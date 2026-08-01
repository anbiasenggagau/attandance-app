import 'package:attandance/utils.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GpsInfo extends StatefulWidget {
  const GpsInfo({super.key});

  @override
  State<GpsInfo> createState() => _GpsInfoState();
}

class _GpsInfoState extends State<GpsInfo> with WidgetsBindingObserver {
  bool gpsReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (mounted) {
        if (serviceEnabled) {
          setState(() {
            gpsReady = true;
          });
        } else {
          showSimpleDialog(
            context,
            "GPS Need To Active",
            "Please make sure to turn on the location service",
          );
        }
      }
    }
  }

  Future<void> getGPSPermission() async {
    LocationPermission permission;
    bool serviceEnabled;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      setState(() {
        gpsReady = true;
      });
    }

    return;
  }

  Future<void> checkGPSService(BuildContext context, bool initiated) async {
    bool serviceEnabled;
    LocationPermission permission;

    if (initiated) {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (context.mounted &&
            (permission == LocationPermission.unableToDetermine ||
                permission == LocationPermission.denied ||
                permission == LocationPermission.deniedForever)) {
          showSimpleDialog(
            context,
            "GPS Service Disabled",
            "Location permission is denied. Geolocation is needed in order to make this app worked. Navigate to settings and allow location permission for this app",
          );
          return;
        }
      }
    }

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (initiated && context.mounted && !serviceEnabled) {
      await promptDialog(
        context,
        "GPS Service Not Active",
        "Please activate GPS service in order to make this app to work",
      );
      await Geolocator.openLocationSettings();
      return;
    }

    return;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    Widget defaultWid = Container(
      width: screenSize.width * 0.4,
      height: screenSize.height * 0.15,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          Center(child: Text('No location data')),
          FilledButton(
            onPressed: () async {
              await checkGPSService(context, true);
            },
            child: Text("Activate GPS Service"),
          ),
        ],
      ),
    );

    getGPSPermission();

    return gpsReady
        ? StreamBuilder(
            stream: Geolocator.getPositionStream(
              locationSettings: AndroidSettings(
                accuracy: LocationAccuracy.best,
                intervalDuration: Duration(seconds: 1),
              ),
            ),

            builder: (context, snapshot) {
              // 1. While waiting for the very first location
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return Container(
                  width: screenSize.width * 0.4,
                  height: screenSize.height * 0.1,
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  child: Center(child: Text('Error listening to location')),
                );
              }

              if (snapshot.hasData) {
                Position position = snapshot.data!;

                // print(position.latitude);

                return Container(
                  width: screenSize.width * 0.4,
                  height: screenSize.height * 0.1,
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Latitude: ${position.latitude}'),
                        Text('Longitude: ${position.longitude}'),
                      ],
                    ),
                  ),
                );
              }

              // Fallback empty state
              return defaultWid;
            },
          )
        : defaultWid;
  }
}
