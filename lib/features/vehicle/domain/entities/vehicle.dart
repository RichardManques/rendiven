class Vehicle {
  final String id;
  final String userId;
  final String brand;
  final String model;
  final int year;
  final double engineSize;
  final String fuelType;
  final String transmission;
  final Consumption consumption;
  final bool isDefault;
  final DateTime createdAt;

  Vehicle({
    required this.id,
    required this.userId,
    required this.brand,
    required this.model,
    required this.year,
    required this.engineSize,
    required this.fuelType,
    required this.transmission,
    required this.consumption,
    required this.isDefault,
    required this.createdAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['_id'],
      userId: json['userId'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      engineSize: json['engineSize'].toDouble(),
      fuelType: json['fuelType'],
      transmission: json['transmission'],
      consumption: Consumption.fromJson(json['consumption']),
      isDefault: json['isDefault'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'userId': userId,
      'brand': brand,
      'model': model,
      'year': year,
      'engineSize': engineSize,
      'fuelType': fuelType,
      'transmission': transmission,
      'consumption': consumption.toJson(),
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
    if (id.isNotEmpty) {
      data['_id'] = id;
    }
    return data;
  }
}

class Consumption {
  final double city;
  final double highway;
  final double mixed;

  Consumption({required this.city, required this.highway, required this.mixed});

  factory Consumption.fromJson(Map<String, dynamic> json) {
    return Consumption(
      city: json['city'].toDouble(),
      highway: json['highway'].toDouble(),
      mixed: json['mixed'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'city': city, 'highway': highway, 'mixed': mixed};
  }
}
