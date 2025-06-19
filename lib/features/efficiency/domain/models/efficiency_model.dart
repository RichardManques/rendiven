class EfficiencyModel {
  final String id;
  final String userId;
  final String vehicleId;
  final double startKm;
  final double endKm;
  final double kmConsumed;
  final String drivingStyle;
  final String routeType;
  final bool useAC;
  final EfficiencyData efficiency;
  final CostData cost;
  final DateTime date;

  EfficiencyModel({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.startKm,
    required this.endKm,
    required this.kmConsumed,
    required this.drivingStyle,
    required this.routeType,
    required this.useAC,
    required this.efficiency,
    required this.cost,
    required this.date,
  });

  factory EfficiencyModel.fromJson(Map<String, dynamic> json) {
    return EfficiencyModel(
      id: json['_id'],
      userId: json['userId'] is Map ? json['userId']['_id'] : json['userId'],
      vehicleId:
          json['vehicleId'] is Map
              ? json['vehicleId']['_id']
              : json['vehicleId'],
      startKm: json['startKm'].toDouble(),
      endKm: json['endKm'].toDouble(),
      kmConsumed: json['kmConsumed'].toDouble(),
      drivingStyle: json['drivingStyle'],
      routeType: json['routeType'],
      useAC: json['useAC'],
      efficiency: EfficiencyData.fromJson(json['efficiency']),
      cost: CostData.fromJson(json['cost']),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'vehicleId': vehicleId,
      'startKm': startKm,
      'endKm': endKm,
      'kmConsumed': kmConsumed,
      'drivingStyle': drivingStyle,
      'routeType': routeType,
      'useAC': useAC,
      'efficiency': efficiency.toJson(),
      'cost': cost.toJson(),
      'date': date.toIso8601String(),
    };
  }
}

class EfficiencyData {
  final double base;
  final double adjusted;

  EfficiencyData({required this.base, required this.adjusted});

  factory EfficiencyData.fromJson(Map<String, dynamic> json) {
    return EfficiencyData(
      base: json['base'].toDouble(),
      adjusted: json['adjusted'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'base': base, 'adjusted': adjusted};
  }
}

class CostData {
  final double perKm;
  final double total;

  CostData({required this.perKm, required this.total});

  factory CostData.fromJson(Map<String, dynamic> json) {
    return CostData(
      perKm: json['perKm'].toDouble(),
      total: json['total'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'perKm': perKm, 'total': total};
  }
}
