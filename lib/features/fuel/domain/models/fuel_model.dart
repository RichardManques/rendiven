class FuelModel {
  final String id;
  final DateTime date;
  final double liters;
  final int pricePerLiter;
  final double totalCost;
  final String gasStation;
  final String location;

  FuelModel({
    required this.id,
    required this.date,
    required this.liters,
    required this.pricePerLiter,
    required this.totalCost,
    required this.gasStation,
    required this.location,
  });

  factory FuelModel.fromJson(Map<String, dynamic> json) {
    return FuelModel(
      id: json['_id'] ?? '',
      date: DateTime.parse(json['date']),
      liters: (json['liters'] as num).toDouble(),
      pricePerLiter: (json['pricePerLiter'] as num).toInt(),
      totalCost: (json['totalCost'] as num).toDouble(),
      gasStation: json['gasStation'] ?? '',
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'liters': double.parse(liters.toStringAsFixed(1)),
      'pricePerLiter': pricePerLiter,
      'totalCost': double.parse(totalCost.toStringAsFixed(2)),
      'gasStation': gasStation,
      'location': location,
    };
  }
}
