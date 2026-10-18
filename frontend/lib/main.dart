import 'package:flutter/material.dart';

import 'api_client.dart';
import 'print_helper.dart';

void main() => runApp(const GreenhouseApp());

class GreenhouseApp extends StatelessWidget {
  const GreenhouseApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Greenhouse Control',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2d7600)),
      scaffoldBackgroundColor: const Color(0xfff0fae7),
      fontFamily: 'Roboto',
      useMaterial3: true,
    ),
    home: const GreenhouseShell(),
  );
}

class GreenhouseShell extends StatefulWidget {
  const GreenhouseShell({super.key});

  @override
  State<GreenhouseShell> createState() => _GreenhouseShellState();
}

class _GreenhouseShellState extends State<GreenhouseShell> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 900;
      return Scaffold(
        key: scaffoldKey,
        drawer: compact ? _NavigationDrawer(onSelect: _selectPage) : null,
        body: Row(
          children: [
            if (!compact)
              _Sidebar(selectedIndex: selectedIndex, onSelect: _selectPage),
            Expanded(
              child: SafeArea(
                child: _PageContent(
                  selectedIndex: selectedIndex,
                  compact: compact,
                  onMenu: compact
                      ? () => scaffoldKey.currentState?.openDrawer()
                      : null,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );

  void _selectPage(int index) {
    setState(() => selectedIndex = index);
    Navigator.of(context).maybePop();
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => Container(
    width: 194,
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(18, 30, 18, 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TITO MERMANO',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 58),
        _NavItem(
          icon: Icons.dashboard_outlined,
          label: 'Dashboard',
          selected: selectedIndex == 0,
          onTap: () => onSelect(0),
        ),
        _NavItem(
          icon: Icons.local_florist_outlined,
          label: 'Watering History',
          selected: selectedIndex == 1,
          onTap: () => onSelect(1),
        ),
        _NavItem(
          icon: Icons.bar_chart_outlined,
          label: 'Sensor Readings',
          selected: selectedIndex == 2,
          onTap: () => onSelect(2),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined, size: 26),
          tooltip: 'Settings',
        ),
      ],
    ),
  );
}

class _NavigationDrawer extends StatelessWidget {
  const _NavigationDrawer({required this.onSelect});

  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => Drawer(
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TITO MERMANO',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              onTap: () => onSelect(0),
            ),
            ListTile(
              leading: const Icon(Icons.local_florist_outlined),
              title: const Text('Watering History'),
              onTap: () => onSelect(1),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart_outlined),
              title: const Text('Sensor Readings'),
              onTap: () => onSelect(2),
            ),
          ],
        ),
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Material(
      type: MaterialType.transparency,
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selected: selected,
        selectedTileColor: const Color(0xffe5f2dc),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: Icon(
          icon,
          color: selected ? const Color(0xff2d7600) : Colors.black87,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        onTap: onTap,
      ),
    ),
  );
}

class _PageContent extends StatelessWidget {
  const _PageContent({
    required this.selectedIndex,
    required this.compact,
    required this.onMenu,
  });

  final int selectedIndex;
  final bool compact;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    const titles = ['Dashboard', 'Watering History', 'Sensor Readings'];
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        compact ? 18 : 24,
        20,
        compact ? 18 : 24,
        28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onMenu != null)
                IconButton(
                  onPressed: onMenu,
                  icon: const Icon(Icons.menu),
                  tooltip: 'Open navigation',
                ),
              Text(
                titles[selectedIndex],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xffccdec3),
                child: Icon(Icons.person_outline, color: Color(0xff384b2c)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (selectedIndex == 0) const _DashboardPage(),
          if (selectedIndex == 1) const _WateringHistoryPage(),
          if (selectedIndex == 2) const _SensorReadingsPage(),
        ],
      ),
    );
  }
}

class _DashboardPage extends StatefulWidget {
  const _DashboardPage();

