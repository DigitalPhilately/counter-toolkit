import 'package:counter_toolkit/features/stamps/domain/best_fit_stamp_solver.dart';
import 'package:counter_toolkit/features/stamps/domain/stamp_models.dart';
import 'package:counter_toolkit/features/stamps/presentation/stamp_tile.dart';
import 'package:flutter/material.dart';

class StampCalculatorPage extends StatefulWidget {
  const StampCalculatorPage({super.key, required this.solver});

  final BestFitStampSolver solver;

  @override
  State<StampCalculatorPage> createState() => _StampCalculatorPageState();
}

class _StampCalculatorPageState extends State<StampCalculatorPage> {
  late final TextEditingController _targetController;
  StampCalculatorSettings _settings = const StampCalculatorSettings();
  final Set<int> _pickedValues = <int>{};
  StampCalculationResult? _result;
  String? _inputError;

  @override
  void initState() {
    super.initState();
    _targetController = TextEditingController(text: '10.25');
    _recalculate();
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  void _recalculate() {
    final targetValuePence = _parseTargetValue(_targetController.text);
    if (targetValuePence == null) {
      setState(() {
        _inputError = 'Use a value like 10.25 or 1025.';
      });
      return;
    }

    setState(() {
      _inputError = null;
      _result = widget.solver.calculate(
        targetValuePence: targetValuePence,
        settings: _settings,
        pickedValues: _pickedValues,
      );
    });
  }

  int? _parseTargetValue(String raw) {
    final cleaned = raw.trim().replaceAll('£', '');
    if (cleaned.isEmpty) {
      return null;
    }

    if (RegExp(r'^\d+$').hasMatch(cleaned)) {
      return int.tryParse(cleaned);
    }

    if (RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(cleaned)) {
      final parsed = double.tryParse(cleaned);
      if (parsed == null) {
        return null;
      }
      return (parsed * 100).round();
    }

    return null;
  }

  void _togglePreferNvi(bool value) {
    setState(() {
      _settings = _settings.copyWith(preferNvi: value);
    });
    _recalculate();
  }

  void _toggleHighTariff(bool value) {
    setState(() {
      _settings = _settings.copyWith(excludeHighTariff: value);
    });
    _recalculate();
  }

  void _setExcludedValue(int value, bool excluded) {
    final nextExcluded = Set<int>.from(_settings.excludedValues);
    if (excluded) {
      nextExcluded.add(value);
      _pickedValues.remove(value);
    } else {
      nextExcluded.remove(value);
    }

    setState(() {
      _settings = _settings.copyWith(excludedValues: nextExcluded);
    });
    _recalculate();
  }

  void _togglePickedValue(int value) {
    setState(() {
      if (_pickedValues.contains(value)) {
        _pickedValues.remove(value);
      } else {
        _pickedValues.add(value);
      }
    });
    _recalculate();
  }

  void _clearExclusions() {
    setState(() {
      _settings = _settings.copyWith(excludedValues: <int>{});
    });
    _recalculate();
  }

  Future<void> _openStampDetails(StampLineItem item) async {
    final excluded = _settings.excludedValues.contains(item.stamp.valuePence);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFF8F4EC),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Take ${item.count} stamp${item.count == 1 ? '' : 's'} of ${item.stamp.label}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 620;
                    final tile = StampPickTile(item: item);
                    final details = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailRow(
                          label: 'Colour',
                          value: item.stamp.colourName,
                        ),
                        const SizedBox(height: 10),
                        _DetailRow(label: 'Section', value: item.stamp.group),
                        const SizedBox(height: 10),
                        _DetailRow(
                          label: 'Type',
                          value: stampTypeLabel(item.stamp.type),
                        ),
                        const SizedBox(height: 10),
                        _DetailRow(label: 'Value', value: item.stamp.label),
                      ],
                    );

                    if (!isWide) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [tile, const SizedBox(height: 16), details],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        tile,
                        const SizedBox(width: 16),
                        Expanded(child: details),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                const _SheetHint(
                  icon: Icons.grid_view_rounded,
                  text:
                      'The barcode strip is decorative only. It gives clerks a quick visual match without pretending to scan.',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _togglePickedValue(item.stamp.valuePence);
                        },
                        icon: Icon(
                          _pickedValues.contains(item.stamp.valuePence)
                              ? Icons.undo_rounded
                              : Icons.check_circle_outline_rounded,
                        ),
                        label: Text(
                          _pickedValues.contains(item.stamp.valuePence)
                              ? 'Clear picked'
                              : 'Mark as picked',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: excluded
                            ? null
                            : () {
                                Navigator.of(context).pop();
                                _setExcludedValue(item.stamp.valuePence, true);
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF9C3D2A),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                        label: const Text('Not available'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7F1E5), Color(0xFFE8EFE8), Color(0xFFFBF7F0)],
            stops: [0.0, 0.6, 1.0],
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
                    _HeaderPanel(
                      controller: _targetController,
                      inputError: _inputError,
                      settings: _settings,
                      onBack: () => Navigator.of(context).pop(),
                      onRecalculate: _recalculate,
                      onPreferNviChanged: _togglePreferNvi,
                      onHighTariffChanged: _toggleHighTariff,
                      onClearExclusions: _clearExclusions,
                    ),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: result == null
                          ? const SizedBox.shrink()
                          : result.hasSolution
                          ? _SolutionView(
                              key: ValueKey(result.recommended?.signature),
                              result: result,
                              pickedValues: _pickedValues,
                              onStampTap: _openStampDetails,
                              onClearExcluded: (value) =>
                                  _setExcludedValue(value, false),
                            )
                          : _NoSolutionView(
                              key: ValueKey(result.message),
                              result: result,
                              onClearExclusions: _clearExclusions,
                            ),
                    ),
                    const SizedBox(height: 20),
                    _SupportPanel(result: result),
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

