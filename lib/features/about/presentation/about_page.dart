import 'package:counter_toolkit/app/app_metadata.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5EFE5), Color(0xFFE6F0EC), Color(0xFFF9F6EF)],
            stops: [0.0, 0.58, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF133A39),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            appVersionLabel,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'About $appName',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'A working toolkit for people serving customers behind the counter. The aim is to reduce queue friction by turning common decisions into fast, reliable actions.',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF495351),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _AboutPanel(
                      eyebrow: 'Purpose',
                      title: 'Built around live counter work',
                      description:
                          'Counter Toolkit is not meant to feel like a brochure app. It is a queue-side helper focused on practical moments such as parcel tracking, exact postage make-up, and the next few checks a clerk reaches for repeatedly.',
                      child: _AboutBulletList(
                        items: [
                          'Speed at counter matters more than feature count.',
                          'The interface should reduce thinking, not add to it.',
                          'Setup and stock controls should stay in the background until needed.',
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _AboutPanel(
                      eyebrow: 'Live tools',
                      title: 'What is in the app today',
                      description:
                          'The current release already supports two working workflows that can be opened directly from the home screen.',
                      child: _AboutFeatureGrid(),
                    ),
                    const SizedBox(height: 20),
                    const _AboutPanel(
                      eyebrow: 'Design',
                      title: 'How the app should feel',
                      description:
                          'Every screen should stay calm and operational under pressure, especially on a busy counter.',
                      child: _AboutPillWrap(
                        labels: [
                          'Fast under pressure',
                          'Plain language',
                          'Colour recognition',
                          'Trustworthy details',
                          'Background setup',
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _AboutPanel(
                      eyebrow: 'Roadmap',
                      title: 'Likely next steps',
                      description:
                          'The broader toolkit can grow around the same practical pattern as the live tools.',
                      child: _AboutBulletList(
                        items: [
                          'Connect Track & Trace to a live backend.',
                          'Add size and weight reference tools.',
                          'Improve saved stock and picked-state memory for stamps.',
                          'Add service comparison prompts for customer conversations.',
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _AboutPanel(
                      eyebrow: 'Version',
                      title: 'Current build',
                      description:
                          'Use this when checking what is installed on a device or confirming a test build.',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _VersionTile(
                            label: appVersionDisplay,
                            caption: 'App version shown in the interface',
                          ),
                          const SizedBox(height: 12),
                          const _VersionTile(
                            label:
                                'iPhone installs should match the latest committed build',
                            caption:
                                'If a device looks wrong, reinstall the app so the build and UI line up again.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutPanel extends StatelessWidget {
  const _AboutPanel({
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
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              letterSpacing: 1.2,
              color: const Color(0xFF7B6C59),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.45,
              color: const Color(0xFF5B6563),
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _AboutBulletList extends StatelessWidget {
  const _AboutBulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: item == items.last ? 0 : 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.circle,
                      size: 8,
                      color: Color(0xFF0F5B57),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF495351),
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _AboutFeatureGrid extends StatelessWidget {
  const _AboutFeatureGrid();

  @override
  Widget build(BuildContext context) {
    const features = [
      (
        title: 'Track & Trace',
        body:
            'Provider-aware parcel lookups for quick customer-facing status checks.',
      ),
      (
        title: 'Best Fit Stamps',
        body:
            'Exact-postage combinations ranked around realistic stamp picking from the book.',
      ),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: features
          .map(
            (feature) => SizedBox(
              width: 280,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F2EA),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feature.body,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5B6563),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _AboutPillWrap extends StatelessWidget {
  const _AboutPillWrap({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: labels
          .map(
            (label) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F2EA),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _VersionTile extends StatelessWidget {
  const _VersionTile({required this.label, required this.caption});

  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2EA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            caption,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5B6563),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
