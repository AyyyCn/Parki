import 'package:flutter/material.dart';
import 'package:frontend/screens/booking_details_screen.dart';
import 'package:frontend/widgets/custom_bottom_navigation_bar.dart';
import 'dart:async';

class ParkBookingScreen extends StatelessWidget {
  const ParkBookingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.access_time, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Track your reservations",
                style: TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TotalPriceCard(totalPrice: 12.50),
            SizedBox(height: 10),
            ListView.separated(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                bool isRunning = index == 0 || index == 1;
                return isRunning
                    ? RunningReservationCard(
                        parkingName: "Lafayette",
                        startTime: "10:00 AM",
                        price: 5.00,
                        duration: "01:05:24",
                        licensePlate: "ABC 123",
                        isPaid: false,
                        onPayPressed: () {
                          // Implement pay functionality
                        },
                      )
                    : ReservationCard(
                        parkingName: "Parking Insat",
                        startTime: "11:30 AM",
                        endTime: "1:00 PM",
                        price: 7.50,
                        licensePlate: "200 - TN - 1234",
                      );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemCount: 5,
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}

class RunningReservationCard extends StatefulWidget {
  final String parkingName;
  final String startTime;
  final double price;
  final String duration;
  final String licensePlate;
  final bool isPaid;
  final VoidCallback onPayPressed;

  const RunningReservationCard({
    Key? key,
    required this.parkingName,
    required this.startTime,
    required this.price,
    required this.duration,
    required this.licensePlate,
    required this.isPaid,
    required this.onPayPressed,
  }) : super(key: key);

  @override
  _RunningReservationCardState createState() => _RunningReservationCardState();
}

class _RunningReservationCardState extends State<RunningReservationCard> {
  late Timer _timer;
  late DateTime _startTime;
  late Duration _runningDuration;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.parse("2024-01-25 10:00:00"); // Example start time, replace with actual
    _runningDuration = Duration(hours: 1, minutes: 5, seconds: 24);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _runningDuration = DateTime.now().difference(_startTime);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.parkingName,
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 10),
            Text(
              "Start Time: ${widget.startTime}",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 10),
            Text(
              "Price: \$${widget.price.toStringAsFixed(2)}",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 10),
            Text(
              "License Plate: ${widget.licensePlate}",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 10),
            Text(
              "Running: ${_formatDuration(_runningDuration)}",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            if (!widget.isPaid)
              ElevatedButton(
                onPressed: widget.onPayPressed,
                child: Text("Pay"),
              ),
          ],
        ),
      ),
    );
  }
}

class ReservationCard extends StatelessWidget {
  final String parkingName;
  final String startTime;
  final String endTime;
  final double price;
  final String licensePlate;

  const ReservationCard({
    Key? key,
    required this.parkingName,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.licensePlate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              parkingName,
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
                  startTime,
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
                  licensePlate,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              "Price: \$${price.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "End Time: $endTime",
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TotalPriceCard extends StatelessWidget {
  final double totalPrice;

  const TotalPriceCard({
    Key? key,
    required this.totalPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Price to be Paid",
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 10),
            Text(
              "\$${totalPrice.toStringAsFixed(2)}",
              style: Theme.of(context).textTheme.headline4?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}


