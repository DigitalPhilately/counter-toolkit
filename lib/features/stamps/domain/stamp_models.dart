enum StampType { fixed, nvi, tariff }

class StampDefinition {
  const StampDefinition({
    required this.valuePence,
    required this.label,
    required this.type,
    required this.colourName,
    required this.colourHex,
    required this.group,
    this.isHighTariff = false,
    this.isAvailable = true,
  });

  final int valuePence;
  final String label;
  final StampType type;
  final String colourName;
  final String colourHex;
  final String group;
  final bool isHighTariff;
  final bool isAvailable;

  bool get isNvi => type == StampType.nvi;
}

class StampCalculatorSettings {
  const StampCalculatorSettings({
    this.preferNvi = true,
    this.excludeHighTariff = true,
    this.availableTariffValues = const {340},
    this.excludedValues = const {},
  });

  final bool preferNvi;
  final bool excludeHighTariff;
  final Set<int> availableTariffValues;
  final Set<int> excludedValues;

  StampCalculatorSettings copyWith({
    bool? preferNvi,
    bool? excludeHighTariff,
    Set<int>? availableTariffValues,
    Set<int>? excludedValues,
  }) {
    return StampCalculatorSettings(
      preferNvi: preferNvi ?? this.preferNvi,
      excludeHighTariff: excludeHighTariff ?? this.excludeHighTariff,
      availableTariffValues:
          availableTariffValues ?? this.availableTariffValues,
      excludedValues: excludedValues ?? this.excludedValues,
    );
  }

  bool allows(StampDefinition stamp) {
    if (!stamp.isAvailable) {
      return false;
    }
    if (excludedValues.contains(stamp.valuePence)) {
      return false;
    }
    if (excludeHighTariff &&
        stamp.isHighTariff &&
        !availableTariffValues.contains(stamp.valuePence)) {
      return false;
    }
    return true;
  }
}

class StampLineItem {
  const StampLineItem({
    required this.stamp,
    required this.count,
    this.isPicked = false,
  });

  final StampDefinition stamp;
  final int count;
  final bool isPicked;

  int get totalValuePence => stamp.valuePence * count;

  StampLineItem copyWith({bool? isPicked}) {
    return StampLineItem(
      stamp: stamp,
      count: count,
      isPicked: isPicked ?? this.isPicked,
    );
  }
}

class StampCombination {
  const StampCombination({required this.items});

  final List<StampLineItem> items;

  int get totalValuePence =>
      items.fold(0, (sum, item) => sum + item.totalValuePence);

  int get distinctValueCount => items.length;

  int get totalStampCount => items.fold(0, (sum, item) => sum + item.count);

  int get bookVisitCount =>
      items.map((item) => item.stamp.group).toSet().length;

  int get highDenominationScore => items.fold(
    0,
    (sum, item) =>
        sum + (item.stamp.valuePence * item.stamp.valuePence * item.count),
  );

  int get nviScore => items.fold(
    0,
    (sum, item) =>
        sum + (item.stamp.isNvi ? (item.totalValuePence * 10) + item.count : 0),
  );

  bool get usesNvi => items.any((item) => item.stamp.isNvi);

  String get signature =>
      items.map((item) => '${item.stamp.valuePence}x${item.count}').join('|');

  List<int> get expandedValues {
    final values = <int>[];
    for (final item in items) {
      for (var index = 0; index < item.count; index++) {
        values.add(item.stamp.valuePence);
      }
    }
    return values;
  }

  StampCombination applyPickedValues(Set<int> pickedValues) {
    return StampCombination(
      items: items
          .map(
            (item) => item.copyWith(
              isPicked: pickedValues.contains(item.stamp.valuePence),
            ),
          )
          .toList(growable: false),
    );
  }
}

class StampCalculationResult {
  const StampCalculationResult({
    required this.targetValuePence,
    required this.settings,
    required this.availableStamps,
    required this.solutions,
    required this.explanation,
    this.message,
  });

  final int targetValuePence;
  final StampCalculatorSettings settings;
  final List<StampDefinition> availableStamps;
  final List<StampCombination> solutions;
  final String explanation;
  final String? message;

  bool get hasSolution => solutions.isNotEmpty;

  StampCombination? get recommended =>
      solutions.isEmpty ? null : solutions.first;

  List<StampCombination> get alternatives => solutions.length <= 1
      ? const []
      : solutions.skip(1).toList(growable: false);
}

String formatPenceAsCurrency(int valuePence) {
  if (valuePence >= 100) {
    final pounds = valuePence ~/ 100;
    final pence = valuePence % 100;
    return pence == 0
        ? '£$pounds'
        : '£$pounds.${pence.toString().padLeft(2, '0')}';
  }
  return '${valuePence}p';
}

String stampTypeLabel(StampType type) {
  switch (type) {
    case StampType.fixed:
      return 'Fixed';
    case StampType.nvi:
      return 'NVI';
    case StampType.tariff:
      return 'Tariff';
  }
}
