import 'package:flutter/material.dart';
import 'package:frontend/screens/booking_details_screen.dart';
import 'package:frontend/widgets/custom_bottom_navigation_bar.dart';

class ParkBookingScreen extends StatelessWidget {
  const ParkBookingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Bookings'),
      ),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          return SizedBox(
            width: double.infinity,
            child: Card(
              elevation: 0.4,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(12),
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingDetailsScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Lafayette",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).primaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Jan 25, 2024",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.directions_car,
                            color: Theme.of(context).primaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "ABC 123",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text(
                            "5 TND",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          if ((index == 0)||(index==1)) ...[
                            ElevatedButton(
                              onPressed: () {
                                // Implement pay functionality
                              },
                              child: Text("Pay"),
                            ),
                          ],
                        ],
                      ),
                      if ((index == 0)||(index==1)) ...[
                        const SizedBox(height: 5),
                        Text(
                          "Running",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemCount: 5,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
