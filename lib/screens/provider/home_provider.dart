import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/models/city_weather_model.dart';
import 'package:weather_app/service/api_service.dart';

class HomeProvider extends ChangeNotifier {
  TextEditingController citySearchController = TextEditingController();
  bool _isLoading = false;
  CityWeatherModel? _weatherData;
  bool _isLastCityVisible = false;
  String? _lastCityName;

  bool get isLoading => _isLoading;
  bool get isLastCityVisible => _isLastCityVisible;
  String? get lastCityName => _lastCityName;
  CityWeatherModel? get weatherData => _weatherData;

  setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  resetData() {
    _weatherData = null;
    notifyListeners();
  }

  Future<bool> fetchCityWeather() async {
    setLoading(true);
    final value =
        await ApiService().fetchCityWiseWeather(citySearchController.text);
    if (value != null) {
      _weatherData = value;
      _isLoading = false;
      notifyListeners();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastCity', citySearchController.text);
      return true;
    } else {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchCurrentCity(double latitude, double longitude) async {
    _isLoading = true;
    notifyListeners();
    final value =
        await ApiService().fetchCurrentWeather(lat: latitude, long: longitude);
    if (value != null) {
      _weatherData = value;
      citySearchController.text = value.name.toString();
      _isLoading = false;
      notifyListeners();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastCity', citySearchController.text);
      return true;
    } else {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  checkPermission() async {
    PermissionStatus permissionStatus = await Permission.location.request();
    return permissionStatus;
  }

  Future<void> checkLastSearchedCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastCity = prefs.getString('lastCity');
    if (lastCity != null) {
      _lastCityName = lastCity;
      _isLastCityVisible = true;
      notifyListeners();
    }
  }
}
