import 'package:counter_toolkit/features/tracking/domain/tracking_models.dart';
import 'package:counter_toolkit/features/tracking/domain/tracking_service.dart';
import 'package:flutter/material.dart';

class TrackingLookupPage extends StatefulWidget {
  const TrackingLookupPage({super.key, required this.service});

  final TrackingService service;

  @override
  State<TrackingLookupPage> createState() => _TrackingLookupPageState();
}

class _TrackingLookupPageState extends State<TrackingLookupPage> {
  late final TextEditingController _controller;
  TrackingLookupMode _selectedMode = TrackingLookupMode.auto;
  bool _isLoading = false;
  String? _inputError;
  TrackingLookupOutcome? _outcome;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.service.sampleReferences.first,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runLookup([String? overrideReference]) async {
    final raw = overrideReference ?? _controller.text;
    final inputError = validateTrackingReference(raw);

    if (inputError != null) {
      setState(() {
        _inputError = inputError;
      });
      return;
    }

    final normalised = normaliseTrackingReference(raw);
    _controller.value = TextEditingValue(
      text: normalised,
      selection: TextSelection.collapsed(offset: normalised.length),
    );

    setState(() {
      _isLoading = true;
      _inputError = null;
    });

    final outcome = await widget.service.lookup(
      TrackingLookupRequest(reference: normalised, mode: _selectedMode),
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _outcome = outcome;
      _isLoading = false;
    });
  }

  void _loadSample(String reference) {
    _controller.value = TextEditingValue(
      text: reference,
      selection: TextSelection.collapsed(offset: reference.length),
    );
    _runLookup(reference);
  }

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PageHeader(onBack: () => Navigator.of(context).pop()),
                        const SizedBox(height: 20),
                        _LookupPanel(
                          controller: _controller,
                          sampleReferences: widget.service.sampleReferences,
                          supportedModes: widget.service.supportedModes,
                          selectedMode: _selectedMode,
                          isLoading: _isLoading,
                          inputError: _inputError,
                          onSubmit: _runLookup,
                          onLoadSample: _loadSample,
                          onModeChanged: (mode) {
                            setState(() {
                              _selectedMode = mode;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        if (_outcome == null)
                          const _IdlePanel()
                        else if (_outcome!.found)
                          _ResultPanel(outcome: _outcome!)
                        else
                          _NotFoundPanel(outcome: _outcome!),
                        const SizedBox(height: 20),
                        _IntegrationNotesPanel(
                          providerGuides: widget.service.providerGuides,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF133A39),
        borderRadius: BorderRadius.circular(28),
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
          IconButton.filledTonal(
            onPressed: onBack,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _HeaderChip(
                label: 'First feature live',
                background: Color(0xFFF0C177),
                foreground: Color(0xFF251506),
              ),
              _HeaderChip(
                label: 'Provider-aware routing',
                background: Color(0x24FFFFFF),
                foreground: Color(0xFFF8F4EC),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Track & Trace',
            style: textTheme.displaySmall?.copyWith(
              color: const Color(0xFFF9F4EB),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This screen now supports auto-routing and provider-specific demo modes, with the lookup boundary ready for a real backend later.',
            style: textTheme.titleLarge?.copyWith(
              color: const Color(0xFFE4EEE8),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _LookupPanel extends StatelessWidget {
  const _LookupPanel({
    required this.controller,
    required this.sampleReferences,
    required this.supportedModes,
    required this.selectedMode,
    required this.isLoading,
    required this.inputError,
    required this.onSubmit,
    required this.onLoadSample,
    required this.onModeChanged,
  });

  final TextEditingController controller;
  final List<String> sampleReferences;
  final List<TrackingLookupMode> supportedModes;
  final TrackingLookupMode selectedMode;
  final bool isLoading;
  final String? inputError;
  final Future<void> Function([String? overrideReference]) onSubmit;
  final ValueChanged<String> onLoadSample;
  final ValueChanged<TrackingLookupMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.sizeOf(context).width >= 820;

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
            'LOOKUP'.toUpperCase(),
            style: textTheme.labelLarge?.copyWith(
              letterSpacing: 1.2,
              color: const Color(0xFF7B6C59),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search by tracking reference',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start with a sample number or paste a real one later. Choose Auto route or lock the lookup to a specific provider path.',
            style: textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF5B6563),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Route mode',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: supportedModes
                .map(
                  (mode) => ChoiceChip(
                    label: Text(trackingLookupModeLabel(mode)),
                    selected: mode == selectedMode,
                    onSelected: (_) => onModeChanged(mode),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 12),
          Text(
            trackingLookupModeDescription(selectedMode),
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5B6563),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildField()),
                const SizedBox(width: 14),
                _buildSearchButton(),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildField(),
                const SizedBox(height: 14),
                _buildSearchButton(fullWidth: true),
              ],
            ),
          if (isLoading) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
          ],
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: sampleReferences
                .map(
                  (reference) => ActionChip(
                    label: Text(reference),
                    onPressed: () => onLoadSample(reference),
                    avatar: const Icon(Icons.bolt_rounded, size: 18),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  Widget _buildField() {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSubmit(),
      decoration: InputDecoration(
        labelText: 'Tracking number',
        hintText: 'Example: AB123456789GB',
        errorText: inputError,
        prefixIcon: const Icon(Icons.search_rounded),
      ),
    );
  }

  Widget _buildSearchButton({bool fullWidth = false}) {
    return SizedBox(
      width: fullWidth ? double.infinity : 190,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onSubmit,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        ),
        icon: const Icon(Icons.travel_explore_rounded),
        label: const Text('Look up'),
      ),
    );
  }
}

class _IdlePanel extends StatelessWidget {
  const _IdlePanel();

  @override
  Widget build(BuildContext context) {
    return _ContentShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F5B57).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.route_outlined,
                  color: Color(0xFF0F5B57),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Try a sample lookup to preview the flow that will eventually sit on top of a live API.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'This first slice proves out the customer-facing lookup journey, result summary, and event timeline before we connect any provider credentials.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF5B6563),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotFoundPanel extends StatelessWidget {
  const _NotFoundPanel({required this.outcome});

  final TrackingLookupOutcome outcome;

  @override
  Widget build(BuildContext context) {
    return _ContentShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RouteBanner(route: outcome.route),
          const SizedBox(height: 18),
          Text(
            'No stored journey for ${outcome.searchedReference}',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            outcome.message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF5B6563),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          const _InfoBanner(
            icon: Icons.layers_outlined,
            title: 'Why this is still useful',
            body:
                'The screen, validation, result state, and provider abstraction are already in place. The next job is swapping the mock service for a real adapter behind a backend.',
          ),
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.outcome});

  final TrackingLookupOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final item = outcome.item!;
    final isWide = MediaQuery.sizeOf(context).width >= 960;

    return Column(
      children: [
        _ContentShell(
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _SummaryColumn(item: item, outcome: outcome),
                    ),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: _MetaColumn(item: item)),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryColumn(item: item, outcome: outcome),
                    const SizedBox(height: 20),
                    _MetaColumn(item: item),
                  ],
                ),
        ),
        const SizedBox(height: 20),
        _ContentShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tracking timeline',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: item.events
                    .map(
                      (event) => Padding(
                        padding: EdgeInsets.only(
                          bottom: event == item.events.last ? 0 : 14,
                        ),
                        child: _TimelineEvent(event: event),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  const _SummaryColumn({required this.item, required this.outcome});

  final TrackingItem item;
  final TrackingLookupOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final stageColor = _stageColor(item.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RouteBanner(route: outcome.route, compact: true),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: stageColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            _stageLabel(item.status),
            style: textTheme.labelLarge?.copyWith(
              color: stageColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          item.reference,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.summary,
          style: textTheme.titleMedium?.copyWith(
            color: const Color(0xFF50605E),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Pill(label: item.serviceName, icon: Icons.local_shipping_outlined),
            _Pill(
              label: _networkLabel(item.network),
              icon: Icons.public_rounded,
            ),
            if (item.requiresSignature)
              const _Pill(
                label: 'Signature expected',
                icon: Icons.draw_outlined,
              ),
            if (item.isInternational)
              const _Pill(
                label: 'International item',
                icon: Icons.language_rounded,
              ),
          ],
        ),
        const SizedBox(height: 20),
        _InfoBanner(
          icon: Icons.cloud_queue_outlined,
          title: 'Current data source',
          body: outcome.message,
        ),
      ],
    );
  }
}

class _MetaColumn extends StatelessWidget {
  const _MetaColumn({required this.item});

  final TrackingItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetaRow(label: 'Destination', value: item.destination),
        const SizedBox(height: 14),
        _MetaRow(label: 'Latest location', value: item.latestLocation),
        const SizedBox(height: 14),
        _MetaRow(
          label: 'Last updated',
          value: _formatDateTime(item.lastUpdated),
        ),
        const SizedBox(height: 14),
        _MetaRow(
          label: 'Delivery estimate',
          value: item.deliveryEstimate == null
              ? 'Not available'
              : _formatDateTime(item.deliveryEstimate!),
        ),
        if (item.notices.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Counter notes',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Column(
            children: item.notices
                .map(
                  (notice) => Padding(
                    padding: EdgeInsets.only(
                      bottom: notice == item.notices.last ? 0 : 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: Color(0xFF0F5B57),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            notice,
                            style: textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF5B6563),
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ],
    );
  }
}

class _TimelineEvent extends StatelessWidget {
  const _TimelineEvent({required this.event});

  final TrackingEvent event;

  @override
  Widget build(BuildContext context) {
    final stageColor = _stageColor(event.stage);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: stageColor,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 72,
              color: stageColor.withValues(alpha: 0.18),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF8F2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE3DDD4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  event.detail,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5B6563),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _TinyPill(label: event.location),
                    _TinyPill(label: _formatDateTime(event.timestamp)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IntegrationNotesPanel extends StatelessWidget {
  const _IntegrationNotesPanel({required this.providerGuides});

  final List<TrackingProviderGuide> providerGuides;

  @override
  Widget build(BuildContext context) {
    return _ContentShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Integration next steps',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          const _InfoBanner(
            icon: Icons.account_tree_outlined,
            title: 'Recommended shape',
            body:
                'App -> your backend -> provider adapter. Keep API credentials and provider-specific request signing out of the mobile app.',
          ),
          const SizedBox(height: 14),
          const _InfoBanner(
            icon: Icons.swap_horiz_rounded,
            title: 'Provider swap point',
            body:
                'Replace MockTrackingService with a backend-backed service that maps Royal Mail or UPU responses into TrackingItem and TrackingEvent.',
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: providerGuides
                .map((guide) => _ProviderGuideCard(guide: guide))
                .toList(growable: false),
          ),
          const SizedBox(height: 14),
          const _InfoBanner(
            icon: Icons.rule_rounded,
            title: 'Operational caution',
            body:
                'Counter staff need plain-language explanations, not raw event codes. Keep the mapping layer responsible for turning provider events into counter-friendly status text.',
          ),
        ],
      ),
    );
  }
}

