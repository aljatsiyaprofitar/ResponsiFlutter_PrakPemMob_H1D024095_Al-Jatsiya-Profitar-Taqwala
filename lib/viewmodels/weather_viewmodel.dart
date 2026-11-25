import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/storage_service.dart';

enum WeatherLoadState { initial, loading, success, error }

class WeatherViewModel extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final StorageService _storageService = StorageService();

  WeatherLoadState _state = WeatherLoadState.initial;
  WeatherData? _weatherData;
  LocationModel? _selectedLocation;
  String _errorMessage = '';
  List<LocationModel> _favorites = [];
  bool _isFavorite = false;

  WeatherLoadState get state => _state;
  WeatherData? get weatherData => _weatherData;
  LocationModel? get selectedLocation => _selectedLocation;
  String get errorMessage => _errorMessage;
  List<LocationModel> get favorites => _favorites;
  bool get isFavorite => _isFavorite;

  WeatherViewModel() {
    _init();
  }

  Future<void> _init() async {
    await loadFavorites();
    final lastLocation = await _storageService.getLastLocation();
    if (lastLocation != null) {
      await selectLocation(lastLocation);
    } else {
      // Default: Jakarta
      await selectLocation(LocationModel(
        id: 1642911,
        name: 'Jakarta',
        latitude: -6.2146,
        longitude: 106.8451,
        country: 'Indonesia',
        admin1: 'DKI Jakarta',
      ));
    }
  }

  Future<void> selectLocation(LocationModel location) async {
    _selectedLocation = location;
    _state = WeatherLoadState.loading;
    notifyListeners();

    try {
      _weatherData = await _weatherService.fetchWeather(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      _isFavorite = await _storageService.isFavorite(location.id);
      await _storageService.saveLastLocation(location);
      _state = WeatherLoadState.success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = WeatherLoadState.error;
    }
    notifyListeners();
  }

  Future<void> refreshWeather() async {
    if (_selectedLocation == null) return;
    await selectLocation(_selectedLocation!);
  }

  Future<void> toggleFavorite() async {
    if (_selectedLocation == null) return;
    if (_isFavorite) {
      await _storageService.removeFavorite(_selectedLocation!.id);
    } else {
      await _storageService.addFavorite(_selectedLocation!);
    }
    _isFavorite = !_isFavorite;
    await loadFavorites();
    notifyListeners();
  }

  Future<void> loadFavorites() async {
    _favorites = await _storageService.getFavorites();
    notifyListeners();
  }

  Future<void> removeFavorite(int locationId) async {
    await _storageService.removeFavorite(locationId);
    await loadFavorites();
  }
}
