import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/nearby_parking_model.dart';
import 'package:frontend/widgets/custom_bottom_navigation_bar.dart';
import 'package:frontend/widgets/custom_icon.dart';
import 'package:frontend/widgets/nearby_parking.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String name;
  late bool isLoading = true;
  late String locationMessage = 'Current Location';
  late double latitude = 0;
  late double longitude = 0;
  List<NearbyParkingModel> nearbyParkings = [];

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    fetchCurrentLocation();
    fetchNearbyParkings();
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
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        locationMessage = 'Latitude: $latitude\nLongitude: $longitude';
      });

      fetchNearbyParkings();
    } catch (e) {
      print('Error fetching current location: $e');
      setState(() {
        locationMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchNearbyParkings() async {
  var dio = Dio();
  var url = 'http://10.0.2.2:8000/closest';
  
  // Set up request body
  var requestBody = {
    'latitude': latitude.toString(),
    'longitude': longitude.toString(),
    'number': 10, // Fetch first 5
  };

  try {
    var response = await dio.get(
      url,
      queryParameters: requestBody,
    );

    if (response.statusCode == 200) {
      setState(() {
        print('here 1 ');
        nearbyParkings = [];
        for (var parkingData in response.data) {
          print('inside the for loop');
          // Extract parking data and distance
          var parkingJson = parkingData[0];
          var distance = parkingData[1];
          nearbyParkings.add(NearbyParkingModel(
            id: parkingJson['id'],
            name: parkingJson['name'],
            address: parkingJson['adress'],
            totalSpots:  parkingJson['totalSpots'],
            availableSpots: parkingJson['availableSpots'],
            pricePerHour: double.tryParse(parkingJson['pricePerHour']) ?? 0.0,
            image: parkingJson['image'] ?? "images/parkings/parking1.jpg",
            distance: distance) ,
          );
        }
        
        isLoading = false;
      });
    } else {
      print('Failed to fetch nearby parkings');
      setState(() {
        isLoading = false;
      });
    }
  } catch (e) {
    print('Error fetching nearby parkings: $e');
    setState(() {
      isLoading = false;
    });
  }
}


  Future<void> _openMap(String lat, String long) async {
    String googleURL = 'https://www.google.com/maps/search/?api=1&query=$lat,$long';
    await canLaunchUrlString(googleURL)
        ? await launchUrlString(googleURL)
        : throw 'Could not launch $googleURL';
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
      title: isLoading
          ? const Text("Hello")
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Hello"),
                Text(
                  name,
                  style: Theme.of(context).textTheme.labelMedium,
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
    body: isLoading
        ? Center(
            child: CircularProgressIndicator(), // Show loading indicator while fetching name
          )
        : ListView(
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
              ),
              const SizedBox(height: 15),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Nearby From You",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              NearbyParkings(nearbyParkings: nearbyParkings),
            ],
          ),
    bottomNavigationBar: CustomBottomNavigationBar(),
  );
}
}

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<String> _searchResults = [];

  void _performSearch(String query) {
  setState(() {
    _isSearching = true;
    _searchResults = List.generate(10, (index) => 'Result $index for "$query"');
    _isSearching = false;
  });
}

void _clearSearch() {
  _searchController.clear();
  setState(() {
    _searchResults.clear();
  });
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Ionicons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search...',
          border: InputBorder.none,
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Ionicons.close_circle),
                  onPressed: _clearSearch,
                )
              : null,
        ),
        onChanged: (query) {
          if (query.isNotEmpty) {
            _performSearch(query);
          } else {
            setState(() {
              _searchResults.clear();
            });
          }
        },
      ),
    ),
    body: _isSearching
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : _searchResults.isEmpty
            ? const Center(
                child: Text(
                  'No results found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: const Icon(Ionicons.search_outline),
                      title: Text(_searchResults[index]),
                      trailing: const Icon(Ionicons.arrow_forward),
                      onTap: () {
                        // Handle result tap
                      },
                    ),
                  );
                },
              ),
  );
}
}