import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../services/geocoding_service.dart';

enum SearchState { idle, loading, success, error }

class SearchViewModel extends ChangeNotifier {
  final GeocodingService _geocodingService = GeocodingService();

  SearchState _state = SearchState.idle;
  List<LocationModel> _results = [];
  String _errorMessage = '';
  String _query = '';

  SearchState get state => _state;
  List<LocationModel> get results => _results;
  String get errorMessage => _errorMessage;
  String get query => _query;

  Future<void> searchLocations(String query) async {
    _query = query;

    if (query.trim().isEmpty) {
      _state = SearchState.idle;
      _results = [];
      notifyListeners();
      return;
    }

    _state = SearchState.loading;
    notifyListeners();

    try {
      _results = await _geocodingService.searchLocations(query);
      _state = SearchState.success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = SearchState.error;
      _results = [];
    }
    notifyListeners();
  }

  void clearSearch() {
    _query = '';
    _results = [];
    _state = SearchState.idle;
    notifyListeners();
  }
}
