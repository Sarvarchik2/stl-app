import 'package:equatable/equatable.dart';

class CarModel extends Equatable {
  final String id;
  final String brand;
  final String make;
  final String model;
  final int year;
  final String? trim;
  final String? bodyType;
  final String? fuelType;
  final int? mileage;
  final String? engine;
  final String? transmission;
  final String? drivetrain;
  final String? sourcePriceUsd;
  final String finalPriceUsd;
  final String? imageUrl;
  final List<String> photos;
  final List<String> features;

  const CarModel({
    required this.id,
    required this.brand,
    required this.make,
    required this.model,
    required this.year,
    this.trim,
    this.bodyType,
    this.fuelType,
    this.mileage,
    this.engine,
    this.transmission,
    this.drivetrain,
    this.sourcePriceUsd,
    required this.finalPriceUsd,
    this.imageUrl,
    required this.photos,
    required this.features,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'].toString(),
      brand: json['brand'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] is int ? json['year'] : int.tryParse(json['year'].toString()) ?? 0,
      trim: json['trim'],
      bodyType: json['body_type'],
      fuelType: json['fuel_type'],
      mileage: json['mileage'] is int ? json['mileage'] : int.tryParse(json['mileage']?.toString() ?? ''),
      engine: json['engine'],
      transmission: json['transmission'],
      drivetrain: json['drivetrain'],
      sourcePriceUsd: json['source_price_usd']?.toString(),
      finalPriceUsd: json['final_price_usd']?.toString() ?? '0',
      imageUrl: json['image_url'],
      photos: List<String>.from(json['photos'] ?? []),
      features: List<String>.from(json['features'] ?? []),
    );
  }

  @override
  List<Object?> get props => [id, brand, make, model, year];
}
