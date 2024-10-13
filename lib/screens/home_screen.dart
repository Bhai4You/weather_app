import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/screens/provider/home_provider.dart';
import 'package:weather_app/utils/colors.dart';
import 'package:weather_app/utils/snackbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  fetchCurrentCity() async {
    var homeProvider = Provider.of<HomeProvider>(context, listen: false);
    await homeProvider.checkLastSearchedCity();
    PermissionStatus permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings);
      await homeProvider.fetchCurrentCity(
          position.latitude, position.longitude);
    } else {
      openSnacbar(context, 'Location Permission Denied !');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchCurrentCity();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: MyColors.white,
      appBar: AppBar(
        backgroundColor: MyColors.white,
        title: Text('Weather Forecast'),
      ),
      body: Consumer<HomeProvider>(
        builder: (context, homeProvider, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: homeProvider.isLoading
                ? Center(child: CircularProgressIndicator())
                : Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          controller: homeProvider.citySearchController,
                          decoration: InputDecoration(
                            labelText: 'Enter city name',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onChanged: (value) {
                            homeProvider.resetData();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter city';
                            }
                            return null;
                          },
                        ),
                        homeProvider.weatherData == null
                            ? ElevatedButton(
                                style: const ButtonStyle(),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    bool status =
                                        await homeProvider.fetchCityWeather();
                                    if (status == false) {
                                      openSnacbar(
                                          context, 'Invalid CityName !');
                                    }
                                  }
                                },
                                child: Text(
                                  'Search',
                                ),
                              )
                            : SizedBox(
                                height: 15,
                              ),
                        homeProvider.weatherData != null
                            ? Container(
                                width: size.width,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Weather Data',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: size.height * 0.02,
                                      ),
                                      Text(
                                          'Temperature : ${homeProvider.weatherData!.main!.temp}°C'),
                                      Text(
                                          'Condition : ${homeProvider.weatherData!.weather![0].description}'),
                                      Text(
                                          'Hmidity : ${homeProvider.weatherData!.main!.humidity}%'),
                                      Text(
                                          'Wind Speed : ${homeProvider.weatherData!.wind!.speed} m/s'),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(),
                        Visibility(
                            visible: homeProvider.isLastCityVisible,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: GestureDetector(
                                onTap: () async {
                                  homeProvider.citySearchController.text =
                                      homeProvider.lastCityName.toString();
                                  await homeProvider.fetchCityWeather();
                                },
                                child: Container(
                                  width: size.width,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Last Searched City',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: size.height * 0.02,
                                            ),
                                            Text(homeProvider.lastCityName
                                                .toString())
                                          ],
                                        ),
                                        Icon(Icons.chevron_right)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ))
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}
