import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

class StorageService {
  static const String _favoritesKey = 'favorite_locations';
  static const String _lastLocationKey = 'last_location';

  // ---- Favorites ----

  Future<List<LocationModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_favoritesKey) ?? [];
    return raw
        .map((s) => LocationModel.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> addFavorite(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (!favorites.any((l) => l.id == location.id)) {
      favorites.add(location);
      await prefs.setStringList(
        _favoritesKey,
        favorites.map((l) => jsonEncode(l.toJson())).toList(),
      );
    }
  }

  Future<void> removeFavorite(int locationId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.removeWhere((l) => l.id == locationId);
    await prefs.setStringList(
      _favoritesKey,
      favorites.map((l) => jsonEncode(l.toJson())).toList(),
    );
  }

  Future<bool> isFavorite(int locationId) async {
    final favorites = await getFavorites();
    return favorites.any((l) => l.id == locationId);
  }

  // ---- Last Selected Location ----

  Future<LocationModel?> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastLocationKey);
    if (raw == null) return null;
    return LocationModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveLastLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLocationKey, jsonEncode(location.toJson()));
  }
}
