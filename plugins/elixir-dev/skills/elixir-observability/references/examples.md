# Elixir Observability Examples

Read this file when adding telemetry tests, writing copyable examples, or checking common observability anti-patterns.

## Testing Pattern

When adding telemetry, test the contract.

Use a unique handler id so async tests and repeated runs do not collide:

```elixir
test "emits invoice created telemetry" do
  test_pid = self()
  handler_id = {__MODULE__, self(), :invoice_created}

  :telemetry.attach(
    handler_id,
    [:my_app, :billing, :invoice, :created],
    fn event, measurements, metadata, _config ->
      send(test_pid, {:telemetry_event, event, measurements, metadata})
    end,
    nil
  )

  on_exit(fn ->
    :telemetry.detach(handler_id)
  end)

  Billing.create_invoice(account_id)

  assert_receive {
    :telemetry_event,
    [:my_app, :billing, :invoice, :created],
    %{count: 1},
    %{account_id: ^account_id}
  }
end
```

Prefer testing that the event exists and has the expected shape. Avoid over-testing incidental metadata.

## Domain Instrumentation

Avoid OpenTelemetry dependencies in core domain code without a real need for active span context:

```elixir
# Bad: OpenTelemetry dependency in core domain code without need.
def create_invoice(account_id) do
  OpenTelemetry.Tracer.with_span "create_invoice" do
    ...
  end
end
```

Prefer domain telemetry:

```elixir
def create_invoice(account_id) do
  start = System.monotonic_time()

  result = do_create_invoice(account_id)

  :telemetry.execute(
    [:my_app, :billing, :invoice, :created],
    %{duration: System.monotonic_time() - start, count: 1},
    %{account_id: account_id}
  )

  result
end
```

Then bridge at the boundary if needed.

## Metric Labels

Avoid high-cardinality metric labels:

```elixir
# Bad: high-cardinality metric label
Telemetry.Metrics.counter("my_app.invoice.created.count",
  tags: [:account_id, :user_id, :email]
)
```

Prefer bounded labels:

```elixir
Telemetry.Metrics.counter("my_app.invoice.created.count",
  tags: [:plan, :region, :result]
)
```