  @override
  State<_DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<_DashboardPage> {
  final api = GreenhouseApi();
  GreenhouseSnapshot? snapshot;

  @override
  void initState() {
    super.initState();
    api
        .loadSnapshot()
        .then((value) {
          if (mounted) setState(() => snapshot = value);
        })
        .catchError((_) {});
  }

  @override
  void dispose() {
    api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _ConditionsCard(snapshot: snapshot),
      const SizedBox(height: 22),
      LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 1050;
          return wide
              ? const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _UsageChart()),
                    SizedBox(width: 16),
                    SizedBox(width: 300, child: _HistorySummary()),
                  ],
                )
              : const Column(
                  children: [
                    _UsageChart(),
                    SizedBox(height: 16),
                    _HistorySummary(),
                  ],
                );
        },
      ),
      const SizedBox(height: 22),
      LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth > 850
              ? 3
              : constraints.maxWidth > 500
              ? 2
              : 1;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sensor Status',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.45,
                children: [
                  _PumpCard(name: 'Water Pump #1', pumpId: _pumpId(0)),
                  _PumpCard(name: 'Water Pump #2', pumpId: _pumpId(1)),
                  _PumpCard(name: 'Water Pump #3', pumpId: _pumpId(2)),
                ],
              ),
            ],
          );
        },
      ),
      const SizedBox(height: 22),
      const _AlertsCard(),
    ],
  );

  int _pumpId(int index) => snapshot != null && snapshot!.pumps.length > index
      ? snapshot!.pumps[index].id
      : index + 1;
}

class _ConditionsCard extends StatelessWidget {
  const _ConditionsCard({this.snapshot});

  final GreenhouseSnapshot? snapshot;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xffccdec3),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Current Conditions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            const Icon(Icons.info_outline, size: 20, color: Colors.black54),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Sensor readings represent greenhouse metrics',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) => GridView.count(
            crossAxisCount: constraints.maxWidth > 700
                ? 4
                : constraints.maxWidth > 420
                ? 2
                : 1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.5,
            children: [
              _MetricCard(label: "Today's water usage", value: '350 mL'),
              _MetricCard(
                label: 'Soil Moisture',
                value: '${snapshot?.sensor?.moisture ?? 45}%',
              ),
              _MetricCard(
                label: 'Humidity',
                value: '${snapshot?.sensor?.waterLevel ?? 45}%',
              ),
              const _MetricCard(label: 'Temperature', value: '31 C'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Last updated · ${_formatRecordedAt(snapshot?.sensor?.recordedAt)}',
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ),
      ],
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _UsageChart extends StatelessWidget {
  const _UsageChart();

  @override
  Widget build(BuildContext context) => _Panel(
    title: 'Water Usage History',
    child: SizedBox(
      height: 340,
      child: CustomPaint(
        painter: _ChartPainter(),
        child: const SizedBox.expand(),
      ),
    ),
  );
}

