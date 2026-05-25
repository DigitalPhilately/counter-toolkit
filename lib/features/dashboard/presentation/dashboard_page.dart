import 'package:counter_toolkit/app/app_metadata.dart';
import 'package:counter_toolkit/features/about/presentation/about_page.dart';
import 'package:counter_toolkit/features/stamps/domain/best_fit_stamp_solver.dart';
import 'package:counter_toolkit/features/stamps/presentation/stamp_calculator_page.dart';
import 'package:counter_toolkit/features/tracking/domain/tracking_service.dart';
import 'package:counter_toolkit/features/tracking/presentation/tracking_lookup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.trackingService,
    required this.stampSolver,
  });

  final TrackingService trackingService;
  final BestFitStampSolver stampSolver;

  void _openTracking(BuildContext context) {
    Feedback.forTap(context);
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TrackingLookupPage(service: trackingService),
      ),
    );
  }

  void _openStamps(BuildContext context) {
    Feedback.forTap(context);
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StampCalculatorPage(solver: stampSolver),
      ),
    );
  }

  void _openAbout(BuildContext context) {
    Feedback.forTap(context);
    HapticFeedback.selectionClick();
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AboutPage()));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isWide = maxWidth >= 980;
        final zoneColumns = maxWidth >= 1120
            ? 3
            : maxWidth >= 760
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
                          onOpenAbout: () => _openAbout(context),
                          versionLabel: appVersionLabel,
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
                                    _ProductZonesPanel(
                                      columns: zoneColumns,
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
                              _ProductZonesPanel(
                                columns: zoneColumns,
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
  const _HeroBanner({
    required this.onOpenTracking,
    required this.onOpenStamps,
    required this.onOpenAbout,
    required this.versionLabel,
  });

  final VoidCallback onOpenTracking;
  final VoidCallback onOpenStamps;
  final VoidCallback onOpenAbout;
  final String versionLabel;

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
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _HeroChip(
                label: versionLabel,
                background: const Color(0xFFF0C177),
                foreground: const Color(0xFF251506),
              ),
              const _HeroChip(
                label: 'Two tools live',
                background: Color(0x24FFFFFF),
                foreground: Color(0xFFF8F4EC),
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
            'Choose a live tool for the current queue.',
            style: textTheme.titleLarge?.copyWith(
              color: const Color(0xFFE4EEE8),
              fontWeight: FontWeight.w600,
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
                    _HeroCallout(
                      textTheme: textTheme,
                      versionLabel: versionLabel,
                    ),
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
                        _HeroButton(
                          onPressed: onOpenAbout,
                          icon: Icons.info_outline_rounded,
                          label: 'About',
                          background: const Color(0x1FFFFFFF),
                          foreground: const Color(0xFFF8F4EC),
                        ),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _HeroCallout(
                      textTheme: textTheme,
                      versionLabel: versionLabel,
                    ),
                  ),
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
                        const SizedBox(height: 12),
                        _HeroButton(
                          onPressed: onOpenAbout,
                          icon: Icons.info_outline_rounded,
                          label: 'About',
                          background: const Color(0x1FFFFFFF),
                          foreground: const Color(0xFFF8F4EC),
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
  const _HeroCallout({required this.textTheme, required this.versionLabel});

  final TextTheme textTheme;
  final String versionLabel;

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
              '$versionLabel is ready. Start with a parcel lookup or build an exact stamp pick for the customer in front of you.',
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

class _ProductZonesPanel extends StatelessWidget {
  const _ProductZonesPanel({
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
      eyebrow: 'Product zones',
      title: 'Choose the counter area',
      description:
          'Tools are grouped by the product family a clerk reaches for first: Mail, Travel, and Banking.',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _toolZones.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: columns == 1
              ? 460
              : columns == 2
              ? 430
              : 468,
        ),
        itemBuilder: (context, index) => _ToolZoneCard(
          zone: _toolZones[index],
          onOpenTracking: onOpenTracking,
          onOpenStamps: onOpenStamps,
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
      title: 'Fast actions for a busy counter',
      description: 'The home screen keeps repeated queue tasks close to hand.',
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
      eyebrow: 'Upcoming tools',
      title: 'Coming next',
      description:
          'These items are not active buttons yet, but they define the next practical tools to add.',
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
      title: 'Counter operating notes',
      description:
          'Short reminders for how each tool should behave when the queue is moving.',
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

class _ToolZoneCard extends StatelessWidget {
  const _ToolZoneCard({
    required this.zone,
    required this.onOpenTracking,
    required this.onOpenStamps,
  });

  final _ToolZone zone;
  final VoidCallback onOpenTracking;
  final VoidCallback onOpenStamps;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: zone.accent.withValues(alpha: 0.18)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [zone.accent.withValues(alpha: 0.08), Colors.white],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: zone.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(zone.icon, color: zone.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone.title,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      zone.subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        height: 1.35,
                        color: const Color(0xFF5B6563),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: zone.tools.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final tool = zone.tools[index];
                return _ZoneToolRow(
                  tool: tool,
                  onTap: switch (tool.routeKey) {
                    'tracking' => onOpenTracking,
                    'stamps' => onOpenStamps,
                    _ => null,
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            zone.footer,
            style: textTheme.labelLarge?.copyWith(
              color: zone.accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneToolRow extends StatelessWidget {
  const _ZoneToolRow({required this.tool, required this.onTap});

  final _QuickTool tool;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final statusColor = tool.isAvailableNow
        ? const Color(0xFF0F5B57)
        : const Color(0xFF7B6C59);
    final row = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3DDD4)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tool.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(tool.icon, color: tool.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tool.title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  tool.subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF5B6563),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tool.isAvailableNow ? 'Live' : 'Soon',
                style: textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                onTap == null
                    ? Icons.lock_clock_outlined
                    : Icons.arrow_forward_rounded,
                size: 18,
                color: statusColor,
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) {
      return row;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: row,
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

class _ToolZone {
  const _ToolZone({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.footer,
    required this.tools,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String footer;
  final List<_QuickTool> tools;
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
  'Parcel lookup',
  'Exact stamp make-up',
  'Counter workflow',
];

const _mailTools = [
  _QuickTool(
    title: 'Track & Trace',
    subtitle: 'Check parcel progress and current status.',
    icon: Icons.route_outlined,
    accent: Color(0xFF0F5B57),
    footerLabel: 'Open feature',
    routeKey: 'tracking',
    isAvailableNow: true,
  ),
  _QuickTool(
    title: 'Best Fit Stamps',
    subtitle: 'Make up exact postage from the stamp book.',
    icon: Icons.style_outlined,
    accent: Color(0xFF8D6E63),
    footerLabel: 'Open feature',
    routeKey: 'stamps',
    isAvailableNow: true,
  ),
  _QuickTool(
    title: 'Parcel Sizer',
    subtitle: 'Use dimensions and weight to find the format.',
    icon: Icons.straighten_outlined,
    accent: Color(0xFFB0653B),
    footerLabel: 'Coming soon',
  ),
  _QuickTool(
    title: 'Service Finder',
    subtitle: 'Compare speed, tracking, and signature needs.',
    icon: Icons.rule_folder_outlined,
    accent: Color(0xFF7A5BA8),
    footerLabel: 'Coming soon',
  ),
];

const _travelTools = [
  _QuickTool(
    title: 'Bureau de Change',
    subtitle: 'Foreign currency reference and handover prompts.',
    icon: Icons.currency_exchange_rounded,
    accent: Color(0xFF3B6C9C),
    footerLabel: 'Coming soon',
  ),
  _QuickTool(
    title: 'Travel Money Card',
    subtitle: 'Checklist for card loads, reloads, and customer notes.',
    icon: Icons.credit_card_rounded,
    accent: Color(0xFF4E6B3F),
    footerLabel: 'Coming soon',
  ),
  _QuickTool(
    title: 'Travel Checklist',
    subtitle: 'Quick prompts for ID, rates, fees, and receipts.',
    icon: Icons.flight_takeoff_rounded,
    accent: Color(0xFF7A5BA8),
    footerLabel: 'Coming soon',
  ),
];

const _bankingTools = [
  _QuickTool(
    title: 'Banking Workspace',
    subtitle: 'Reserved for future banking counter tools.',
    icon: Icons.account_balance_outlined,
    accent: Color(0xFF6B5C4A),
    footerLabel: 'To define',
  ),
  _QuickTool(
    title: 'Cash Services',
    subtitle: 'Potential prompts for deposits, withdrawals, and limits.',
    icon: Icons.payments_outlined,
    accent: Color(0xFF0F5B57),
    footerLabel: 'To define',
  ),
  _QuickTool(
    title: 'Customer Checks',
    subtitle: 'Space for future ID, eligibility, and handoff guidance.',
    icon: Icons.fact_check_outlined,
    accent: Color(0xFFB0653B),
    footerLabel: 'To define',
  ),
];

const _toolZones = [
  _ToolZone(
    title: 'Mail',
    subtitle: 'Letters, parcels, stamps, formats, and postal services.',
    icon: Icons.local_shipping_outlined,
    accent: Color(0xFF0F5B57),
    footer: 'Postal tools and parcel workflows',
    tools: _mailTools,
  ),
  _ToolZone(
    title: 'Travel',
    subtitle: 'Foreign currency, travel money, and trip-related prompts.',
    icon: Icons.flight_takeoff_rounded,
    accent: Color(0xFF3B6C9C),
    footer: 'Bureau de Change and travel services',
    tools: _travelTools,
  ),
  _ToolZone(
    title: 'Banking',
    subtitle:
        'A reserved space for banking services once the useful tools are clear.',
    icon: Icons.account_balance_outlined,
    accent: Color(0xFF6B5C4A),
    footer: 'Discovery area',
    tools: _bankingTools,
  ),
];

const _essentials = [
  _BulletItem(
    title: 'Find parcel status',
    subtitle:
        'Open Track & Trace, paste or scan a reference, and read the latest status.',
    icon: Icons.flash_on_outlined,
    accent: Color(0xFF0F5B57),
  ),
  _BulletItem(
    title: 'Make up exact postage',
    subtitle:
        'Enter the required amount and pick the recommended stamp values from the book.',
    icon: Icons.style_outlined,
    accent: Color(0xFF8D6E63),
  ),
  _BulletItem(
    title: 'Explain the next step',
    subtitle:
        'Use short status and service wording that is easy to repeat to a customer.',
    icon: Icons.record_voice_over_outlined,
    accent: Color(0xFF3B6C9C),
  ),
];

const _roadmap = [
  _RoadmapItem(
    title: 'Connect live Track & Trace',
    subtitle:
        'Use approved Royal Mail access so real parcel events can appear in the same lookup flow.',
  ),
  _RoadmapItem(
    title: 'Parcel Sizer',
    subtitle:
        'Show carrier size and weight limits, then let staff enter height, width, depth, and weight to get a format or size guide.',
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
