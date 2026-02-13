import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/car_model.dart';

class FavoritesRepository {
  final SharedPreferences _prefs;
  static const String _key = 'favorite_cars';

  FavoritesRepository(this._prefs);

  Future<void> toggleFavorite(CarModel car) async {
    final favorites = getFavorites();
    final index = favorites.indexWhere((element) => element.id == car.id);
    
    if (index >= 0) {
      favorites.removeAt(index);
    } else {
      favorites.add(car);
    }
    
    await _saveFavorites(favorites);
  }

  bool isFavorite(String carId) {
    final favorites = getFavorites();
    return favorites.any((car) => car.id == carId);
  }

  List<CarModel> getFavorites() {
    final String? jsonString = _prefs.getString(_key);
    if (jsonString == null) return [];
    
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((e) => CarModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveFavorites(List<CarModel> favorites) async {
    final String jsonString = json.encode(favorites.map((e) => e.toJson()).toList());
    await _prefs.setString(_key, jsonString);
  }
}
