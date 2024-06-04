import 'package:flutter/material.dart';
import 'package:frontend/models/nearby_parking_model.dart';
import 'package:frontend/screens/parking_detail_screen.dart';

class SearchParkingCard extends StatelessWidget {
  final NearbyParkingModel parking;

  const SearchParkingCard({Key? key, required this.parking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ParkingDetailsPage(parking: parking),
          ),
        );
      },
      child: Card(
        elevation: 2.0,
        child: ListTile(
          contentPadding: EdgeInsets.all(0),
          title: Container(
            height: 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  parking.image,
                  fit: BoxFit.cover,
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 40,
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Text(
                          parking.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          subtitle: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parking.address,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.local_parking,
                      size: 16,
                      color: Colors.orange[600],
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${parking.availableSpots}/${parking.totalSpots} spots available',
                      style: TextStyle(
                        color: parking.availableSpots > 0 ? Colors.green[600] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.yellow[800],
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${parking.pricePerHour.toStringAsFixed(2)} TND per hour',
                      style: TextStyle(
                        color: Colors.yellow[800],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