class _ChartPainter extends CustomPainter {
  const _ChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const left = 38.0;
    const top = 18.0;
    final chart = Rect.fromLTWH(
      left,
      top,
      size.width - left - 12,
      size.height - 48,
    );
    final grid = Paint()
      ..color = const Color(0xffb8b8b8)
      ..strokeWidth = 1;
    for (var i = 0; i < 8; i++) {
      final y = chart.top + chart.height * i / 7;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), grid);
    }
    for (var i = 0; i < 12; i++) {
      final x = chart.left + chart.width * i / 11;
      canvas.drawLine(
        Offset(x, chart.top),
        Offset(x, chart.bottom),
        grid..color = const Color(0xffe0e0e0),
      );
    }
    final line = Paint()
      ..color = const Color(0xff007300)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final values = [
      0.72,
      0.51,
      0.62,
      0.43,
      0.8,
      0.55,
      0.69,
      0.48,
      0.58,
      0.4,
      0.63,
      0.52,
    ];
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final point = Offset(
        chart.left + chart.width * i / (values.length - 1),
        chart.bottom - chart.height * values[i],
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(path, line);
    final text = TextPainter(textDirection: TextDirection.ltr);
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    for (var i = 0; i < months.length; i++) {
      text.text = TextSpan(
        text: months[i],
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color(0xff424242),
        ),
      );
      text.layout();
      text.paint(
        canvas,
        Offset(
          chart.left + chart.width * i / 11 - text.width / 2,
          chart.bottom + 12,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) {
      final text = TextPainter(
        text: const TextSpan(
          text: 'Not enough data',
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(
        canvas,
        Offset(
          (size.width - text.width) / 2,
          (size.height - text.height) / 2,
        ),
      );
      return;
    }

    const left = 38.0;
    const top = 18.0;
    final chart = Rect.fromLTWH(
      left,
      top,
      size.width - left - 12,
      size.height - 48,
    );
    final grid = Paint()
      ..color = const Color(0xffb8b8b8)
      ..strokeWidth = 1;
    for (var i = 0; i < 8; i++) {
      final y = chart.top + chart.height * i / 7;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), grid);
    }

    final line = Paint()
      ..color = const Color(0xff007300)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final point = Offset(
        chart.left + chart.width * i / (values.length - 1),
        chart.bottom - chart.height * values[i],
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(path, line);

    final text = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < values.length; i++) {
      text.text = TextSpan(
        text: '${(values[i] * 100).round()}',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color(0xff424242),
        ),
      );
      text.layout();
      text.paint(
        canvas,
        Offset(
          chart.left + chart.width * i / (values.length - 1) - text.width / 2,
          chart.bottom - chart.height * values[i] - text.height - 6,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.values != values;
}

class _HistorySummary extends StatefulWidget {
  const _HistorySummary();

  @override
  State<_HistorySummary> createState() => _HistorySummaryState();
}

class _HistorySummaryState extends State<_HistorySummary> {
  final api = GreenhouseApi();
  List<PumpHistoryEntry>? history;
  bool failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final entries = await api.loadPumpHistory();
      if (mounted) setState(() => history = entries);
    } catch (_) {
      if (mounted) setState(() => failed = true);
    }
  }

  @override
  void dispose() {
    api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = history;
    return _Panel(
      title: 'History Summary',
      child: failed
          ? const Text(
              'Could not load history',
              style: TextStyle(color: Colors.black54),
            )
          : entries == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(),
              ),
            )
          : _summary(entries),
    );
  }

  Widget _summary(List<PumpHistoryEntry> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    bool onDay(PumpHistoryEntry entry, DateTime day) =>
        entry.recordedAt != null && sameDay(entry.recordedAt!, day);

    final todayEntries = entries.where((e) => onDay(e, today)).toList();
    final yesterdayEntries = entries.where((e) => onDay(e, yesterday)).toList();

    if (entries.isEmpty) {
      return const Text(
        'No water usage recorded yet',
        style: TextStyle(color: Colors.black54),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Today', style: TextStyle(fontSize: 17, color: Colors.black54)),
        const SizedBox(height: 12),
        if (todayEntries.isEmpty)
          const Text('No water usage', style: TextStyle(color: Colors.black54))
        else
          ...todayEntries.map(_summaryLine),
        const SizedBox(height: 22),
        const Divider(),
        const SizedBox(height: 12),
        const Text(
          'Yesterday',
          style: TextStyle(fontSize: 17, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        if (yesterdayEntries.isEmpty)
          const Text('No water usage', style: TextStyle(color: Colors.black54))
        else
          ...yesterdayEntries.map(_summaryLine),
      ],
    );
  }

  Widget _summaryLine(PumpHistoryEntry entry) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      '${_pumpLabel(entry)}: ${_formatLiters(entry.liters)} at '
      '${_formatTime(entry.recordedAt)}',
    ),
  );
}

class _PumpCard extends StatefulWidget {
  const _PumpCard({required this.name, required this.pumpId});
  final String name;
  final int pumpId;

  @override
  State<_PumpCard> createState() => _PumpCardState();
}

class _PumpCardState extends State<_PumpCard> {
  bool running = true;
  String mode = 'Drip';
  final api = GreenhouseApi();

  @override
  void dispose() {
    api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.name,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(
          running ? 'Running' : 'Stopped',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 6),
        DropdownButton<String>(
          value: mode,
          isDense: true,
          items: ['Fast', 'Slow', 'Drip', 'Sprinkle']
              .map(
                (value) =>
                    DropdownMenuItem(value: value, child: Text('Mode: $value')),
              )
              .toList(),
          onChanged: (value) async {
            final next = value ?? mode;
            setState(() => mode = next);
            try {
              await api.updatePumpMode(widget.pumpId, _modeValue(next));
            } catch (_) {}
          },
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: running
                  ? const Color(0xff760202)
                  : const Color(0xff384b2c),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            onPressed: () => setState(() => running = !running),
            child: Text(running ? 'Stop' : 'Start'),
          ),
        ),
      ],
    ),
  );

  int _modeValue(String value) =>
      ['Fast', 'Slow', 'Drip', 'Sprinkle'].indexOf(value) + 1;
}

class _AlertsCard extends StatelessWidget {
  const _AlertsCard();

