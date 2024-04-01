import 'package:flutter/material.dart';

class BookingDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lafayette',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Date: Jan 25, 2024',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Time Spent: 3h 20m',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Vehicle: ABC 123',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            RichText(
              text: TextSpan(
                text: 'Price: ',
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                    text: '5',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' TND',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement your logic for any actions you want to perform
              },
              child: Text('Action Button'),
            ),
          ],
        ),
      ),
    );
  }
}
