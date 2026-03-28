import 'package:counter_toolkit/features/stamps/domain/best_fit_stamp_solver.dart';
import 'package:counter_toolkit/features/stamps/presentation/stamp_calculator_page.dart';
import 'package:counter_toolkit/features/tracking/domain/tracking_service.dart';
import 'package:counter_toolkit/features/tracking/presentation/tracking_lookup_page.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.trackingService,
    required this.stampSolver,
  });

  final TrackingService trackingService;
  final BestFitStampSolver stampSolver;

  void _openTracking(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TrackingLookupPage(service: trackingService),
      ),
    );
  }

  void _openStamps(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StampCalculatorPage(solver: stampSolver),
      ),
    );
  }

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
                        _HeroBanner(
                          onOpenTracking: () => _openTracking(context),
                          onOpenStamps: () => _openStamps(context),
                        ),
                        const SizedBox(height: 20),
                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    _QuickToolsPanel(
                                      columns: quickToolColumns,
                                      onOpenTracking: () =>
                                          _openTracking(context),
                                      onOpenStamps: () => _openStamps(context),
                                    ),
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
                              _QuickToolsPanel(
                                columns: quickToolColumns,
                                onOpenTracking: () => _openTracking(context),
                                onOpenStamps: () => _openStamps(context),
                              ),
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
  const _HeroBanner({required this.onOpenTracking, required this.onOpenStamps});

  final VoidCallback onOpenTracking;
  final VoidCallback onOpenStamps;

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
                label: 'Two tools live',
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
            'The toolkit now has two live counter workflows: provider-aware Track & Trace and a colour-led best-fit stamp picker for exact postage make-up.',
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
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 760;

              if (isNarrow) {
                return Column(
                  children: [
                    _HeroCallout(textTheme: textTheme),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _HeroButton(
                          onPressed: onOpenTracking,
                          icon: Icons.travel_explore_rounded,
                          label: 'Open Track & Trace',
                          background: const Color(0xFFF0C177),
                          foreground: const Color(0xFF251506),
                        ),
                        _HeroButton(
                          onPressed: onOpenStamps,
                          icon: Icons.style_rounded,
                          label: 'Open Best Fit Stamps',
                          background: const Color(0xFFE6F0EC),
                          foreground: const Color(0xFF113331),
                        ),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _HeroCallout(textTheme: textTheme)),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 270,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HeroButton(
                          onPressed: onOpenTracking,
                          icon: Icons.travel_explore_rounded,
                          label: 'Open Track & Trace',
                          background: const Color(0xFFF0C177),
                          foreground: const Color(0xFF251506),
                        ),
                        const SizedBox(height: 12),
                        _HeroButton(
                          onPressed: onOpenStamps,
                          icon: Icons.style_rounded,
                          label: 'Open Best Fit Stamps',
                          background: const Color(0xFFE6F0EC),
                          foreground: const Color(0xFF113331),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeroCallout extends StatelessWidget {
  const _HeroCallout({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              'Open the live tools to preview both parcel lookups and the exact-postage stamp picker a clerk can use mid-queue.',
              style: textTheme.bodyLarge?.copyWith(
                color: const Color(0xFFF6F1E8),
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      ),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _QuickToolsPanel extends StatelessWidget {
  const _QuickToolsPanel({
    required this.columns,
    required this.onOpenTracking,
    required this.onOpenStamps,
  });

  final int columns;
  final VoidCallback onOpenTracking;
  final VoidCallback onOpenStamps;

  @override
  Widget build(BuildContext context) {
    return _SurfacePanel(
      eyebrow: 'Current toolset',
      title: 'Live tools and the next queue',
      description:
          'Track & Trace and Best Fit Stamps are both interactive now. The remaining tiles stay visible as the next planned helpers.',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _quickTools.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: columns == 1
              ? 232
              : columns == 2
              ? 236
              : 192,
        ),
        itemBuilder: (context, index) => _QuickToolCard(
          data: _quickTools[index],
          onTap: switch (_quickTools[index].routeKey) {
            'tracking' => onOpenTracking,
            'stamps' => onOpenStamps,
            _ => null,
          },
        ),
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
      title: 'Suggested next milestones',
      description:
          'Now that two real tools are in place, the rest of the toolkit can grow around the same counter-side patterns.',
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
  const _QuickToolCard({required this.data, required this.onTap});

  final _QuickTool data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final content = Container(
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
          Row(
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: data.isAvailableNow
                      ? const Color(0xFF0F5B57).withValues(alpha: 0.12)
                      : const Color(0xFF7B6C59).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  data.isAvailableNow ? 'Live' : 'Planned',
                  style: textTheme.labelMedium?.copyWith(
                    color: data.isAvailableNow
                        ? const Color(0xFF0F5B57)
                        : const Color(0xFF7B6C59),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
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
          const SizedBox(height: 14),
          Text(
            data.footerLabel,
            style: textTheme.labelLarge?.copyWith(
              color: onTap != null ? data.accent : const Color(0xFF7B6C59),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: content,
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
    required this.footerLabel,
    this.routeKey,
    this.isAvailableNow = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String footerLabel;
  final String? routeKey;
  final bool isAvailableNow;
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
  'Track & Trace working',
  'Best Fit Stamps live',
  'Counter-first language',
];

const _quickTools = [
  _QuickTool(
    title: 'Track & Trace',
    subtitle:
        'Pull up parcel progress quickly while the customer is in front of you.',
    icon: Icons.route_outlined,
    accent: Color(0xFF0F5B57),
    footerLabel: 'Open feature',
    routeKey: 'tracking',
    isAvailableNow: true,
  ),
  _QuickTool(
    title: 'Best Fit Stamps',
    subtitle:
        'Build the quickest exact-postage pick list from the stamp book in front of you.',
    icon: Icons.style_outlined,
    accent: Color(0xFF8D6E63),
    footerLabel: 'Open feature',
    routeKey: 'stamps',
    isAvailableNow: true,
  ),
  _QuickTool(
    title: 'Size Guide',
    subtitle:
        'Check large letter, small parcel, and awkward-format thresholds in seconds.',
    icon: Icons.straighten_outlined,
    accent: Color(0xFFB0653B),
    footerLabel: 'Next planned tool',
  ),
  _QuickTool(
    title: 'Weight Limits',
    subtitle: 'Confirm service cut-offs before you commit to the wrong option.',
    icon: Icons.scale_outlined,
    accent: Color(0xFF3B6C9C),
    footerLabel: 'Planned after size guide',
  ),
  _QuickTool(
    title: 'Service Finder',
    subtitle:
        'Guide customers toward the right mix of speed, signature, and tracking.',
    icon: Icons.rule_folder_outlined,
    accent: Color(0xFF7A5BA8),
    footerLabel: 'Planned decision support',
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
    title: 'Keep stamp picking visual',
    subtitle:
        'Exact postage make-up should feel like a colour-led pick list, not a maths exercise.',
    icon: Icons.style_outlined,
    accent: Color(0xFF8D6E63),
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
    title: 'Connect Track & Trace to a backend',
    subtitle:
        'Replace the mock provider with a server-backed adapter for Royal Mail or UPU-style lookups.',
  ),
  _RoadmapItem(
    title: 'Size and weight reference tools',
    subtitle:
        'Turn the common limits into fast visual checks instead of manual interpretation.',
  ),
  _RoadmapItem(
    title: 'Persist the stamp workflow',
    subtitle:
        'Add picked-state memory, saved exclusions, and tighter counter-side explanations around the stamp recommendations.',
  ),
  _RoadmapItem(
    title: 'Service comparison prompts',
    subtitle:
        'Help staff explain options confidently when customers are choosing between services.',
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
