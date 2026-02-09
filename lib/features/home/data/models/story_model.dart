import 'package:equatable/equatable.dart';

class LocalizedString extends Equatable {
  final String ru;
  final String uz;
  final String en;

  const LocalizedString({
    required this.ru,
    required this.uz,
    required this.en,
  });

  factory LocalizedString.fromJson(Map<String, dynamic> json) {
    return LocalizedString(
      ru: json['ru'] ?? '',
      uz: json['uz'] ?? '',
      en: json['en'] ?? '',
    );
  }

  String get localized {
    // This could depend on a global state or common logic
    return ru; // Fallback, will be handled by a helper
  }

  @override
  List<Object?> get props => [ru, uz, en];
}

class StorySlideModel extends Equatable {
  final String id;
  final LocalizedString title;
  final LocalizedString content;
  final String imageUrl;
  final LocalizedString? buttonText;
  final String? buttonLink;
  final int order;

  const StorySlideModel({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    this.buttonText,
    this.buttonLink,
    required this.order,
  });

  factory StorySlideModel.fromJson(Map<String, dynamic> json) {
    return StorySlideModel(
      id: json['id'].toString(),
      title: LocalizedString.fromJson(json['title']),
      content: LocalizedString.fromJson(json['content']),
      imageUrl: json['image_url'],
      buttonText: json['button_text'] != null ? LocalizedString.fromJson(json['button_text']) : null,
      buttonLink: json['button_link'],
      order: json['order'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, title, content, imageUrl, order];
}

class StoryModel extends Equatable {
  final String id;
  final LocalizedString title;
  final String previewImage;
  final int order;
  final List<StorySlideModel> slides;

  const StoryModel({
    required this.id,
    required this.title,
    required this.previewImage,
    required this.order,
    required this.slides,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'].toString(),
      title: LocalizedString.fromJson(json['title']),
      previewImage: json['preview_image'],
      order: json['order'] ?? 0,
      slides: (json['slides'] as List? ?? [])
          .map((s) => StorySlideModel.fromJson(s))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, title, previewImage, order, slides];
}
