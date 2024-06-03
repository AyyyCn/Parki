import 'package:flutter/material.dart';
import 'package:frontend/models/nearby_parking_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ParkingDetailsPage extends StatelessWidget {
  final NearbyParkingModel parking;

  const ParkingDetailsPage({Key? key, required this.parking}) : super(key: key);

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
              onPressed: parking.availableSpots > 0 ? () {
                // Implement reservation logic
              } : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, color: parking.availableSpots > 0 ? Colors.transparent : Colors.grey),
                  SizedBox(width: 5),
                  Text(
                        'Reserve Parking',
                        style: TextStyle(
                          color: parking.availableSpots > 0 ? Color.fromARGB(255, 4, 111, 7) : Colors.grey, 
                          fontWeight: FontWeight.bold, 
                        ),
                      )
                      ,
                  
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
    String text ='$availableSpots' ;
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
}
Future<void> _openMap(String lat, String long) async {
    String googleURL = 'https://www.google.com/maps/search/?api=1&query=$lat,$long';
    await launch(googleURL); 
  }