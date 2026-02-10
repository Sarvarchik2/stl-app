import 'package:equatable/equatable.dart';
import 'package:stl_app/core/api/api_endpoints.dart';

class DocumentModel extends Equatable {
  final String id;
  final String type;
  final String filename;
  final String fileSize;
  final String downloadUrl;

  const DocumentModel({
    required this.id,
    required this.type,
    required this.filename,
    required this.fileSize,
    required this.downloadUrl,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    // Debug print
    // ignore: avoid_print
    print('Parsing Document: $json');
    
    String url = json['download_url'] ?? json['url'] ?? json['file_url'] ?? json['path'] ?? '';
    
    // Handle relative URLs
    if (url.startsWith('/')) {
      url = '${ApiEndpoints.baseUrl}$url';
    }

    return DocumentModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      filename: json['original_filename'] ?? json['filename'] ?? 'document',
      fileSize: json['file_size']?.toString() ?? '',
      downloadUrl: url,
    );
  }

  @override
  List<Object?> get props => [id, type, filename, fileSize, downloadUrl];
}

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
  final List<DocumentModel> documents;

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
    this.documents = const [],
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id']?.toString() ?? '',
      carId: json['car_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'NEW',
      finalPrice: json['final_price']?.toString() ?? '0',
      carBrand: json['car_brand']?.toString() ?? (json['car']?['brand']?.toString() ?? ''),
      carModel: json['car_model']?.toString() ?? (json['car']?['model']?.toString() ?? ''),
      carYear: json['car_year'] ?? (json['car']?['year'] ?? 0),
      carImageUrl: json['car_image_url']?.toString(),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      documents: (json['documents'] as List? ?? [])
          .map<DocumentModel>((d) => DocumentModel.fromJson(Map<String, dynamic>.from(d)))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, carId, status, finalPrice, carBrand, carModel, carYear, carImageUrl, createdAt, documents];
}
