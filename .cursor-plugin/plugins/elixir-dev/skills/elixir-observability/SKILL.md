---
name: elixir-observability
description: Use this skill when designing, implementing, reviewing, or refactoring observability in Elixir, Phoenix, Ecto, Oban, Broadway, or OTP applications. Applies when choosing between :telemetry and OpenTelemetry, defining telemetry events, adding metrics, creating spans, propagating trace context, or integrating with observability backends.
---

# Elixir Observability Skill: `:telemetry` + OpenTelemetry

## Core Rule

In Elixir systems, prefer this architecture:

```text
domain/library code
  emits :telemetry events

application boundary
  attaches handlers
  defines metrics
  creates/bridges OpenTelemetry spans
  exports to collector/vendor/backend
```

Use `:telemetry` as the internal instrumentation contract.

Use OpenTelemetry for distributed tracing, cross-service context propagation, exporters, collectors, and vendor-neutral observability integration.

Do not treat `:telemetry` and OpenTelemetry as competitors. They solve different layers of the observability stack.

## Decision Model

Use `:telemetry` when:

* Instrumenting reusable Elixir libraries.
* Emitting internal domain/application events.
* Adding metrics around Phoenix, Ecto, Oban, Broadway, GenServers, jobs, or domain workflows.
* You want backend-neutral instrumentation.
* You want app-local handlers, reporters, logs, counters, timings, or custom diagnostics.

Use OpenTelemetry when:

* You need distributed traces.
* You need trace/span context across services.
* You export to an OpenTelemetry Collector.
* You integrate with Grafana Tempo, Jaeger, Honeycomb, Datadog, New Relic, SigNoz, OpenObserve, or another tracing backend.
* You need standard semantic conventions for HTTP, DB, messaging, RPC, or external service calls.
* You need log/trace correlation.

Use both when:

* A Phoenix/Ecto/OTP app emits `:telemetry` events internally.
* The release/runtime attaches handlers that turn selected events into metrics and spans.
* Traces are exported through OpenTelemetry.

Only bridge telemetry events into spans when lifecycle, timing, and context are preserved, usually from matched start/stop/exception events. Do not create post-facto spans from a single completed event and imply they measured the original operation.

## Preferred Design

For user code, prefer:

```elixir
:telemetry.execute(
  [:my_app, :billing, :invoice, :created],
  %{count: 1, duration: duration},
  %{account_id: account_id, invoice_id: invoice_id}
)
```

For boundary/runtime code, prefer:

```elixir
:telemetry.attach_many(
  "my-app-observability",
  [
    [:my_app, :billing, :invoice, :created],
    [:my_app, :billing, :invoice, :failed]
  ],
  &MyApp.Observability.handle_event/4,
  %{}
)
```

OpenTelemetry belongs in application-level observability modules, not deep domain modules, unless the code truly needs active span context.

## Naming Conventions

Telemetry event names must be lists of atoms.

Use stable, hierarchical names:

```elixir
[:my_app, :domain, :resource, :event]
[:my_app, :worker, :job, :start]
[:my_app, :worker, :job, :stop]
[:my_app, :worker, :job, :exception]
```

Good examples:

```elixir
[:yellowdog, :repo, :query, :slow]
[:yellowdog, :ingest, :document, :parsed]
[:yellowdog, :pipeline, :stage, :stop]
[:gsmlg, :billing, :invoice, :paid]
```

Avoid:

```elixir
[:event]
[:thing_happened]
[:my_app, :misc]
[:my_app, :debug, :temporary]
```

Names should be part of the public instrumentation contract. Do not rename events casually.

## Measurement Rules

Measurements are numeric values.

Good measurements:

```elixir
%{
  count: 1,
  duration: native_duration,
  queue_time: native_duration,
  bytes: byte_size,
  rows: row_count
}
```

Bad measurements:

```elixir
%{
  user_id: user_id,
  status: "ok",
  request_id: request_id
}
```

Put descriptive/contextual values in metadata, not measurements.