  @override
  Widget build(BuildContext context) => _Panel(
    title: 'Alerts',
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pump #1 Overheating',
          style: TextStyle(
            color: Color(0xff760202),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Check water level in reservoir',
          style: TextStyle(color: Colors.black54),
        ),
      ],
    ),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xffccdec3),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        ),
      ],
    ),
  );
}

class _WateringHistoryPage extends StatefulWidget {
  const _WateringHistoryPage();

  @override
  State<_WateringHistoryPage> createState() => _WateringHistoryPageState();
}

class _WateringHistoryPageState extends State<_WateringHistoryPage> {
  final api = GreenhouseApi();
  List<PumpHistoryEntry>? history;
  bool failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final entries = await api.loadPumpHistory();
      if (mounted) setState(() => history = entries);
    } catch (_) {
      if (mounted) setState(() => failed = true);
    }
  }

  @override
  void dispose() {
    api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = history;
    return _Panel(
      title: 'Watering History',
      child: failed
          ? const Text(
              'Could not load watering history',
              style: TextStyle(color: Colors.black54),
            )
          : entries == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            )
          : entries.isEmpty
          ? const Text(
              'No watering history yet',
              style: TextStyle(color: Colors.black54),
            )
          : Column(
              children: [
                for (final entry in entries)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.water_drop_outlined,
                      color: Color(0xff2d7600),
                    ),
                    title: Text(_pumpLabel(entry)),
                    subtitle: Text(_formatRecordedAt(entry.recordedAt)),
                    trailing: Text(_formatLiters(entry.liters)),
                  ),
              ],
            ),
    );
  }
}

String _pumpLabel(PumpHistoryEntry entry) =>
    entry.pump == null ? 'Pump' : 'Pump #${entry.pump}';

String _formatLiters(double liters) {
  final num value = liters == liters.roundToDouble() ? liters.toInt() : liters;
  return '$value L';
}

String _formatTime(DateTime? recordedAt) {
  if (recordedAt == null) return 'Unknown time';
  final hour24 = recordedAt.hour;
  final hour = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final minute = recordedAt.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${hour24 < 12 ? 'AM' : 'PM'}';
}

String _formatRecordedAt(DateTime? recordedAt) {
  if (recordedAt == null) return 'Unknown date';
  const months = [
    'Jan.',
    'Feb.',
    'Mar.',
    'Apr.',
    'May',
    'Jun.',
    'Jul.',
    'Aug.',
    'Sep.',
    'Oct.',
    'Nov.',
    'Dec.',
  ];
  return '${months[recordedAt.month - 1]} ${recordedAt.day}, '
      '${recordedAt.year} · ${_formatTime(recordedAt)}';
}

class _SensorReadingsPage extends StatefulWidget {
  const _SensorReadingsPage();

  @override
  State<_SensorReadingsPage> createState() => _SensorReadingsPageState();
}

class _SensorReadingsPageState extends State<_SensorReadingsPage> {
  final api = GreenhouseApi();
  List<SensorReading>? readings;
  bool failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final entries = await api.loadSensorReadings();
      if (mounted) setState(() => readings = entries);
    } catch (_) {
      if (mounted) setState(() => failed = true);
    }
  }

  @override
  void dispose() {
    api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = readings;
    final loading = entries == null && !failed;
    final hasData = entries != null && entries.isNotEmpty;
    final values = hasData
        ? entries
            .map((e) => (e.moisture / 100).clamp(0.0, 1.0).toDouble())
            .toList()
        : const <double>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ConditionsCard(
          snapshot: hasData
              ? GreenhouseSnapshot(sensor: entries.last, pumps: const [])
              : null,
        ),
        const SizedBox(height: 22),
        _Panel(
          title: 'Temperature Trends',
          child: SizedBox(
            height: 280,
            child: CustomPaint(
              painter: _ChartPainter(),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _Panel(
          title: 'Moisture Trends',
          child: failed
              ? const Text(
                  'Could not load sensor readings',
                  style: TextStyle(color: Colors.black54),
                )
              : loading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                )
              : !hasData
              ? const Text(
                  'No sensor readings yet',
                  style: TextStyle(color: Colors.black54),
                )
              : SizedBox(
                  height: 280,
                  child: CustomPaint(
                    painter: _LineChartPainter(values: values),
                    child: const SizedBox.expand(),
                  ),
                ),
        ),
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xff384b2c),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            onPressed: printPage,
            child: const Text('Print Detailed Report'),
          ),
        ),
      ],
    );
  }
}
