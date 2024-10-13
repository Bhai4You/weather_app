import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:weather_app/models/city_weather_model.dart';

class ApiService {
  static String apiKey = 'bd5e378503939ddaee76f12ad7a97608';
  var dio = Dio();

  Future<CityWeatherModel?> fetchCityWiseWeather(String cityName) async {
    var response = await dio.request(
      'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey',
      options: Options(
        method: 'GET',
        validateStatus: (status) => true,
      ),
    );

    if (response.statusCode == 200) {
      var decoded = jsonDecode(jsonEncode(response.data));
      var model = CityWeatherModel.fromJson(decoded);
      return model;
    } else {
      return null;
    }
  }

  Future<CityWeatherModel?> fetchCurrentWeather(
      {required double lat, required double long}) async {
    var response = await dio.request(
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$long&appid=$apiKey',
      options: Options(
        method: 'GET',
        validateStatus: (status) => true,
      ),
    );

    if (response.statusCode == 200) {
      var decoded = jsonDecode(jsonEncode(response.data));
      var model = CityWeatherModel.fromJson(decoded);
      return model;
    } else {
      return null;
    }
  }
}