Prefer native time for internal timing:

```elixir
start = System.monotonic_time()

result = do_work()

duration = System.monotonic_time() - start

:telemetry.execute(
  [:my_app, :worker, :job, :stop],
  %{duration: duration},
  %{job: job_name}
)
```

Convert units at the reporting/export layer.

## Metadata Rules

Metadata should describe the event.

Good metadata:

```elixir
%{
  module: __MODULE__,
  function: :sync_account,
  account_id: account_id,
  result: :ok
}
```

Metadata may include atoms, integers, strings, IDs, modules, and small maps.

Avoid putting high-cardinality or sensitive metadata into metrics labels.

Be careful with:

* `user_id`
* `account_id`
* `email`
* `request_id`
* `trace_id`
* raw URLs
* raw SQL
* params
* tokens
* secrets
* full error payloads

These may be acceptable in traces or logs, depending on policy, but are usually dangerous as metric labels.

## Handler Rules

Telemetry handlers run in the calling process, so they must be fast, non-blocking, and failure-safe. The official telemetry docs describe `execute/3` as invoking attached handlers for emitted events. ([Hexdocs][2])

Handlers must not:

* perform blocking network calls
* perform expensive serialization
* call external APIs
* write synchronously to slow storage
* raise exceptions
* allocate large structures
* perform unbounded work

Handlers should:

* increment counters
* record metrics
* add span attributes/events
* enqueue work elsewhere if needed
* sample aggressively for high-volume events
* rescue defensively if necessary

## Phoenix/Ecto Guidance

Phoenix and Ecto already emit `:telemetry` events. Phoenix's telemetry guide describes using Telemetry events, `Telemetry.Metrics`, reporters, and the generated telemetry supervisor in Phoenix apps. ([GitHub][3])

Do not duplicate built-in Phoenix/Ecto instrumentation unless there is a specific missing domain signal.

Prefer defining metrics in:

```text
lib/my_app_web/telemetry.ex
```

Typical Phoenix metrics:

```elixir
summary("phoenix.endpoint.stop.duration",
  unit: {:native, :millisecond}
)

counter("phoenix.endpoint.stop.duration")

summary("my_app.repo.query.total_time",
  unit: {:native, :millisecond}
)
```

Use application-specific telemetry for domain workflows that Phoenix/Ecto cannot know about.

## OpenTelemetry Guidance

For OpenTelemetry in Elixir/Erlang, the standard dependency split is:

* `opentelemetry_api` for instrumentation APIs.
* `opentelemetry` for the SDK implementation.
* `opentelemetry_exporter` for exporting to an OpenTelemetry Collector or vendor backend.

The OpenTelemetry Erlang/Elixir getting-started docs describe this split and note that API calls are no-ops without the SDK. ([OpenTelemetry][4])

Use OpenTelemetry instrumentation packages where appropriate. Choose current compatible versions for the target project instead of copying placeholder dependency tuples.

Relevant package names include `opentelemetry_api`, `opentelemetry`, `opentelemetry_exporter`, `opentelemetry_phoenix`, and `opentelemetry_ecto`.

The OpenTelemetry Erlang contrib repository lists automatic instrumentation support for Cowboy, Phoenix, Ecto, and Req. ([GitHub][5])

Prefer auto-instrumentation for standard infrastructure:

* Phoenix HTTP requests
* Ecto database queries
* Cowboy/Plug boundaries
* Req HTTP clients

Use manual spans for domain workflows:

```elixir
require OpenTelemetry.Tracer, as: Tracer

Tracer.with_span "billing.create_invoice" do
  Tracer.set_attribute("billing.account_id", account_id)

  create_invoice(account_id)
end
```

Do not wrap every function in spans. Spans should represent meaningful operations.

## Span Design

Good spans:

```text
billing.create_invoice
pipeline.parse_document
worker.sync_account
external.github.fetch_repo
```

Bad spans:

```text
do_work
handle_call
map
process
run
```

A span should usually represent:

