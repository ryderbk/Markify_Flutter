import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calculations.dart';

void main() => runApp(const MarkifyApp());

class MarkifyApp extends StatefulWidget {
  const MarkifyApp({super.key});
  @override
  State<MarkifyApp> createState() => _MarkifyAppState();
}

class _MarkifyAppState extends State<MarkifyApp> {
  ThemeMode mode = ThemeMode.light;
  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(
      () => mode = preferences.getBool('dark_mode') == true
          ? ThemeMode.dark
          : ThemeMode.light,
    );
  }

  Future<void> _toggleTheme() async {
    final next = mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setState(() => mode = next);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('dark_mode', next == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Markify',
    debugShowCheckedModeBanner: false,
    themeMode: mode,
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
    home: HomeScreen(onTheme: _toggleTheme),
  );
}

ThemeData _theme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xff7aa8ff),
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark
        ? const Color(0xff0b1220)
        : const Color(0xffe9eff7),
    fontFamily: 'Arial',
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark
          ? Colors.white.withOpacity(.06)
          : Colors.white.withOpacity(.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onTheme});
  final VoidCallback onTheme;
  @override
  Widget build(BuildContext context) => AppShell(
    title: 'Markify',
    actions: [
      IconButton(
        onPressed: onTheme,
        icon: Icon(
          Theme.of(context).brightness == Brightness.dark
              ? Icons.light_mode
              : Icons.dark_mode,
        ),
        tooltip: 'Toggle theme',
      ),
    ],
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        const Icon(Icons.school_rounded, size: 54, color: Color(0xff7aa8ff)),
        const SizedBox(height: 16),
        Text(
          'Welcome to Markify',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'All your academic calculations in one place',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 28),
        ...[
          (
            'Internal Score',
            'Calculate theory and integrated internal marks.',
            Icons.calculate_rounded,
            const InternalScreen(),
          ),
          (
            'Target Sense',
            'Plan model and semester examination targets.',
            Icons.track_changes_rounded,
            const TargetScreen(),
          ),
          (
            'GPA Predictor',
            'Predict GPA based on expected marks.',
            Icons.insights_rounded,
            const GpaScreen(),
          ),
          (
            'CGPA Calculator',
            'Calculate cumulative grade points.',
            Icons.timeline_rounded,
            const CgpaScreen(),
          ),
          (
            'CGPA Booster',
            'Plan the GPA required to reach a target CGPA.',
            Icons.rocket_launch_rounded,
            const BoosterScreen(),
          ),
        ].map(
          (tool) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: GlassCard(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => tool.$4),
              ),
              child: Row(
                children: [
                  Icon(
                    tool.$3,
                    color: Theme.of(context).colorScheme.primary,
                    size: 30,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tool.$1,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(tool.$2),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });
  final String title;
  final Widget child;
  final List<Widget>? actions;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      actions: actions,
      backgroundColor: Colors.transparent,
    ),
    body: child,
  );
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
  });
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(.07)
            : Colors.white.withOpacity(.58),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.07),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
    return onTap == null
        ? card
        : InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: card,
          );
  }
}

class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.label,
    required this.controller,
    this.max,
  });
  final String label;
  final TextEditingController controller;
  final double? max;
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: const [],
    decoration: InputDecoration(
      labelText: label,
      suffixText: max == null
          ? null
          : 'max ${max!.toStringAsFixed(max! % 1 == 0 ? 0 : 1)}',
    ),
  );
}

double? parse(TextEditingController c) => double.tryParse(c.text.trim());
List<TextEditingController> controllers(int count) =>
    List.generate(count, (_) => TextEditingController());

class InternalScreen extends StatefulWidget {
  const InternalScreen({super.key});
  @override
  State<InternalScreen> createState() => _InternalScreenState();
}

class _InternalScreenState extends State<InternalScreen> {
  bool theory = true;
  late List<TextEditingController> fields;
  ScoreResult? result;
  @override
  void initState() {
    super.initState();
    fields = controllers(6);
  }

  @override
  void dispose() {
    for (final c in fields) c.dispose();
    super.dispose();
  }

  void reset() {
    for (final c in fields) c.clear();
    setState(() => result = null);
  }

