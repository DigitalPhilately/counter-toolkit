import 'package:flutter/material.dart';

void main() {
  runApp(const CounterToolkitApp());
}

class CounterToolkitApp extends StatelessWidget {
  const CounterToolkitApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF1F2A29);
    const pine = Color(0xFF0F5B57);
    const brass = Color(0xFFC8883C);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: pine,
          brightness: Brightness.light,
        ).copyWith(
          primary: pine,
          onPrimary: Colors.white,
          secondary: brass,
          onSecondary: const Color(0xFF1F1408),
          surface: Colors.white,
          onSurface: ink,
        );

    return MaterialApp(
      title: 'Counter Toolkit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFF3EEE5),
        textTheme: ThemeData(
          brightness: Brightness.light,
        ).textTheme.apply(bodyColor: ink, displayColor: ink),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isWide = maxWidth >= 980;
        final quickToolColumns = maxWidth >= 1120
            ? 4
            : maxWidth >= 720
            ? 2
            : 1;

        return Scaffold(
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF5EFE5),
                  Color(0xFFE6F0EC),
                  Color(0xFFF9F6EF),
                ],
                stops: [0.0, 0.58, 1.0],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _HeroBanner(),
                        const SizedBox(height: 20),
                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    _QuickToolsPanel(columns: quickToolColumns),
                                    const SizedBox(height: 20),
                                    const _GuidingPrinciplesPanel(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              const Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    _ShiftEssentialsPanel(),
                                    SizedBox(height: 20),
                                    _BuildRoadmapPanel(),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _QuickToolsPanel(columns: quickToolColumns),
                              const SizedBox(height: 20),
                              const _ShiftEssentialsPanel(),
                              const SizedBox(height: 20),
                              const _BuildRoadmapPanel(),
                              const SizedBox(height: 20),
                              const _GuidingPrinciplesPanel(),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: const Color(0xFF133A39),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _HeroChip(
                label: 'Postal counter workspace',
                background: Color(0x24FFFFFF),
                foreground: Color(0xFFF8F4EC),
              ),
              _HeroChip(
                label: 'Initial scaffold',
                background: Color(0xFFF0C177),
                foreground: Color(0xFF251506),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Counter Toolkit',
            style: textTheme.displaySmall?.copyWith(
              color: const Color(0xFFF9F4EB),
              fontWeight: FontWeight.w800,
              height: 0.95,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'A digital toolkit for people serving customers behind the counter.',
            style: textTheme.titleLarge?.copyWith(
              color: const Color(0xFFE4EEE8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This first cut is set up around the jobs that need to be fast and dependable: tracking items, checking size and weight limits, and guiding customers toward the right service.',
            style: textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFD7E3DE),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _heroPoints
                .map((point) => _PointPill(label: point))
                .toList(growable: false),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.flash_on_rounded,
                  color: Color(0xFFF0C177),
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'First build focus: Track & Trace, size guidance, weight checks, and service comparison.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFFF6F1E8),
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickToolsPanel extends StatelessWidget {
  const _QuickToolsPanel({required this.columns});

  final int columns;

  @override
  Widget build(BuildContext context) {
    return _SurfacePanel(
      eyebrow: 'Planned quick tools',
      title: 'The first workflow slice',
      description:
          'These are the tools worth making fast, obvious, and reliable from the start.',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _quickTools.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: columns == 1
              ? 220
              : columns == 2
              ? 228
              : 184,
        ),
        itemBuilder: (context, index) =>
            _QuickToolCard(data: _quickTools[index]),
      ),
    );
  }
}

class _ShiftEssentialsPanel extends StatelessWidget {
  const _ShiftEssentialsPanel();

  @override
  Widget build(BuildContext context) {
    return _SurfacePanel(
      eyebrow: 'Shift essentials',
      title: 'What the app should help with first',
      description:
          'Keep the day-to-day counter decisions quick to reach and easy to trust.',
      child: Column(
        children: _essentials
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ChecklistRow(data: item),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _BuildRoadmapPanel extends StatelessWidget {
  const _BuildRoadmapPanel();

  @override
  Widget build(BuildContext context) {
    return _SurfacePanel(
      eyebrow: 'Build runway',
      title: 'Suggested first milestones',
      description:
          'A practical path from scaffold to a genuinely useful counter-side app.',
      child: Column(
        children: _roadmap
            .asMap()
            .entries
            .map(
              (entry) => Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key == _roadmap.length - 1 ? 0 : 16,
                ),
                child: _RoadmapStep(
                  stepNumber: entry.key + 1,
                  data: entry.value,
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _GuidingPrinciplesPanel extends StatelessWidget {
  const _GuidingPrinciplesPanel();

  @override
  Widget build(BuildContext context) {
    return _SurfacePanel(
      eyebrow: 'Design guardrails',
      title: 'A toolkit that earns its space',
      description:
          'The product should feel calm under pressure and useful in a busy queue.',
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: _principles
            .map(
              (principle) =>
                  SizedBox(width: 220, child: _PrincipleCard(data: principle)),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _SurfacePanel extends StatelessWidget {
  const _SurfacePanel({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE3DDD4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: textTheme.labelLarge?.copyWith(
              letterSpacing: 1.2,
              color: const Color(0xFF7B6C59),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: textTheme.bodyLarge?.copyWith(
              height: 1.45,
              color: const Color(0xFF5B6563),
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _QuickToolCard extends StatelessWidget {
  const _QuickToolCard({required this.data});

  final _QuickTool data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: data.accent.withValues(alpha: 0.18)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [data.accent.withValues(alpha: 0.10), Colors.white],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: data.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(data.icon, color: data.accent),
          ),
          const Spacer(),
          Text(
            data.title,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            data.subtitle,
            style: textTheme.bodyMedium?.copyWith(
              height: 1.45,
              color: const Color(0xFF576260),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.data});

  final _BulletItem data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2EA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: data.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: data.accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5E6765),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoadmapStep extends StatelessWidget {
  const _RoadmapStep({required this.stepNumber, required this.data});

  final int stepNumber;
  final _RoadmapItem data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF0F5B57),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$stepNumber',
            style: textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                data.subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5C6664),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrincipleCard extends StatelessWidget {
  const _PrincipleCard({required this.data});

  final _Principle data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F2),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4DDD3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, color: data.accent),
          const SizedBox(height: 14),
          Text(
            data.title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            data.subtitle,
            style: textTheme.bodyMedium?.copyWith(
              height: 1.45,
              color: const Color(0xFF5D6664),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PointPill extends StatelessWidget {
  const _PointPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x1FFFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x29FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: Color(0xFFF0C177),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFFF5EFE7),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTool {
  const _QuickTool({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
}

class _BulletItem {
  const _BulletItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
}

class _RoadmapItem {
  const _RoadmapItem({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

class _Principle {
  const _Principle({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
}

const _heroPoints = [
  'Tracking at a glance',
  'Limits without guesswork',
  'Counter-side reference',
];

const _quickTools = [
  _QuickTool(
    title: 'Track & Trace',
    subtitle:
        'Pull up parcel progress quickly while the customer is in front of you.',
    icon: Icons.route_outlined,
    accent: Color(0xFF0F5B57),
  ),
  _QuickTool(
    title: 'Size Guide',
    subtitle:
        'Check large letter, small parcel, and awkward-format thresholds in seconds.',
    icon: Icons.straighten_outlined,
    accent: Color(0xFFB0653B),
  ),
  _QuickTool(
    title: 'Weight Limits',
    subtitle: 'Confirm service cut-offs before you commit to the wrong option.',
    icon: Icons.scale_outlined,
    accent: Color(0xFF3B6C9C),
  ),
  _QuickTool(
    title: 'Service Finder',
    subtitle:
        'Guide customers toward the right mix of speed, signature, and tracking.',
    icon: Icons.rule_folder_outlined,
    accent: Color(0xFF7A5BA8),
  ),
];

const _essentials = [
  _BulletItem(
    title: 'Make the common lookup the fastest',
    subtitle:
        'Tracking should be the most direct action on the screen when queues are moving.',
    icon: Icons.flash_on_outlined,
    accent: Color(0xFF0F5B57),
  ),
  _BulletItem(
    title: 'Keep size and weight checks visual',
    subtitle:
        'Counter staff should not have to hunt through dense tables to confirm a limit.',
    icon: Icons.inventory_2_outlined,
    accent: Color(0xFFB0653B),
  ),
  _BulletItem(
    title: 'Support explain-it-to-the-customer moments',
    subtitle:
        'Helpful prompts and comparison language will matter as much as the raw data.',
    icon: Icons.record_voice_over_outlined,
    accent: Color(0xFF3B6C9C),
  ),
];

const _roadmap = [
  _RoadmapItem(
    title: 'Tracking lookup shell',
    subtitle:
        'Start with an input flow and result screen that can become the core daily utility.',
  ),
  _RoadmapItem(
    title: 'Size and weight reference tools',
    subtitle:
        'Turn the common limits into fast visual checks instead of manual interpretation.',
  ),
  _RoadmapItem(
    title: 'Service comparison prompts',
    subtitle:
        'Help staff explain options confidently when customers are choosing between services.',
  ),
  _RoadmapItem(
    title: 'Counter-side reference extras',
    subtitle:
        'Add the small daily helpers that save time once the core flows are solid.',
  ),
];

const _principles = [
  _Principle(
    title: 'Fast under pressure',
    subtitle: 'The right answer should be within one or two obvious taps.',
    icon: Icons.speed_outlined,
    accent: Color(0xFF0F5B57),
  ),
  _Principle(
    title: 'Plain language',
    subtitle:
        'The UI should help staff explain a choice, not just expose data.',
    icon: Icons.chat_bubble_outline_rounded,
    accent: Color(0xFFB0653B),
  ),
  _Principle(
    title: 'Trustworthy details',
    subtitle:
        'Limits, statuses, and prompts need to feel dependable enough for live counter use.',
    icon: Icons.verified_outlined,
    accent: Color(0xFF3B6C9C),
  ),
];