class _ContentShell extends StatelessWidget {
  const _ContentShell({required this.child});

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
      child: child,
    );
  }
}

class _RouteBanner extends StatelessWidget {
  const _RouteBanner({required this.route, this.compact = false});

  final TrackingLookupRoute route;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final readinessColor = _readinessColor(route.readiness);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 16 : 18),
      decoration: BoxDecoration(
        color: readinessColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: readinessColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _TinyStatusPill(
                label:
                    'Requested: ${trackingLookupModeLabel(route.requestedMode)}',
                color: const Color(0xFF0F5B57),
              ),
              _TinyStatusPill(
                label:
                    'Resolved: ${trackingLookupModeLabel(route.resolvedMode)}',
                color: readinessColor,
              ),
              _TinyStatusPill(
                label:
                    'State: ${trackingIntegrationReadinessLabel(route.readiness)}',
                color: readinessColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            route.reason,
            style: textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF425150),
              height: 1.45,
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 10),
            Text(
              trackingIntegrationReadinessDescription(route.readiness),
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5B6563),
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2EA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF0F5B57).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0F5B57), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5B6563),
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

class _ProviderGuideCard extends StatelessWidget {
  const _ProviderGuideCard({required this.guide});

  final TrackingProviderGuide guide;

  @override
  Widget build(BuildContext context) {
    final readinessColor = _readinessColor(guide.readiness);

    return SizedBox(
      width: 240,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE3DDD4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TinyStatusPill(
              label: trackingIntegrationReadinessLabel(guide.readiness),
              color: readinessColor,
            ),
            const SizedBox(height: 14),
            Text(
              guide.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              guide.summary,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5B6563),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              guide.focus,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF0F5B57),
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
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

class _TinyStatusPill extends StatelessWidget {
  const _TinyStatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2EA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0F5B57)),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _TinyPill extends StatelessWidget {
  const _TinyPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE3DDD4)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: const Color(0xFF5B6563),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 118,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF7B6C59),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

