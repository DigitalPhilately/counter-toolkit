import 'package:counter_toolkit/features/stamps/domain/stamp_models.dart';

class BestFitStampSolver {
  const BestFitStampSolver(
    this.catalog, {
    this.maxSolutionsPerState = 18,
    this.maxReturnedSolutions = 6,
  });

  final List<StampDefinition> catalog;
  final int maxSolutionsPerState;
  final int maxReturnedSolutions;

  StampCalculationResult calculate({
    required int targetValuePence,
    required StampCalculatorSettings settings,
    Set<int> pickedValues = const {},
  }) {
    final availableStamps =
        catalog.where(settings.allows).toList(growable: false)
          ..sort((left, right) => right.valuePence.compareTo(left.valuePence));

    if (targetValuePence <= 0) {
      return StampCalculationResult(
        targetValuePence: targetValuePence,
        settings: settings,
        availableStamps: availableStamps,
        solutions: const [],
        explanation: 'Enter a target value above zero to calculate a result.',
        message: 'Target value must be positive.',
      );
    }

    if (availableStamps.isEmpty) {
      return StampCalculationResult(
        targetValuePence: targetValuePence,
        settings: settings,
        availableStamps: availableStamps,
        solutions: const [],
        explanation: 'No stamps are currently available under these settings.',
        message: 'Every available stamp has been filtered out.',
      );
    }

    final memo = <_SolverKey, List<StampCombination>>{};
    final rawSolutions = _search(
      index: 0,
      remaining: targetValuePence,
      availableStamps: availableStamps,
      settings: settings,
      memo: memo,
    );
    final solutions = _limitToPracticalStampCounts(rawSolutions)
        .take(maxReturnedSolutions)
        .map((solution) => solution.applyPickedValues(pickedValues))
        .toList(growable: false);

    final explanation = solutions.isEmpty
        ? _buildNoSolutionExplanation(targetValuePence, settings)
        : _buildExplanation(solutions.first, settings);

    return StampCalculationResult(
      targetValuePence: targetValuePence,
      settings: settings,
      availableStamps: availableStamps,
      solutions: solutions,
      explanation: explanation,
      message: solutions.isEmpty
          ? 'No exact match was found with the current exclusions.'
          : null,
    );
  }

  List<StampCombination> _search({
    required int index,
    required int remaining,
    required List<StampDefinition> availableStamps,
    required StampCalculatorSettings settings,
    required Map<_SolverKey, List<StampCombination>> memo,
  }) {
    if (remaining == 0) {
      return const [StampCombination(items: [])];
    }
    if (index >= availableStamps.length || remaining < 0) {
      return const [];
    }

    final key = _SolverKey(index: index, remaining: remaining);
    final cached = memo[key];
    if (cached != null) {
      return cached;
    }

    final stamp = availableStamps[index];
    final candidates = <StampCombination>[];
    final seenSignatures = <String>{};
    final maxCount = remaining ~/ stamp.valuePence;

    for (var count = maxCount; count >= 0; count--) {
      final nextRemaining = remaining - (stamp.valuePence * count);
      final tails = _search(
        index: index + 1,
        remaining: nextRemaining,
        availableStamps: availableStamps,
        settings: settings,
        memo: memo,
      );

      for (final tail in tails) {
        final candidateItems = <StampLineItem>[
          if (count > 0) StampLineItem(stamp: stamp, count: count),
          ...tail.items,
        ];
        final candidate = StampCombination(items: candidateItems);
        if (seenSignatures.add(candidate.signature)) {
          candidates.add(candidate);
        }
      }
    }

    candidates.sort((left, right) => _compare(left, right, settings));
    final trimmed = candidates.length <= maxSolutionsPerState
        ? candidates
        : candidates.take(maxSolutionsPerState).toList(growable: false);
    memo[key] = trimmed;
    return trimmed;
  }

  List<StampCombination> _limitToPracticalStampCounts(
    List<StampCombination> solutions,
  ) {
    if (solutions.isEmpty) {
      return solutions;
    }

    final minimumStampCount = solutions
        .map((solution) => solution.totalStampCount)
        .reduce((left, right) => left < right ? left : right);
    final practicalThreshold = minimumStampCount + 3;

    return solutions
        .where((solution) => solution.totalStampCount <= practicalThreshold)
        .toList(growable: false);
  }

  int _compare(
    StampCombination left,
    StampCombination right,
    StampCalculatorSettings settings,
  ) {
    var comparison = left.distinctValueCount.compareTo(
      right.distinctValueCount,
    );
    if (comparison != 0) {
      return comparison;
    }

    comparison = left.totalStampCount.compareTo(right.totalStampCount);
    if (comparison != 0) {
      return comparison;
    }

    comparison = left.bookVisitCount.compareTo(right.bookVisitCount);
    if (comparison != 0) {
      return comparison;
    }

    comparison = right.highDenominationScore.compareTo(
      left.highDenominationScore,
    );
    if (comparison != 0) {
      return comparison;
    }

    if (settings.preferNvi) {
      comparison = right.nviScore.compareTo(left.nviScore);
      if (comparison != 0) {
        return comparison;
      }
    }

    return left.signature.compareTo(right.signature);
  }

  String _buildExplanation(
    StampCombination combination,
    StampCalculatorSettings settings,
  ) {
    final reasons = <String>[];

    if (combination.totalStampCount <= 4) {
      reasons.add('Using a short pick list to reduce handling time.');
    } else {
      reasons.add('Keeping the number of different stamp values low.');
    }

    if (combination.bookVisitCount == 1) {
      reasons.add('Everything comes from one section of the book.');
    } else if (combination.bookVisitCount == 2) {
      reasons.add('Only two book sections are needed for this pick.');
    }

    if (settings.excludeHighTariff) {
      reasons.add('High tariff stamps are restricted by the current toggle.');
    }

    if (settings.preferNvi && combination.usesNvi) {
      reasons.add(
        'NVI usage was favoured where it still fit the faster route.',
      );
    } else if (!settings.excludeHighTariff) {
      reasons.add(
        'Higher denomination stamps are helping keep the pick efficient.',
      );
    }

    return reasons.take(2).join(' ');
  }

  String _buildNoSolutionExplanation(
    int targetValuePence,
    StampCalculatorSettings settings,
  ) {
    final reasons = <String>[
      'No exact match was found for ${formatPenceAsCurrency(targetValuePence)}.',
    ];

    if (settings.excludedValues.isNotEmpty) {
      reasons.add('Try clearing one of the excluded stamp values.');
    }
    if (settings.excludeHighTariff) {
      reasons.add(
        'Disabling the high tariff restriction may open more options.',
      );
    }

    return reasons.join(' ');
  }
}

class _SolverKey {
  const _SolverKey({required this.index, required this.remaining});

  final int index;
  final int remaining;

  @override
  bool operator ==(Object other) {
    return other is _SolverKey &&
        other.index == index &&
        other.remaining == remaining;
  }

  @override
  int get hashCode => Object.hash(index, remaining);
}