class _HeaderPanel extends StatelessWidget {
  const _HeaderPanel({
    required this.controller,
    required this.inputError,
    required this.settings,
    required this.onBack,
    required this.onRecalculate,
    required this.onPreferNviChanged,
    required this.onHighTariffChanged,
    required this.onClearExclusions,
  });

  final TextEditingController controller;
  final String? inputError;
  final StampCalculatorSettings settings;
  final VoidCallback onBack;
  final VoidCallback onRecalculate;
  final ValueChanged<bool> onPreferNviChanged;
  final ValueChanged<bool> onHighTariffChanged;
  final VoidCallback onClearExclusions;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final chips = <Widget>[
      _StatusChip(
        label: settings.preferNvi ? 'Prefer NVI' : 'NVI neutral',
        accent: const Color(0xFFF0C177),
        foreground: const Color(0xFF251506),
      ),
      _StatusChip(
        label: settings.excludeHighTariff
            ? 'No high tariff'
            : 'High tariff allowed',
        accent: settings.excludeHighTariff
            ? const Color(0x24FFFFFF)
            : const Color(0xFFDFEAD9),
        foreground: const Color(0xFFF8F4EC),
      ),
      const _StatusChip(
        label: 'Keep £3.40 available',
        accent: Color(0x24FFFFFF),
        foreground: Color(0xFFF8F4EC),
      ),
      ...settings.excludedValues.map(
        (value) => InputChip(
          label: Text('Excluded ${formatPenceAsCurrency(value)}'),
          onDeleted: onClearExclusions,
          deleteIconColor: Colors.white,
          backgroundColor: Colors.white.withValues(alpha: 0.14),
          labelStyle: textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF3E2A22),
        borderRadius: BorderRadius.circular(30),
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
          Wrap(spacing: 10, runSpacing: 10, children: chips),
          const SizedBox(height: 18),
          Text(
            'Best Fit Stamps',
            style: textTheme.displaySmall?.copyWith(
              color: const Color(0xFFF9F4EB),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'A constrained optimisation engine built around how a clerk actually picks stamps from a physical book.',
            style: textTheme.titleLarge?.copyWith(
              color: const Color(0xFFECE2D7),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;

              final amountPanel = _ControlShell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Required amount',
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onSubmitted: (_) => onRecalculate(),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '10.25 or 1025',
                        errorText: inputError,
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.08),
                        hintStyle: const TextStyle(color: Color(0xFFD0C2B4)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: onRecalculate,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFF0C177),
                        foregroundColor: const Color(0xFF251506),
                      ),
                      icon: const Icon(Icons.auto_fix_high_rounded),
                      label: const Text('Recalculate'),
                    ),
                  ],
                ),
              );

              final togglePanel = _ControlShell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Counter toggles',
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SettingToggle(
                      title: 'Prefer NVI',
                      subtitle:
                          'Soft preference in ranking, not a hard filter.',
                      value: settings.preferNvi,
                      onChanged: onPreferNviChanged,
                    ),
                    const SizedBox(height: 12),
                    _SettingToggle(
                      title: 'No High Tariff',
                      subtitle:
                          'Exclude £4.30 and £3.50 while still allowing £3.40.',
                      value: settings.excludeHighTariff,
                      onChanged: onHighTariffChanged,
                    ),
                  ],
                ),
              );

              if (!isWide) {
                return Column(
                  children: [
                    amountPanel,
                    const SizedBox(height: 16),
                    togglePanel,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: amountPanel),
                  const SizedBox(width: 16),
                  Expanded(child: togglePanel),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SolutionView extends StatelessWidget {
  const _SolutionView({
    super.key,
    required this.result,
    required this.pickedValues,
    required this.onStampTap,
    required this.onClearExcluded,
  });

  final StampCalculationResult result;
  final Set<int> pickedValues;
  final ValueChanged<StampLineItem> onStampTap;
  final ValueChanged<int> onClearExcluded;

  @override
  Widget build(BuildContext context) {
    final recommended = result.recommended!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionPanel(
          eyebrow: 'Recommended result',
          title:
              'Best fit for ${formatPenceAsCurrency(result.targetValuePence)}',
          description: result.explanation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MetricPill(
                    label:
                        '${recommended.distinctValueCount} value${recommended.distinctValueCount == 1 ? '' : 's'}',
                  ),
                  _MetricPill(
                    label:
                        '${recommended.totalStampCount} stamp${recommended.totalStampCount == 1 ? '' : 's'}',
                  ),
                  _MetricPill(
                    label:
                        '${recommended.bookVisitCount} section${recommended.bookVisitCount == 1 ? '' : 's'}',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _StampTray(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: recommended.items
                        .map(
                          (item) => Padding(
                            padding: EdgeInsets.only(
                              right: item == recommended.items.last ? 0 : 16,
                            ),
                            child: StampPickTile(
                              item: item,
                              onTap: () => onStampTap(item),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (result.alternatives.isNotEmpty)
          _SectionPanel(
            eyebrow: 'Alternatives',
            title: 'Other exact combinations',
            description:
                'Each option still matches exactly, but the ranking pushed it behind the recommended pick.',
            child: Column(
              children: result.alternatives
                  .map(
                    (combination) => Padding(
                      padding: EdgeInsets.only(
                        bottom: combination == result.alternatives.last
                            ? 0
                            : 16,
                      ),
                      child: _AlternativeCard(
                        combination: combination,
                        onStampTap: onStampTap,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        if (result.settings.excludedValues.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SectionPanel(
            eyebrow: 'Live exclusions',
            title: 'Current not-available list',
            description:
                'Tap the close icon to put a stamp back into the calculation.',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: result.settings.excludedValues
                  .map(
                    (value) => InputChip(
                      label: Text(formatPenceAsCurrency(value)),
                      onDeleted: () => onClearExcluded(value),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ],
        const SizedBox(height: 20),
        _SectionPanel(
          eyebrow: 'Shelf preview',
          title: 'What is currently on the book',
          description:
              'A quick visual shelf of the active stamp values after the current toggles and exclusions.',
          child: _StampTray(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: result.availableStamps
                  .map(
                    (stamp) => StampPickTile(
                      item: StampLineItem(
                        stamp: stamp,
                        count: 1,
                        isPicked: pickedValues.contains(stamp.valuePence),
                      ),
                      compact: true,
                      onTap: () => onStampTap(
                        StampLineItem(
                          stamp: stamp,
                          count: 1,
                          isPicked: pickedValues.contains(stamp.valuePence),
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ),
      ],
    );
  }
}

class _NoSolutionView extends StatelessWidget {
  const _NoSolutionView({
    super.key,
    required this.result,
    required this.onClearExclusions,
  });

  final StampCalculationResult result;
  final VoidCallback onClearExclusions;

  @override
  Widget build(BuildContext context) {
    return _SectionPanel(
      eyebrow: 'No exact fit',
      title: 'Nothing matches the current constraints',
      description: result.explanation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SupportNote(
            icon: Icons.warning_amber_rounded,
            title: 'Why this happened',
            body:
                'The current exclusions removed every exact path to the target. Clearing one stamp value or relaxing the high tariff rule should reopen the search.',
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onClearExclusions,
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Clear exclusions'),
          ),
        ],
      ),
    );
  }
}

class _AlternativeCard extends StatelessWidget {
  const _AlternativeCard({required this.combination, required this.onStampTap});

  final StampCombination combination;
  final ValueChanged<StampLineItem> onStampTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE3DDD4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricPill(label: '${combination.distinctValueCount} values'),
              _MetricPill(label: '${combination.totalStampCount} stamps'),
              _MetricPill(label: '${combination.bookVisitCount} sections'),
            ],
          ),
          const SizedBox(height: 14),
          _StampTray(
            child: Wrap(
              spacing: 14,
              runSpacing: 14,
              children: combination.items
                  .map(
                    (item) => StampPickTile(
                      item: item,
                      compact: true,
                      onTap: () => onStampTap(item),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportPanel extends StatelessWidget {
  const _SupportPanel({required this.result});

  final StampCalculationResult? result;

  @override
  Widget build(BuildContext context) {
    return _SectionPanel(
      eyebrow: 'Design notes',
      title: 'Built for speed at the counter',
      description:
          'This is not just a calculator. It is a physical workflow assistant that helps clerks pick the right stamps with minimal thinking.',
      child: Column(
        children: [
          const _SupportNote(
            icon: Icons.palette_outlined,
            title: 'Colour recognition first',
            body:
                'The recommended tiles are grouped and colour-led so a clerk can glance at the result and reach for the right section quickly.',
          ),
          const SizedBox(height: 14),
          const _SupportNote(
            icon: Icons.bolt_outlined,
            title: 'Exact-match engine underneath',
            body:
                'Every shown result is an exact combination. The ranking then pushes the faster, lower-friction pick to the top.',
          ),
          if (result != null) ...[
            const SizedBox(height: 14),
            _SupportNote(
              icon: Icons.info_outline_rounded,
              title: 'Current shelf size',
              body:
                  '${result!.availableStamps.length} stamp values are available under the current filters.',
            ),
          ],
        ],
      ),
    );
  }
}

class _ControlShell extends StatelessWidget {
  const _ControlShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: child,
    );
  }
}

class _StampTray extends StatelessWidget {
  const _StampTray({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECE5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2DBCF)),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.6),
            blurRadius: 0,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SettingToggle extends StatelessWidget {
  const _SettingToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: (next) => onChanged(next ?? false),
              side: const BorderSide(color: Colors.white70),
              checkColor: const Color(0xFF251506),
              fillColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? const Color(0xFFF0C177)
                    : Colors.transparent;
              }),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFE6D8CA),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionPanel extends StatelessWidget {
  const _SectionPanel({
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
        borderRadius: BorderRadius.circular(28),
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
              color: const Color(0xFF5B6563),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _SupportNote extends StatelessWidget {
  const _SupportNote({
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

class _SheetHint extends StatelessWidget {
  const _SheetHint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0F5B57)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5B6563),
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF7B6C59),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
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

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.accent,
    required this.foreground,
  });

  final String label;
  final Color accent;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: accent,
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