String _stageLabel(TrackingStage stage) {
  switch (stage) {
    case TrackingStage.accepted:
      return 'Accepted';
    case TrackingStage.inTransit:
      return 'In transit';
    case TrackingStage.outForDelivery:
      return 'Out for delivery';
    case TrackingStage.delivered:
      return 'Delivered';
    case TrackingStage.held:
      return 'Held';
    case TrackingStage.issue:
      return 'Attention needed';
  }
}

Color _stageColor(TrackingStage stage) {
  switch (stage) {
    case TrackingStage.accepted:
      return const Color(0xFF59728E);
    case TrackingStage.inTransit:
      return const Color(0xFF0F5B57);
    case TrackingStage.outForDelivery:
      return const Color(0xFF3B6C9C);
    case TrackingStage.delivered:
      return const Color(0xFF2F7B4A);
    case TrackingStage.held:
      return const Color(0xFFB0653B);
    case TrackingStage.issue:
      return const Color(0xFF9C3D2A);
  }
}

Color _readinessColor(TrackingIntegrationReadiness readiness) {
  switch (readiness) {
    case TrackingIntegrationReadiness.demoReady:
      return const Color(0xFF2F7B4A);
    case TrackingIntegrationReadiness.backendNext:
      return const Color(0xFF0F5B57);
    case TrackingIntegrationReadiness.accessControlled:
      return const Color(0xFFB0653B);
  }
}

String _networkLabel(TrackingNetwork network) {
  switch (network) {
    case TrackingNetwork.royalMail:
      return 'Royal Mail';
    case TrackingNetwork.upu:
      return 'UPU-style';
    case TrackingNetwork.parcelForce:
      return 'Parcelforce';
  }
}

String _formatDateTime(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.day} ${months[value.month - 1]} ${value.year}, $hour:$minute';
}
