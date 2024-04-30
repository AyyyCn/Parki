import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Location extends StatefulWidget {
  const Location({Key? key}) : super(key: key);

  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  String locationMessage = 'Current Location';
  late String lat = '';
  late String long = '';

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied';
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      lat = '${position.latitude}';
      long = '${position.longitude}';
      locationMessage = 'Latitude: $lat\nLongitude: $long';
    });
  }
// Open the current location in GoogleMap
Future<void> _openMap(String lat, String long) async {
  String googleURL =
      'https://www.google.com/maps/search/?api=1&query=$lat,$long';
  await canLaunchUrlString(googleURL)
      ? await launchUrlString(googleURL)
      : throw 'Could not launch $googleURL';
}

  // Listen to location updates
void _liveLocation() {
  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );
  Geolocator.getPositionStream(locationSettings: locationSettings)
  .listen((Position position){
    lat=position.latitude.toString();
    long=position.longitude.toString();
    setState(() {
      locationMessage = 'Latitude : $lat\nLongitude : $long';

    });
  });
}

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                _openMap(lat,long);
                
              },
              child: Image.asset(
                'images/map.jpg',
                width: 80,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                GestureDetector(
              onTap: () {
                _getCurrentLocation().catchError((error) {
                  setState(() {
                    locationMessage = error.toString();
                  });
                  _liveLocation();
                });
              },
              child: Text(
                  "Your Location",
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
            ),
                const SizedBox(height: 5),
                Text(
                  locationMessage,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