* an inbound request
* an outbound request
* a database operation
* a job execution
* a pipeline stage
* a meaningful domain operation
* a slow or failure-prone boundary

Keep span attributes bounded and non-sensitive.

## Metrics vs Traces

Use metrics for:

* rates
* counts
* durations
* queue sizes
* error totals
* resource usage
* SLO/SLA signals
* alerting

Use traces for:

* request flow
* cross-service causality
* latency breakdown
* debugging failures
* N+1 query diagnosis
* external dependency visibility

Use logs for:

* discrete facts
* audit-ish records
* human-readable debugging
* exceptional conditions

Do not use traces as your primary alerting source. Do not use logs as your primary metrics system.

## Preferred Architecture

For umbrella apps or multi-app systems:

```text
apps/core
  emits domain :telemetry events
  does not depend on OpenTelemetry

apps/web
  uses Phoenix/Ecto instrumentation
  defines web metrics

apps/worker
  emits job/pipeline telemetry
  may create job-level spans

apps/observability
  attaches telemetry handlers
  defines Telemetry.Metrics
  configures OpenTelemetry
  owns exporters/reporters
```

For a release:

```text
runtime config
  configures exporters, endpoints, sampling, service name

application supervision tree
  starts telemetry reporter
  initializes OpenTelemetry
  attaches handlers
```

## Review Checklist

When reviewing Elixir observability code, check:

1. Does domain/library code emit `:telemetry` instead of depending directly on a vendor?
2. Are event names stable, hierarchical lists of atoms?
3. Are measurements numeric?
4. Is metadata bounded, useful, and non-sensitive?
5. Are metric labels low-cardinality?
6. Are handlers fast and non-blocking?
7. Are Phoenix/Ecto built-in events reused where possible?
8. Are OpenTelemetry spans meaningful rather than noisy?
9. Is trace context propagated across service boundaries?
10. Are exporters configured only at the application/runtime boundary?
11. Are tests asserting important telemetry events?
12. Are units explicit when defining metrics?
13. Is sampling configured for high-volume tracing?
14. Are errors represented consistently in metrics, traces, and logs?

## Testing Pattern

When adding telemetry, test the contract.

Prefer testing that the event exists and has the expected shape. Avoid over-testing incidental metadata.

Read [references/examples.md](references/examples.md) when adding telemetry tests, writing copyable examples, or checking common observability anti-patterns.

## Common Mistakes

Avoid OpenTelemetry dependencies in core domain code without a need for active span context. Emit `:telemetry` events from domain code and bridge them at the boundary if needed.

Avoid high-cardinality metric labels such as user IDs, account IDs, emails, request IDs, raw URLs, raw SQL, params, tokens, secrets, and full error payloads. Prefer bounded labels such as plan, region, result, status class, queue, worker, or operation.

## Output Style For This Skill

When responding to observability questions:

* Start with the recommended architecture.
* Distinguish `:telemetry`, `Telemetry.Metrics`, OpenTelemetry API, OpenTelemetry SDK, and exporters.
* Prefer small, composable examples.
* Avoid vendor lock-in.
* Prefer functional boundaries and explicit data flow.
* Do not suggest wrapping everything in spans.
* Do not suggest using OpenTelemetry as a replacement for `:telemetry`.
* Treat observability as a contract: events, measurements, metadata, labels, spans, and exporters each have separate responsibilities.

## Default Recommendation

When uncertain, recommend:

```text
Emit :telemetry events from Elixir code.
Define metrics with Telemetry.Metrics.
Attach lightweight handlers at the application boundary.
Use OpenTelemetry for distributed traces and exporting.
Keep vendors outside the domain.
```

[2]: https://hexdocs.pm/telemetry/telemetry.html
[3]: https://github.com/phoenixframework/phoenix/blob/master/guides/telemetry.md
[4]: https://opentelemetry.io/docs/languages/erlang/getting-started/
[5]: https://github.com/open-telemetry/opentelemetry-erlang-contrib