  @override
  Widget build(BuildContext context) {
    final labels = theory
        ? [
            'CIE 1 (50)',
            'CIE 2 (50)',
            'Assignment 1 (10)',
            'Assignment 2 (10)',
            'Assignment 3 (10)',
            'Model (100)',
          ]
        : [
            'CIE 1 (50)',
            'CIE 2 (50)',
            'CIE 3 (100)',
            'Practical 1 (50)',
            'Practical 2 (50)',
            'Practical 3 (100)',
          ];
    return AppShell(
      title: 'Internal Score',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Theory')),
              ButtonSegment(value: false, label: Text('Integrated')),
            ],
            selected: {theory},
            onSelectionChanged: (s) => setState(() {
              theory = s.first;
              result = null;
            }),
          ),
          const SizedBox(height: 20),
          GlassCard(
            child: Column(
              children: [
                ...labels.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NumberField(
                      label: e.value,
                      controller: fields[e.key],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => setState(
                          () => result = theory
                              ? theoryScore(fields.map(parse).toList())
                              : integratedScore(fields.map(parse).toList()),
                        ),
                        icon: const Icon(Icons.calculate),
                        label: const Text('Calculate'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: reset,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Reset',
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (result != null) ...[
            const SizedBox(height: 18),
            ResultCard(result: result!),
          ],
        ],
      ),
    );
  }
}

class ResultCard extends StatelessWidget {
  const ResultCard({super.key, required this.result});
  final ScoreResult result;
  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${result.total.toStringAsFixed(1)} / ${result.maximum.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text('${result.percentage.toStringAsFixed(1)}%  •  ${result.message}'),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: result.percentage / 100,
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    ),
  );
}

class TargetScreen extends StatefulWidget {
  const TargetScreen({super.key});
  @override
  State<TargetScreen> createState() => _TargetScreenState();
}

class _TargetScreenState extends State<TargetScreen> {
  String type = 'Model Theory';
  final target = TextEditingController();
  late List<TextEditingController> fields;
  String? result;
  @override
  void initState() {
    super.initState();
    fields = controllers(5);
  }

  @override
  void dispose() {
    target.dispose();
    for (final c in fields) c.dispose();
    super.dispose();
  }

  void calculate() {
    final t = parse(target);
    if (t == null ||
        t < 0 ||
        t >
            (type == 'Semester'
                ? 100
                : type.contains('Integrated')
                ? 50
                : 40)) {
      setState(
        () => result = 'Enter a valid target within the permitted range.',
      );
      return;
    }
    double known;
    if (type == 'Model Theory')
      known =
          fields[0].let(0, 50, 8) +
          fields[1].let(0, 50, 8) +
          fields[2].let(0, 10, 4) +
          fields[3].let(0, 10, 4) +
          fields[4].let(0, 10, 6);
    else if (type == 'Model Integrated')
      known =
          fields[0].let(0, 50, 7) +
          fields[1].let(0, 50, 7) +
          fields[2].let(0, 50, 7) +
          fields[3].let(0, 50, 7) +
          fields[4].let(0, 100, 11);
    else {
      final values = fields.map(parse).map((v) => v ?? 0);
      final messages = values
          .map(
            (v) => v >= t
                ? 'Already achieved'
                : v > 40
                ? 'Invalid internal mark'
                : ((t - v) / 60 * 100 > 100
                      ? 'Impossible target'
                      : 'Need ${((t - v) / 60 * 100).toStringAsFixed(1)}/100 (safe target ${((t - v) / 60 * 100).ceil()})'),
          )
          .toList();
      setState(
        () => result = messages
            .asMap()
            .entries
            .map((e) => 'Subject ${e.key + 1}: ${e.value}')
            .join('\n'),
      );
      return;
    }
    final required = type == 'Model Theory'
        ? requiredMark(t, known, 10, 10)
        : requiredMark(t, known, 11, 100);
    setState(
      () => result = required <= 0
          ? 'Target already achieved.'
          : required > 100
          ? 'Impossible target. You would need ${required.toStringAsFixed(1)}/100.'
          : 'Required examination mark: ${required.ceil()}/100 (precise ${required.toStringAsFixed(1)}).',
    );
  }

