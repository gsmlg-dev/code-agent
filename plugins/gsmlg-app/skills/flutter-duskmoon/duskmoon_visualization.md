# duskmoon_visualization

Data visualization package for the DuskMoon Design System. Provides five chart widgets backed by a vendored `dv_*` ecosystem, with theme-integrated color palettes.

## Installation

```yaml
dependencies:
  duskmoon_visualization: ^0.1.0
```

```dart
import 'package:duskmoon_visualization/duskmoon_visualization.dart';
```

Also available via the umbrella:

```dart
import 'package:duskmoon_ui/duskmoon_ui.dart';
```

For advanced/low-level vendor access:

```dart
import 'package:duskmoon_visualization/duskmoon_visualization_compat.dart';
```

## Chart Widgets

### DmVizLineChart

```dart
DmVizLineChart(
  data: [
    DmVizPoint(x: 1, y: 10),
    DmVizPoint(x: 2, y: 25),
    DmVizPoint(x: 3, y: 18),
  ],
  comparisonData: [           // Optional second line (dashed)
    DmVizPoint(x: 1, y: 8),
    DmVizPoint(x: 2, y: 20),
    DmVizPoint(x: 3, y: 22),
  ],
  xAxisLabel: 'Month',
  yAxisLabel: 'Revenue',
  smooth: true,               // Curved primary line (default: true)
  showMarkers: true,          // Point markers (default: true)
  palette: null,              // Auto-derived from theme if null
)
```

- Y-axis always includes zero
- Comparison series uses dashed line, always linear (no smoothing)

### DmVizBarChart

```dart
DmVizBarChart(
  data: [
    DmVizPoint(x: 'Jan', y: 42),
    DmVizPoint(x: 'Feb', y: 67),
    DmVizPoint(x: 'Mar', y: 55),
  ],
  xAxisLabel: 'Month',
  yAxisLabel: 'Units',
  cornerRadius: 8,            // Bar corner radius (default: 8)
  palette: null,
)
```

### DmVizScatterChart

```dart
DmVizScatterChart(
  data: [
    DmVizPoint(x: 1.2, y: 3.4, metadata: {'label': 'A'}),
    DmVizPoint(x: 2.8, y: 1.9),
  ],
  xAxisLabel: 'X',
  yAxisLabel: 'Y',
  shape: DmVizMarkerShape.circle,   // Marker shape (default: circle)
  radiusAccessor: (p) => (p.y * 3).clamp(4, 20), // Dynamic size
  palette: null,
)
```

`DmVizMarkerShape` values: `circle`, `square`, `triangle`, `diamond`, `cross`, `plus`, `star`

### DmVizHeatmap

```dart
DmVizHeatmap(
  rows: 5,
  columns: 7,
  data: [
    DmVizHeatmapCell(row: 0, column: 0, value: 0.8),
    DmVizHeatmapCell(row: 0, column: 1, value: 0.3),
    // ...
  ],
  rowLabels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
  columnLabels: ['00h', '04h', '08h', '12h', '16h', '20h', '24h'],
  showValues: true,            // Show value text in cells (default: true)
  palette: null,
)
```

Uses Viridis color scale from min to max cell value.

### DmVizNetworkGraph

```dart
DmVizNetworkGraph(
  nodes: [
    DmVizNetworkNode(id: 'a', label: 'Alpha', group: 'team1', radius: 12),
    DmVizNetworkNode(id: 'b', label: 'Beta', group: 'team2'),
    DmVizNetworkNode(id: 'c', label: 'Gamma', x: 100, y: 100, fixed: true),
  ],
  links: [
    DmVizNetworkEdge(source: 'a', target: 'b', weight: 2.0, directed: true),
    DmVizNetworkEdge(source: 'b', target: 'c', label: 'connects', width: 2),
  ],
  enableSimulation: false,         // Force-directed layout (default: false)
  showNodeLabels: true,            // Node labels (default: true)
  showLinkLabels: false,           // Edge labels (default: false)
  enableZoomPan: true,             // Zoom/pan (default: true)
  draggableNodes: true,            // Draggable nodes (default: true)
  nodeShape: DmVizNetworkNodeShape.circle,    // default: circle
  linkStyle: DmVizNetworkLinkStyle.curved,    // default: curved
  groupColors: {'team1': Colors.blue, 'team2': Colors.red},
  onNodeTap: (node) => print(node.id),
  onLinkTap: (edge) => print('${edge.source} -> ${edge.target}'),
  palette: null,
)
```

`DmVizNetworkNodeShape` values: `circle`, `square`, `diamond`, `triangle`, `hexagon`

`DmVizNetworkLinkStyle` values: `straight`, `curved`, `dashed`

## Data Models

### DmVizPoint

Used by line, bar, and scatter charts:

```dart
DmVizPoint(
  x: 1.0,                          // Object? — numeric or label
  y: 42.0,                         // double
  metadata: {'label': 'Item A'},   // Optional
)
```

### DmVizHeatmapCell

```dart
DmVizHeatmapCell(
  row: 0,
  column: 3,
  value: 0.75,              // Intensity value
  metadata: {'hour': '12h'},
)
```

### DmVizNetworkNode

```dart
DmVizNetworkNode(
  id: 'node1',             // Unique identifier (required)
  label: 'Node 1',
  group: 'cluster_a',      // Used for groupColors mapping
  x: 200, y: 150,          // Pre-set position (auto if null)
  fixed: false,            // Lock position during simulation
  radius: 10,              // Node size (default: 10)
  color: Colors.blue,      // Overrides group color
)
```

### DmVizNetworkEdge

```dart
DmVizNetworkEdge(
  source: 'node1',         // Source node ID (required)
  target: 'node2',         // Target node ID (required)
  weight: 1.0,             // Layout weight (default: 1)
  label: 'link',
  color: Colors.grey,
  width: 1.0,              // Stroke width (default: 1)
  directed: false,         // Arrow head (default: false)
)
```

## Theme Integration: DmChartPalette

All chart widgets auto-derive colors from `Theme.of(context)` via `DmChartPalette.fromTheme()`. Override with a custom palette:

```dart
DmChartPalette(
  background: Colors.white,
  grid: Colors.grey[200]!,
  axis: Colors.grey[600]!,
  primary: Colors.blue,
  secondary: Colors.orange,
  positive: Colors.green,
  positiveOnColor: Colors.green[700]!,
  warning: Colors.amber,
  warningOnColor: Colors.amber[700]!,
  heatmapBorder: Colors.grey[300]!,
)
```

The factory uses `DmColorExtension` if present in the theme, falling back to Material 3 color roles.
