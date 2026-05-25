import 'package:counter_toolkit/features/stamps/domain/best_fit_stamp_solver.dart';
import 'package:counter_toolkit/features/stamps/domain/stamp_models.dart';
import 'package:counter_toolkit/features/stamps/presentation/stamp_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum _AmountEntryMode { pounds, pence }

class StampCalculatorPage extends StatefulWidget {
  const StampCalculatorPage({super.key, required this.solver});

  final BestFitStampSolver solver;

  @override
  State<StampCalculatorPage> createState() => _StampCalculatorPageState();
}

class _StampCalculatorPageState extends State<StampCalculatorPage> {
  late final TextEditingController _targetController;
  StampCalculatorSettings _settings = const StampCalculatorSettings();
  _AmountEntryMode _amountEntryMode = _AmountEntryMode.pounds;
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
    final targetValuePence = _parseTargetValue(
      _targetController.text,
      _amountEntryMode,
    );
    if (targetValuePence == null) {
      setState(() {
        _inputError = _amountEntryMode == _AmountEntryMode.pounds
            ? 'Enter pounds like 10.25.'
            : 'Enter whole pence like 1025.';
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

  void _acknowledgeTap({bool major = false}) {
    Feedback.forTap(context);
    if (major) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  void _recalculateFromUserAction() {
    FocusScope.of(context).unfocus();
    _acknowledgeTap(major: true);
    _recalculate();
  }

  int? _parseTargetValue(String raw, _AmountEntryMode mode) {
    final cleaned = raw.trim().replaceAll('£', '').replaceAll('p', '');
    if (cleaned.isEmpty) {
      return null;
    }

    if (mode == _AmountEntryMode.pence) {
      if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
        return null;
      }
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

  void _setAmountEntryMode(_AmountEntryMode mode) {
    if (_amountEntryMode == mode) {
      return;
    }

    _acknowledgeTap();
    final currentValue = _parseTargetValue(
      _targetController.text,
      _amountEntryMode,
    );
    setState(() {
      _amountEntryMode = mode;
      if (currentValue != null) {
        _targetController.text = _formatInputForMode(currentValue, mode);
      }
    });
    _recalculate();
  }

  String _formatInputForMode(int valuePence, _AmountEntryMode mode) {
    if (mode == _AmountEntryMode.pence) {
      return '$valuePence';
    }

    final pounds = valuePence ~/ 100;
    final pence = valuePence % 100;
    if (pence == 0) {
      return '$pounds';
    }
    return '$pounds.${pence.toString().padLeft(2, '0')}';
  }

  void _handleAmountChanged(String value) {
    setState(() {
      if (_inputError != null) {
        _inputError = null;
      }
    });
  }

  void _togglePreferNvi(bool value) {
    _acknowledgeTap();
    setState(() {
      _settings = _settings.copyWith(preferNvi: value);
    });
    _recalculate();
  }

  void _toggleHighTariff(bool value) {
    _acknowledgeTap();
    setState(() {
      _settings = _settings.copyWith(excludeHighTariff: value);
    });
    _recalculate();
  }

  void _setExcludedValue(int value, bool excluded) {
    _acknowledgeTap();
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
    _acknowledgeTap();
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
    _acknowledgeTap();
    setState(() {
      _settings = _settings.copyWith(excludedValues: <int>{});
    });
    _recalculate();
  }

  Future<void> _openSetupSheet() async {
    FocusScope.of(context).unfocus();
    _acknowledgeTap(major: true);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFF8F4EC),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, refreshSheet) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: _SetupSheetContent(
                  settings: _settings,
                  catalog: widget.solver.catalog,
                  onPreferNviChanged: (value) {
                    _togglePreferNvi(value);
                    refreshSheet(() {});
                  },
                  onHighTariffChanged: (value) {
                    _toggleHighTariff(value);
                    refreshSheet(() {});
                  },
                  onClearExclusions: () {
                    _clearExclusions();
                    refreshSheet(() {});
                  },
                  onToggleExcluded: (value, excluded) {
                    _setExcludedValue(value, excluded);
                    refreshSheet(() {});
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openStampDetails(StampLineItem item) async {
    _acknowledgeTap();
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
    final parsedPreviewValue = _parseTargetValue(
      _targetController.text,
      _amountEntryMode,
    );

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
                      amountEntryMode: _amountEntryMode,
                      parsedPreviewValue: parsedPreviewValue,
                      onBack: () => Navigator.of(context).pop(),
                      onAmountChanged: _handleAmountChanged,
                      onRecalculate: _recalculateFromUserAction,
                      onAmountEntryModeChanged: _setAmountEntryMode,
                      onOpenSetup: _openSetupSheet,
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
                              onStampTap: _openStampDetails,
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
    required this.amountEntryMode,
    required this.parsedPreviewValue,
    required this.onBack,
    required this.onAmountChanged,
    required this.onRecalculate,
    required this.onAmountEntryModeChanged,
    required this.onOpenSetup,
  });

  final TextEditingController controller;
  final String? inputError;
  final _AmountEntryMode amountEntryMode;
  final int? parsedPreviewValue;
  final VoidCallback onBack;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onRecalculate;
  final ValueChanged<_AmountEntryMode> onAmountEntryModeChanged;
  final VoidCallback onOpenSetup;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final helperText = amountEntryMode == _AmountEntryMode.pounds
        ? 'Enter pounds and pence, for example 10.25.'
        : 'Enter whole pence, for example 1025.';
    final hintText = amountEntryMode == _AmountEntryMode.pounds
        ? '10.25'
        : '1025';
    final amountPreview = parsedPreviewValue == null
        ? null
        : 'Calculating ${formatPenceAsCurrency(parsedPreviewValue!)}';

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
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: onBack,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: onOpenSetup,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF0C177),
                  foregroundColor: const Color(0xFF251506),
                ),
                icon: const Icon(Icons.tune_rounded),
                label: const Text('Setup & stock'),
              ),
            ],
          ),
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
            'Enter the postage needed and the app will show the quickest exact stamp pick. Counter defaults and stock live in Setup & stock.',
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
                      'Required postage',
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<_AmountEntryMode>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment<_AmountEntryMode>(
                          value: _AmountEntryMode.pounds,
                          label: Text('Pounds'),
                          icon: Icon(Icons.currency_pound_rounded),
                        ),
                        ButtonSegment<_AmountEntryMode>(
                          value: _AmountEntryMode.pence,
                          label: Text('Pence'),
                          icon: Icon(Icons.pin_outlined),
                        ),
                      ],
                      selected: <_AmountEntryMode>{amountEntryMode},
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          return states.contains(WidgetState.selected)
                              ? const Color(0xFFF0C177)
                              : Colors.white.withValues(alpha: 0.08);
                        }),
                        foregroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          return states.contains(WidgetState.selected)
                              ? const Color(0xFF251506)
                              : Colors.white;
                        }),
                        side: WidgetStateProperty.all(
                          BorderSide(
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                        ),
                        textStyle: WidgetStateProperty.all(
                          const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      onSelectionChanged: (selection) {
                        onAmountEntryModeChanged(selection.first);
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      key: const ValueKey('target-amount-field'),
                      controller: controller,
                      keyboardType: amountEntryMode == _AmountEntryMode.pounds
                          ? const TextInputType.numberWithOptions(decimal: true)
                          : TextInputType.number,
                      onChanged: onAmountChanged,
                      onSubmitted: (_) => onRecalculate(),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: amountEntryMode == _AmountEntryMode.pounds
                            ? 'Amount in pounds'
                            : 'Amount in pence',
                        hintText: hintText,
                        errorText: inputError,
                        helperText: inputError == null ? helperText : null,
                        helperStyle: const TextStyle(
                          color: Color(0xFFD0C2B4),
                          height: 1.35,
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.08),
                        prefixText: amountEntryMode == _AmountEntryMode.pounds
                            ? '£'
                            : null,
                        suffixText: amountEntryMode == _AmountEntryMode.pence
                            ? 'p'
                            : null,
                        labelStyle: const TextStyle(color: Color(0xFFECE2D7)),
                        hintStyle: const TextStyle(color: Color(0xFFD0C2B4)),
                        prefixStyle: const TextStyle(color: Colors.white),
                        suffixStyle: const TextStyle(color: Colors.white),
                      ),
                    ),
                    if (amountPreview != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        amountPreview,
                        style: textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFF0C177),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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

              final guidancePanel = _ControlShell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pick list',
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _HeaderNote(
                      icon: Icons.looks_one_rounded,
                      title: 'Enter the target postage',
                      body:
                          'Type the amount the item needs and recalculate the exact stamp make-up.',
                    ),
                    const SizedBox(height: 12),
                    const _HeaderNote(
                      icon: Icons.sell_outlined,
                      title: 'Pick from the stamp book',
                      body:
                          'The best result is ranked for fewer values, fewer stamps, and easier book movement.',
                    ),
                    const SizedBox(height: 12),
                    const _HeaderNote(
                      icon: Icons.inventory_2_outlined,
                      title: 'Adjust stock when needed',
                      body:
                          'Open Setup & stock when a value is missing or high tariff stamps should be hidden.',
                    ),
                  ],
                ),
              );

              if (!isWide) {
                return Column(
                  children: [
                    amountPanel,
                    const SizedBox(height: 16),
                    guidancePanel,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: amountPanel),
                  const SizedBox(width: 16),
                  Expanded(child: guidancePanel),
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
    required this.onStampTap,
  });

  final StampCalculationResult result;
  final ValueChanged<StampLineItem> onStampTap;

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
        const SizedBox(height: 20),
        _SectionPanel(
          eyebrow: 'Counter note',
          title: 'Setup stays in the background',
          description:
              'Use Setup & stock for availability and ranking preferences. The main screen now stays focused on the pick itself.',
          child: _SupportNote(
            icon: Icons.tune_rounded,
            title: 'One set of controls',
            body: result.settings.excludedValues.isEmpty
                ? 'Nothing is currently marked out of stock.'
                : '${result.settings.excludedValues.length} stamp value${result.settings.excludedValues.length == 1 ? ' is' : 's are'} marked out of stock in Setup & stock.',
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

class _SetupSheetContent extends StatelessWidget {
  const _SetupSheetContent({
    required this.settings,
    required this.catalog,
    required this.onPreferNviChanged,
    required this.onHighTariffChanged,
    required this.onClearExclusions,
    required this.onToggleExcluded,
  });

  final StampCalculatorSettings settings;
  final List<StampDefinition> catalog;
  final ValueChanged<bool> onPreferNviChanged;
  final ValueChanged<bool> onHighTariffChanged;
  final VoidCallback onClearExclusions;
  final void Function(int value, bool excluded) onToggleExcluded;

  @override
  Widget build(BuildContext context) {
    final excludedCount = settings.excludedValues.length;
    final inStockCount = catalog.length - excludedCount;
    final stockSummary = excludedCount == 0
        ? 'No stamp values marked out of stock.'
        : '$excludedCount value${excludedCount == 1 ? '' : 's'} marked out of stock.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Setup & stock',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Keep stock and ranking preferences here so the main screen stays focused on the pick itself.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF5B6563),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2DBCF)),
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricPill(
                label:
                    '$inStockCount value${inStockCount == 1 ? '' : 's'} currently in stock',
              ),
              _MetricPill(label: stockSummary),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _SheetSectionCard(
          title: 'Counter defaults',
          description:
              'These are the only live toggles for ranking and high-tariff filtering.',
          child: Column(
            children: [
              _SettingToggle(
                title: 'Prefer NVI',
                subtitle: 'Soft preference in ranking, not a hard filter.',
                value: settings.preferNvi,
                onChanged: onPreferNviChanged,
              ),
              const SizedBox(height: 12),
              _SettingToggle(
                title: 'No high tariff',
                subtitle:
                    'Hide £4.30 and £3.50 from the solver while still allowing £3.40.',
                value: settings.excludeHighTariff,
                onChanged: onHighTariffChanged,
              ),
              const SizedBox(height: 14),
              const _SheetHint(
                icon: Icons.info_outline_rounded,
                text:
                    'Stock and tariff filtering are separate. A high-value stamp can be in stock here and still be hidden by the No high tariff toggle.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _SheetSectionCard(
          title: 'Stamp book stock',
          description:
              'Tap a stamp to mark it in stock or out of stock. Every change recalculates immediately.',
          trailing: excludedCount == 0
              ? null
              : TextButton.icon(
                  onPressed: onClearExclusions,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Reset stock'),
                ),
          child: Wrap(
            spacing: 14,
            runSpacing: 18,
            children: catalog
                .map(
                  (stamp) => _StockTileButton(
                    stamp: stamp,
                    excluded: settings.excludedValues.contains(
                      stamp.valuePence,
                    ),
                    filterNote:
                        settings.excludeHighTariff &&
                            stamp.isHighTariff &&
                            !settings.availableTariffValues.contains(
                              stamp.valuePence,
                            )
                        ? 'Hidden by No high tariff'
                        : null,
                    onTap: () {
                      final excluded = settings.excludedValues.contains(
                        stamp.valuePence,
                      );
                      onToggleExcluded(stamp.valuePence, !excluded);
                    },
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
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

class _StockTileButton extends StatelessWidget {
  const _StockTileButton({
    required this.stamp,
    required this.excluded,
    required this.onTap,
    this.filterNote,
  });

  final StampDefinition stamp;
  final bool excluded;
  final VoidCallback onTap;
  final String? filterNote;

  @override
  Widget build(BuildContext context) {
    final statusColor = excluded
        ? const Color(0xFF9C3D2A)
        : const Color(0xFF0F5B57);

    return SizedBox(
      width: 132,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('stock-tile-${stamp.valuePence}'),
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: excluded ? 0.42 : 1,
                    child: StampPickTile(
                      item: StampLineItem(stamp: stamp, count: 1),
                      compact: true,
                    ),
                  ),
                  if (excluded)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.58),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9C3D2A),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Out of stock',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                stamp.label,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                excluded ? 'Out of stock' : 'In stock',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (filterNote != null) ...[
                const SizedBox(height: 4),
                Text(
                  filterNote!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF7B6C59),
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
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

class _HeaderNote extends StatelessWidget {
  const _HeaderNote({
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF0C177),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF251506), size: 20),
          ),
          const SizedBox(width: 12),
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
                  body,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => onChanged(!value),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F2EA),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2DBCF)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: value,
                onChanged: (next) => onChanged(next ?? false),
                side: const BorderSide(color: Color(0xFF7B6C59)),
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
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5B6563),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetSectionCard extends StatelessWidget {
  const _SheetSectionCard({
    required this.title,
    required this.description,
    required this.child,
    this.trailing,
  });

  final String title;
  final String description;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE3DDD4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5B6563),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 12), trailing!],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
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
