import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/widgets/confetti_card.dart';
import 'package:frontend/widgets/custom_bottom_navigation_bar.dart';
import 'package:frontend/widgets/happy_card.dart';
import 'package:frontend/widgets/sad_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class ParkBookingScreen extends StatefulWidget {
  @override
  _ParkBookingScreenState createState() => _ParkBookingScreenState();
}

class _ParkBookingScreenState extends State<ParkBookingScreen> {
  List<dynamic> parkingSessions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchParkingSessions();
  }

  Future<void> fetchParkingSessions() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? sessionId = prefs.getString('sessionId');
      String? csrfToken = prefs.getString('csrfToken');

      var dio = Dio();
      dio.options.headers['Cookie'] = 'sessionid=$sessionId; csrftoken=$csrfToken';
      dio.options.headers['X-CSRFToken'] = csrfToken;

      var url = 'http://10.0.2.2:8000/parkingsession';
      var response = await dio.get(url);

      // Fetch parking names and price per hour using parking IDs
      for (var session in response.data) {
        var parkingId = session['parking'];
        var parkingUrl = 'http://10.0.2.2:8000/parking?id=$parkingId';
        var parkingResponse = await dio.get(parkingUrl);
        session['parkingName'] = parkingResponse.data['name'];
        session['price_per_hour'] = double.tryParse(parkingResponse.data['price_per_hour'].toString()) ?? 0.0;
      }

      setState(() {
        parkingSessions = response.data;
        parkingSessions.sort((a, b) => DateTime.parse(b['entry_time']).compareTo(DateTime.parse(a['entry_time'])));
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching parking sessions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

 Future<String> pay(int parkingId, String licensePlate) async {
  String message = "";
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString('sessionId');
    String? csrfToken = prefs.getString('csrfToken');

    var dio = Dio();
    dio.options.headers['Cookie'] = 'sessionid=$sessionId; csrftoken=$csrfToken';
    dio.options.headers['X-CSRFToken'] = csrfToken;

    var url = 'http://10.0.2.2:8000/pay';
    var response = await dio.post(
      url,
      data: {
        'parking_id': parkingId.toString(),
        'license_plate': licensePlate,
      },
    );
    message = response.data['message'];
  } catch (e) {
    print('Error when paying: $e');
    throw e; // Rethrow the error to handle it in the caller function
  }
  return message;
}


  double calculateCurrentPrice(DateTime entryTime, double pricePerHour) {
    Duration duration = DateTime.now().difference(entryTime);
    int hours = (duration.inMinutes / 60.0).ceil();
    return hours * pricePerHour;
  }

  double calculateTotalPriceToPay() {
    // Calculate the sum of prices for running sessions
    double totalPrice = 0.0;
    for (var session in parkingSessions) {
      if (session['paid'] == false) {
        double pricePerHour = session['price_per_hour'] ?? 0.0;
        DateTime entryTime = DateTime.parse(session['entry_time'] ?? DateTime.now().toString());
        double currentPrice = calculateCurrentPrice(entryTime, pricePerHour);
        totalPrice += currentPrice;
      }
    }
    return totalPrice;
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
  children: [
    SizedBox(width: 10),
    Expanded(
      child: Text(
        "Your Parking \nSessions",
        overflow: TextOverflow.visible,
        style: TextStyle(color: Colors.white), // Set text color to white
      ),
    ),
    Spacer(), // Add spacer to push the money icon to the right
    Icon(
      Icons.access_time,
      color: Colors.white, // Set icon color to white
    ),
  ],
),
        backgroundColor: Color.fromARGB(255, 45, 139, 247),
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  TotalPriceCard(totalPrice: calculateTotalPriceToPay()),
                  SizedBox(height: 10),
                  ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      var session = parkingSessions[index];
                      bool isRunning = session['end_time'] == null;
                      double pricePerHour = session['price_per_hour'] ?? 0.0;
                      DateTime entryTime = DateTime.parse(session['entry_time'] ?? DateTime.now().toString());
                      double currentPrice = calculateCurrentPrice(entryTime, pricePerHour);

                      return isRunning
                          ? RunningReservationCard(
                              parkingName: session['parkingName'] ?? "Unknown Parking",
                              startTime: session['entry_time'] ?? "Unknown Time",
                              price: currentPrice,
                              duration: "00:00:00", // Placeholder, update logic as needed
                              licensePlate: session['license_plate'] ?? "Unknown",
                              isPaid: session['paid'] ?? false,
                              payTime: session['pay_time'] ?? "Unknown Time",
                              
                              onPayPressed: () async {
                                double amount = currentPrice; // Assuming currentPrice holds the amount of money to pay

                                // Show dialog to confirm payment
                                bool confirmPayment = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                            'Confirm Payment',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                              fontSize: 24,
                                            ),
                                          ),
                                          content: Text(
                                            'Do you want to pay $amount?',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(false); // Return false if canceled
                                              },
                                              child: Text(
                                                'No',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(true); // Return true if confirmed
                                              },
                                              child: Text(
                                                'Yes',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );

                                  },
                                );

                                // If payment is confirmed, proceed with payment
                                if (confirmPayment == true) {
        
                                  try {
                                    print("9bal lpayment");
                                    print(session["parking"]); print( session["license_plate"]);
                                    String message = await pay(session["parking"], session["license_plate"]);
                                    Widget card;
                                    if (message == "Payment successful. Thank you! Please leave within 15 minutes.") {
                                      // Happy card
                                      card = HappyCard();
                                    } else  {
                                      // Confetti card
                                      card = ConfettiCard();
                                    }

                                    // Show card in a dialog
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: card,
                                          actions: <Widget>[
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                                                },
                                                child: Text('OK'),
                                              ),

                                          ],
                                        );
                                      },
                                    );
                                  } catch (e) {
                                    // Handle payment error
                                    print('Error during payment: $e');
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: SadCard(),
                                          actions: <Widget>[
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                                                },
                                                child: Text('OK'),
                                              ),

                                          ],
                                        );
                                      },
                                    );
                                  }
                                }
                              },






                            )
                          : ReservationCard(
                              parkingName: session['parkingName'] ?? "Unknown Parking",
                              startTime: session['entry_time'] ?? "Unknown Time",
                              endTime: session['end_time'] ?? "Unknown Time",
                              payTime: session['pay_time'] ?? "Unknown Time",
                              price: session['price'] ?? 0.0,
                              licensePlate: session['license_plate'] ?? "Unknown",
                            );
                    },
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemCount: parkingSessions.length,
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
  final String payTime;
  final VoidCallback onPayPressed;

  const RunningReservationCard({
    Key? key,
    required this.parkingName,
    required this.startTime,
    required this.price,
    required this.duration,
    required this.licensePlate,
    required this.isPaid,
    required this.payTime,
    required this.onPayPressed,
  }) : super(key: key);

  @override
  _RunningReservationCardState createState() => _RunningReservationCardState();
}

