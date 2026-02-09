import 'package:equatable/equatable.dart';

class ApplicationModel extends Equatable {
  final String id;
  final String carId;
  final String status;
  final String finalPrice;
  final String carBrand;
  final String carModel;
  final int carYear;
  final String? carImageUrl;
  final DateTime createdAt;

  const ApplicationModel({
    required this.id,
    required this.carId,
    required this.status,
    required this.finalPrice,
    required this.carBrand,
    required this.carModel,
    required this.carYear,
    this.carImageUrl,
    required this.createdAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'].toString(),
      carId: json['car_id'].toString(),
      status: json['status'] ?? 'NEW',
      finalPrice: json['final_price']?.toString() ?? '0',
      carBrand: json['car_brand'] ?? '',
      carModel: json['car_model'] ?? '',
      carYear: json['car_year'] ?? 0,
      carImageUrl: json['car_image_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  @override
  List<Object?> get props => [id, carId, status, finalPrice, carBrand, carModel, carYear, carImageUrl, createdAt];
}
