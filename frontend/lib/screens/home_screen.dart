import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/nearby_parking_model.dart';
import 'package:frontend/screens/search_screen.dart';
import 'package:frontend/widgets/custom_bottom_navigation_bar.dart';
import 'package:frontend/widgets/custom_icon.dart';
import 'package:frontend/widgets/nearby_parking.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String name="";
  late bool isLoading = true;
  late String locationMessage = 'Current Location';
  late double latitude = 0;
  late double longitude = 0;
  List<NearbyParkingModel> nearbyParkings = [];
  bool isLocationFetched = false;
  bool isNearbyParkingsFetched = false;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    fetchCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchUserProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? sessionId = prefs.getString('sessionId');
      String? csrfToken = prefs.getString('csrfToken');
      var dio = Dio();
      dio.options.headers['Cookie'] = 'sessionid=$sessionId; csrftoken=$csrfToken';
      var url = 'http://10.0.2.2:8000/self';
      var response = await dio.get(url);

      if (response.statusCode == 200) {
        final userData = response.data;
        setState(() {
          name = '${userData['first_name']} ${userData['last_name']}';
          isLoading = false;
        });
      } else {
        print('Failed to fetch user profile');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCurrentLocation() async {
    try {
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
      if (mounted) {
        setState(() {
          latitude = position.latitude;
          longitude = position.longitude;
          locationMessage = 'Latitude: $latitude\nLongitude: $longitude';
        });
      }
      isLocationFetched=true;
      fetchNearbyParkings();
    } catch (e) {
      print('Error fetching current location: $e');
      if (mounted) {
        setState(() {
          locationMessage = 'Error: $e';
        });
      }
    }
  }

  Future<void> fetchNearbyParkings() async {
    setState(() {
      isLoading = true; // Show loading indicator for nearby parkings
    });

    var dio = Dio();
    var url = 'http://10.0.2.2:8000/closest';
    
    // Set up request body
    var requestBody = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'number': '10', // Corrected to a string
    };

    try {
      var response = await dio.get(
        url,
        queryParameters: requestBody,
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            nearbyParkings = [];
            for (var parkingData in response.data) {
              // Extract parking data and distance
              var parkingJson = parkingData[0];
              var distance = parkingData[1];
              nearbyParkings.add(NearbyParkingModel(
                id: parkingJson['id'],
                name: parkingJson['name'],
                longitude: parkingJson['longitude'],
                latitude: parkingJson['latitude'],
                address: parkingJson['adress'], // Corrected 'address' typo
                totalSpots:  parkingJson['totalSpots'],
                availableSpots: parkingJson['availableSpots'],
                pricePerHour: double.tryParse(parkingJson['pricePerHour']) ?? 0.0,
                image: parkingJson['image'] ?? "images/parkings/parking1.jpg",
                distance: distance),
              );
            }
            isLoading = false; // Hide loading indicator for nearby parkings
          });
        }
        isNearbyParkingsFetched= true;
      } else {
        print('Failed to fetch nearby parkings');
        if (mounted) {
          setState(() {
            isLoading = false; // Hide loading indicator for nearby parkings
          });
        }
      }
    } catch (e) {
      print('Error fetching nearby parkings: $e');
      if (mounted) {
        setState(() {
          isLoading = false; // Hide loading indicator for nearby parkings
        });
      }
    }
  }

  Future<void> _openMap(String lat, String long) async {
    String googleURL = 'https://www.google.com/maps/search/?api=1&query=$lat,$long';
    await launch(googleURL); 
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.pink[200],
        foregroundColor: Colors.black,
        title: isLoading
            ? const Text("Hello")
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Hello"),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ],
              ),
        actions: [
          CustomIconButton(
            icon: const Icon(Ionicons.search_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 12),
            child: CustomIconButton(
              icon: const Icon(Ionicons.notifications_outline),
            ),
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            elevation: 0.4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _openMap(latitude.toString(), longitude.toString());
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
                          fetchCurrentLocation().catchError((error) {
                            setState(() {
                              locationMessage = error.toString();
                            });
                                                      });
                        },
                        child: Text(
                          "Your Location",
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Nearby From You",
                style: Theme.of(context).textTheme.headline6,
              ),
              if (!isLocationFetched || !isNearbyParkingsFetched) // Show loading indicator only when fetching nearby parkings
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (!isLoading) // Render nearby parkings only when not loading
            Container(
              height: 400, // Adjust the height as per your requirement
              child: NearbyParkings(
                nearbyParkings: nearbyParkings,
              ),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}