class _RunningReservationCardState extends State<RunningReservationCard> {
  late Timer _timer= Timer(Duration(seconds: 0), (){});
  late DateTime _startTime;
  late Duration _runningDuration;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.tryParse(widget.startTime) ?? DateTime.now(); // Handle invalid dates
    _runningDuration = Duration(); // Initialize running duration
    if (!widget.isPaid) {
      _startTimer();
    }
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
    if (_timer.isActive) {
      _timer.cancel();
    }
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
      color: widget.isPaid ? Color.fromARGB(255, 87, 97, 164) : Color.fromARGB(255, 58, 122, 133),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.parkingName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              "Start Time: ${widget.startTime}",
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              widget.isPaid ? "Paid Price: \$${widget.price.toStringAsFixed(2)}" : "Current Price: \$${widget.price.toStringAsFixed(2)}",
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              "License Plate: ${widget.licensePlate}",
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            if (widget.isPaid)
              Text(
                "Pay Time: ${widget.payTime}",
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )
            else
              Text(
                "Running: ${_formatDuration(_runningDuration)}",
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            SizedBox(height: 10),
            if (!widget.isPaid)
              ElevatedButton(
                onPressed: widget.onPayPressed,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.greenAccent, // text color
                ),
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
  final String payTime;
  final double price;
  final String licensePlate;

  const ReservationCard({
    Key? key,
    required this.parkingName,
    required this.startTime,
    required this.endTime,
    required this.payTime,
    required this.price,
    required this.licensePlate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Color.fromARGB(255, 45, 139, 247),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              parkingName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              "Start Time: $startTime",
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              "End Time: $endTime",
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              "Pay Time: $payTime",
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              "Price: ${price.toStringAsFixed(2)}",
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              "License Plate: $licensePlate",
              style: TextStyle(color: Colors.white),
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
      color: Color.fromARGB(255, 58, 122, 133),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Price to be Paid",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),
            Center( 
              child:
            Text(
              "\$${totalPrice.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amberAccent),
            ),)
          ],
        ),
      ),
    );
  }
}

