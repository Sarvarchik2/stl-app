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

class ChecklistModel extends Equatable {
  final bool agreedVisit;
  final bool documents;

  const ChecklistModel({
    required this.agreedVisit,
    required this.documents,
  });

  factory ChecklistModel.fromJson(Map<String, dynamic> json) {
    return ChecklistModel(
      agreedVisit: json['agreed_visit'] ?? false,
      documents: json['documents'] ?? false,
    );
  }

  @override
  List<Object?> get props => [agreedVisit, documents];
}

class ApplicationModel extends Equatable {
  final String id;
  final String clientId;
  final String carId;
  final String? operatorId;
  final String? managerId;
  final String? managerFirstName;
  final String? managerLastName;
  final String? managerPhone;
  
  final double sourcePriceSnapshot;
  final double markupPercent;
  final double finalPrice;
  
  final String status;
  final String contactStatus;
  
  final String carBrand;
  final String carModel;
  final int carYear;
  final String? carImageUrl;
  
  final String clientFirstName;
  final String clientLastName;
  final String clientPhone;
  
  final ChecklistModel checklist;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<DocumentModel> documents;

  const ApplicationModel({
    required this.id,
    required this.clientId,
    required this.carId,
    this.operatorId,
    this.managerId,
    this.managerFirstName,
    this.managerLastName,
    this.managerPhone,
    required this.sourcePriceSnapshot,
    required this.markupPercent,
    required this.finalPrice,
    required this.status,
    required this.contactStatus,
    required this.carBrand,
    required this.carModel,
    required this.carYear,
    this.carImageUrl,
    required this.clientFirstName,
    required this.clientLastName,
    required this.clientPhone,
    required this.checklist,
    required this.createdAt,
    required this.updatedAt,
    this.documents = const [],
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return ApplicationModel(
      id: json['id']?.toString() ?? '',
      clientId: json['client_id']?.toString() ?? '',
      carId: json['car_id']?.toString() ?? '',
      operatorId: json['operator_id']?.toString(),
      managerId: json['manager_id']?.toString(),
      managerFirstName: json['manager_first_name']?.toString(),
      managerLastName: json['manager_last_name']?.toString(),
      managerPhone: json['manager_phone']?.toString(),
      sourcePriceSnapshot: parseDouble(json['source_price_snapshot']),
      markupPercent: parseDouble(json['markup_percent']),
      finalPrice: parseDouble(json['final_price']),
      status: json['status']?.toString() ?? 'new',
      contactStatus: json['contact_status']?.toString() ?? '',
      carBrand: json['car_brand']?.toString() ?? '',
      carModel: json['car_model']?.toString() ?? '',
      carYear: json['car_year'] as int? ?? 0,
      carImageUrl: json['car_image_url']?.toString(),
      clientFirstName: json['client_first_name']?.toString() ?? '',
      clientLastName: json['client_last_name']?.toString() ?? '',
      clientPhone: json['client_phone']?.toString() ?? '',
      checklist: ChecklistModel.fromJson(json['checklist'] ?? {}),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      documents: (json['documents'] as List? ?? [])
          .map<DocumentModel>((d) => DocumentModel.fromJson(Map<String, dynamic>.from(d)))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        clientId,
        carId,
        operatorId,
        managerId,
        managerFirstName,
        managerLastName,
        managerPhone,
        sourcePriceSnapshot,
        markupPercent,
        finalPrice,
        status,
        contactStatus,
        carBrand,
        carModel,
        carYear,
        carImageUrl,
        clientFirstName,
        clientLastName,
        clientPhone,
        checklist,
        createdAt,
        updatedAt,
        documents,
      ];
}