  @override
  Widget build(BuildContext context) {
    final semester = type == 'Semester';
    final labels = type == 'Model Theory'
        ? [
            'CIE 1 (50)',
            'CIE 2 (50)',
            'Assignment 1 (10)',
            'Assignment 2 (10)',
            'Assignment 3 (10)',
          ]
        : type == 'Model Integrated'
        ? [
            'CIE 1 (50)',
            'CIE 2 (50)',
            'Practical 1 (50)',
            'Practical 2 (50)',
            'Practical 3 (100)',
          ]
        : List.generate(fields.length, (i) => 'Subject ${i + 1} internal (40)');
    final visibleFields = semester ? fields : fields.take(5).toList();
    return AppShell(
      title: 'Target Sense',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DropdownButtonFormField<String>(
            value: type,
            decoration: const InputDecoration(labelText: 'Workflow'),
            items: const [
              'Model Theory',
              'Model Integrated',
              'Semester',
            ].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
            onChanged: (x) => setState(() {
              type = x!;
              result = null;
            }),
          ),
          const SizedBox(height: 12),
          NumberField(
            label: semester
                ? 'Target percentage (100)'
                : 'Target internal mark',
            controller: target,
            max: semester
                ? 100
                : type.contains('Integrated')
                ? 50
                : 40,
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              children: [
                ...visibleFields.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NumberField(
                      label: labels[e.key],
                      controller: e.value,
                    ),
                  ),
                ),
                if (semester)
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => fields.add(TextEditingController())),
                        icon: const Icon(Icons.add),
                        label: const Text('Add subject'),
                      ),
                      TextButton.icon(
                        onPressed: fields.length > 1
                            ? () =>
                                  setState(() => fields.removeLast().dispose())
                            : null,
                        icon: const Icon(Icons.remove),
                        label: const Text('Remove subject'),
                      ),
                    ],
                  ),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: calculate,
                        child: const Text('Calculate'),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        for (final c in fields) c.clear();
                        target.clear();
                        setState(() => result = null);
                      },
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Reset',
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (result != null) ...[
            const SizedBox(height: 16),
            GlassCard(
              child: Text(
                result!,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

extension on TextEditingController {
  double let(double min, double max, double weight) {
    final v = double.tryParse(text) ?? 0;
    return v.clamp(min, max) / max * weight;
  }
}

class GpaScreen extends StatefulWidget {
  const GpaScreen({super.key});
  @override
  State<GpaScreen> createState() => _GpaScreenState();
}

class _GpaScreenState extends State<GpaScreen> {
  final papers = <Paper>[Paper()];
  String? result;
  void reset() => setState(() {
    papers
      ..clear()
      ..add(Paper());
    result = null;
  });
  @override
  Widget build(BuildContext context) => AppShell(
    title: 'GPA Predictor',
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ...papers.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              child: Column(
                children: [
                  DropdownButtonFormField<bool>(
                    value: entry.value.integrated,
                    decoration: const InputDecoration(labelText: 'Paper type'),
                    items: const [
                      DropdownMenuItem(value: false, child: Text('Theory')),
                      DropdownMenuItem(value: true, child: Text('Integrated')),
                    ],
                    onChanged: (v) =>
                        setState(() => entry.value.integrated = v!),
                  ),
                  const SizedBox(height: 12),
                  NumberField(
                    label: 'Credits (20)',
                    controller: entry.value.credits,
                    max: 20,
                  ),
                  const SizedBox(height: 12),
                  NumberField(
                    label: 'Internal marks',
                    controller: entry.value.internal,
                    max: entry.value.integrated ? 50 : 40,
                  ),
                  const SizedBox(height: 12),
                  NumberField(
                    label: 'Expected external (100)',
                    controller: entry.value.external,
                    max: 100,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: papers.length > 1
                          ? () => setState(() {
                              entry.value.dispose();
                              papers.removeAt(entry.key);
                            })
                          : null,
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          children: [
            TextButton.icon(
              onPressed: () => setState(() => papers.add(Paper())),
              icon: const Icon(Icons.add),
              label: const Text('Add paper'),
            ),
            TextButton.icon(
              onPressed: papers.length > 1
                  ? () => setState(() {
                      papers.removeLast().dispose();
                    })
                  : null,
              icon: const Icon(Icons.remove),
              label: const Text('Remove'),
            ),
          ],
        ),
        FilledButton(
          onPressed: () {
            final values = papers.map((p) {
              final credits = parse(p.credits) ?? 0;
              final internal = (parse(p.internal) ?? 0).clamp(
                0,
                p.integrated ? 50 : 40,
              );
              final external = (parse(p.external) ?? 0).clamp(0, 100);
              final mark = internal + external / 100 * (p.integrated ? 50 : 60);
              return (gradePoint(mark), credits);
            }).toList();
            setState(
              () => result =
                  'Predicted GPA: ${weightedAverage(values).toStringAsFixed(2)}',
            );
          },
          child: const Text('Predict GPA'),
        ),
        if (result != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: GlassCard(
              child: Text(
                result!,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
        TextButton(onPressed: reset, child: const Text('Reset')),
      ],
    ),
  );
}

class Paper {
  bool integrated = false;
  final credits = TextEditingController();
  final internal = TextEditingController();
  final external = TextEditingController();
  void dispose() {
    credits.dispose();
    internal.dispose();
    external.dispose();
  }
}

class CgpaScreen extends StatefulWidget {
  const CgpaScreen({super.key});
  @override
  State<CgpaScreen> createState() => _CgpaScreenState();
}

class _CgpaScreenState extends State<CgpaScreen> {
  final semesters = <Semester>[Semester()];
  String? result;
  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'CGPA Calculator',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ...semesters.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: Row(
                  children: [
                    Expanded(
                      child: NumberField(
                        label: 'Semester ${e.key + 1} GPA (10)',
                        controller: e.value.gpa,
                        max: 10,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: NumberField(
                        label: 'Credits (30)',
                        controller: e.value.credits,
                        max: 30,
                      ),
                    ),
                    IconButton(
                      onPressed: semesters.length > 1
                          ? () => setState(() {
                              e.value.dispose();
                              semesters.removeAt(e.key);
                            })
                          : null,
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed: semesters.length < 8
                    ? () => setState(() => semesters.add(Semester()))
                    : null,
                icon: const Icon(Icons.add),
                label: Text(
                  semesters.length == 8 ? '8 semester limit' : 'Add semester',
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  for (final s in semesters) {
                    s.dispose();
                  }
                  setState(() {
                    semesters
                      ..clear()
                      ..add(Semester());
                    result = null;
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          FilledButton(
            onPressed: () {
              final values = semesters
                  .map(
                    (s) => (
                      double.tryParse(s.gpa.text) ?? 0,
                      double.tryParse(s.credits.text) ?? 0,
                    ),
                  )
                  .toList();
              setState(
                () => result =
                    'CGPA: ${weightedAverage(values).toStringAsFixed(2)}',
              );
            },
            child: const Text('Calculate CGPA'),
          ),
          if (result != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: GlassCard(
                child: Text(
                  result!,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Semester {
  final gpa = TextEditingController();
  final credits = TextEditingController();
  void dispose() {
    gpa.dispose();
    credits.dispose();
  }
}

class BoosterScreen extends StatefulWidget {
  const BoosterScreen({super.key});
  @override
  State<BoosterScreen> createState() => _BoosterScreenState();
}

class _BoosterScreenState extends State<BoosterScreen> {
  final target = TextEditingController();
  final semesters = <TextEditingController>[TextEditingController()];
  String? result;
  @override
  void dispose() {
    target.dispose();
    for (final c in semesters) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppShell(
    title: 'CGPA Booster',
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        NumberField(
          label: 'Target final CGPA (10)',
          controller: target,
          max: 10,
        ),
        const SizedBox(height: 16),
        ...semesters.asMap().entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              child: Row(
                children: [
                  Expanded(
                    child: NumberField(
                      label: 'Completed semester ${e.key + 1} GPA',
                      controller: e.value,
                      max: 10,
                    ),
                  ),
                  IconButton(
                    onPressed: semesters.length > 1
                        ? () => setState(() {
                            e.value.dispose();
                            semesters.removeAt(e.key);
                          })
                        : null,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          children: [
            TextButton.icon(
              onPressed: semesters.length < 8
                  ? () => setState(() => semesters.add(TextEditingController()))
                  : null,
              icon: const Icon(Icons.add),
              label: Text(
                semesters.length == 8 ? '8 semester limit' : 'Add semester',
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                for (final c in semesters) c.clear();
                target.clear();
                setState(() => result = null);
              },
              child: const Text('Reset'),
            ),
          ],
        ),
        FilledButton(
          onPressed: () {
            final t = double.tryParse(target.text);
            final values = semesters
                .map((c) => double.tryParse(c.text))
                .toList();
            if (t == null ||
                t < 0 ||
                t > 10 ||
                values.any((v) => v == null || v! < 0 || v > 10)) {
              setState(() => result = 'Enter valid GPAs between 0 and 10.');
              return;
            }
            final remaining = 8 - values.length;
            if (remaining == 0) {
              setState(() => result = 'All eight semesters are complete.');
              return;
            }
            final required =
                (t * 8 - values.fold<double>(0, (a, b) => a + b!)) / remaining;
            setState(
              () => result = required > 10
                  ? 'Even with perfect scores, this target is mathematically impossible.'
                  : required <= 0
                  ? 'You have already achieved your target CGPA!'
                  : 'Required GPA per remaining semester: ${required.toStringAsFixed(2)}',
            );
          },
          child: const Text('Calculate required GPA'),
        ),
        if (result != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: GlassCard(
              child: Text(
                result!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
      ],
    ),
  );
}
