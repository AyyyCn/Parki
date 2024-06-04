import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/nearby_parking_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ParkingDetailsPage extends StatelessWidget {
  final NearbyParkingModel parking;

  const ParkingDetailsPage({Key? key, required this.parking}) : super(key: key);

  Future<List<String>> fetchLicensePlates() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? sessionId = prefs.getString('sessionId');
      String? csrfToken = prefs.getString('csrfToken');

      var dio = Dio();
      dio.options.headers['Cookie'] = 'sessionid=$sessionId; csrftoken=$csrfToken';
      dio.options.headers['X-CSRFToken'] = csrfToken;

      var url = 'http://10.0.2.2:8000/license_plate';
      var response = await dio.get(url);

      if (response.statusCode == 200) {
        var responseData = response.data;
        if (responseData is Map && responseData.containsKey('license_plates')) {
          return List<String>.from(responseData['license_plates']);
        } else {
          print('License plates data is not in the expected format');
          return []; // Handle empty list scenario
        }
      } else {
        print('Failed to fetch license plates');
        return []; // Handle error scenario
      }
    } catch (e) {
      print('Error fetching license plates: $e');
      return []; // Handle error scenario
    }
  }

  Future<void> reserveSpot(BuildContext context, String chosenLicensePlate) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? sessionId = prefs.getString('sessionId');
      String? csrfToken = prefs.getString('csrfToken');

      var dio = Dio();
      dio.options.headers['Cookie'] = 'sessionid=$sessionId; csrftoken=$csrfToken';
      dio.options.headers['X-CSRFToken'] = csrfToken;

      var url = 'http://10.0.2.2:8000/ReserveSpot';
      print(parking.id);
      var response = await dio.post(url, data: {
        'license_plate': chosenLicensePlate,
        'parking_id': parking.id, // Assuming 'id' is a property in NearbyParkingModel
      });

      if (response.statusCode == 200) {
        var responseData = response.data;
        if (responseData['status'] == 'session_already_active') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Session already active for this spot!'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Spot reserved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        print('Failed to reserve spot: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reserve spot: ${response.data}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (e is DioError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('an expected error, please try again later'),
            backgroundColor: Color.fromARGB(255, 240, 32, 32),
          ),
        );
      } else {
        print('Error reserving spot: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error reserving spot: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Parking Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display parking image
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                image: DecorationImage(
                  image: AssetImage(parking.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Parking details
            Text(
              parking.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue[700]),
                SizedBox(width: 5),
                Flexible(
                  child: Text(
                    parking.address,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Additional details in boxes
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Total Spots', parking.totalSpots.toString()),
                  SizedBox(height: 10),
                  _buildAvailableSpotsRow(parking.availableSpots),
                  SizedBox(height: 10),
                  _buildDetailRow('Price per Hour (TND)', '${parking.pricePerHour.toStringAsFixed(2)} '),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Button to reserve parking
            ElevatedButton(
              onPressed: parking.availableSpots > 0 ? () => _showLicensePlateSelectionDialog(context) : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock,
                    color: parking.availableSpots > 0 ? Colors.transparent : Colors.grey,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Reserve Parking',
                    style: TextStyle(
                      color: parking.availableSpots > 0 ? Color.fromARGB(255, 4, 111, 7) : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openMap(parking.latitude.toString(), parking.longitude.toString());
        },
        child: Icon(Icons.location_on),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableSpotsRow(int availableSpots) {
    Color? textColor = availableSpots > 0 ? Color.fromARGB(255, 4, 111, 7) : Colors.red[600];
    String text = '$availableSpots';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Available Spots',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: textColor,
          ),
        ),
      ],
    );
  }

  void _showLicensePlateSelectionDialog(BuildContext context) async {
    List<String> licensePlates = await fetchLicensePlates();
    if (licensePlates.isEmpty) {
      // Handle case where no license plates are available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No license plates available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String? chosenLicensePlate = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose License Plate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: licensePlates.map((plate) => _buildLicensePlateItem(context, plate)).toList(),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );

    if (chosenLicensePlate != null) {
      await reserveSpot(context, chosenLicensePlate);
    }
  }

  Widget _buildLicensePlateItem(BuildContext context, String plate) {
    return ListTile(
      title: Text(plate),
      onTap: () {
        Navigator.pop(context, plate);
      },
    );
  }

  Future<void> _openMap(String lat, String long) async {
    String googleURL = 'https://www.google.com/maps/search/?api=1&query=$lat,$long';
    await launch(googleURL);
  }
}
