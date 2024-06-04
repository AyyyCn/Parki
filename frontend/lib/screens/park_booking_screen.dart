import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:frontend/models/nearby_parking_model.dart';
import 'package:frontend/screens/credit_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/parking_detail_screen.dart';
import 'package:frontend/widgets/confetti_card.dart';
import 'package:frontend/widgets/custom_bottom_navigation_bar.dart';
import 'package:frontend/widgets/happy_card.dart';
import 'package:frontend/widgets/sad_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class ParkBookingScreen extends StatefulWidget {
  @override
  _ParkBookingScreenState createState() => _ParkBookingScreenState();
}

class _ParkBookingScreenState extends State<ParkBookingScreen> {
  List<dynamic> parkingSessions = [];
  bool isLoading = true;
  Timer? _timer;
  String _selectedTimeFrame = 'Today'; 

  @override
  void initState() {
    super.initState();
    fetchParkingSessions();
    _startTimer();
  }

  Future<Map<String, dynamic>> fetchParkingById(int parkingId) async {
  try {
    var dio = Dio();
    var response = await dio.get('http://10.0.2.2:8000/parking?id=$parkingId');

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to fetch parking');
    }
  } catch (e) {
    throw Exception('Error fetching parking: $e');
  }
}
  Future<void> fetchParkingSessions() async {
    try {
      setState(() {
        isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? sessionId = prefs.getString('sessionId');
      String? csrfToken = prefs.getString('csrfToken');

      var dio = Dio();
      dio.options.headers['Cookie'] = 'sessionid=$sessionId; csrftoken=$csrfToken';
      dio.options.headers['X-CSRFToken'] = csrfToken;

      var url = 'http://10.0.2.2:8000/parkingsession?timeframe=$_selectedTimeFrame';
      var response = await dio.get(url);

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching parking sessions: $e')),
      );

      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> fetchParkingSessionsCustomized(String text) async {
  try {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString('sessionId');
    String? csrfToken = prefs.getString('csrfToken');

    var dio = Dio();
    dio.options.headers['Cookie'] = 'sessionid=$sessionId; csrftoken=$csrfToken';
    dio.options.headers['X-CSRFToken'] = csrfToken;

    var now = DateTime.now();
    var url = 'http://10.0.2.2:8000/parkingsession?timeframe=$text';
    if (text == 'Today') {
      var formattedDate = DateFormat('yyyy-MM-dd').format(now);
      url += '&start_date=$formattedDate';
    } else if (text == 'LastWeek') {
      var startDate = now.subtract(Duration(days: 7));
      var formattedDate = DateFormat('yyyy-MM-dd').format(startDate);
      url += '&start_date=$formattedDate';
    } else if (text == 'LastMonth') {
      var startDate = now.subtract(Duration(days: 30));
      var formattedDate = DateFormat('yyyy-MM-dd').format(startDate);
      url += '&start_date=$formattedDate';
    } else if (text == 'LastYear') {
      var startDate = now.subtract(Duration(days: 365));
      var formattedDate = DateFormat('yyyy-MM-dd').format(startDate);
      url += '&start_date=$formattedDate';
    }

    var response = await dio.get(url);

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching parking sessions: $e')),
    );

    setState(() {
      isLoading = false;
    });
  }
}




  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  double calculateCurrentPrice(DateTime entryTime, double pricePerHour) {
    Duration duration = DateTime.now().difference(entryTime);
    double hours = duration.inMinutes / 60.0;
    return hours * pricePerHour;
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('My Bookings'),
      backgroundColor: Colors.teal,
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                TimeFrameButton(
                  text: 'Today',
                  isSelected: _selectedTimeFrame == 'Today',
                  onTap: () {
                    setState(() {
                      _selectedTimeFrame = 'Today';
                    });
                    fetchParkingSessionsCustomized('Today');
                  },
                ),
                SizedBox(width: 8),
                TimeFrameButton(
                  text: 'Last Week',
                  isSelected: _selectedTimeFrame == 'Last Week',
                  onTap: () {
                    setState(() {
                      _selectedTimeFrame = 'Last Week';
                    });
                    fetchParkingSessionsCustomized('LastWeek');
                  },
                ),
                SizedBox(width: 8),
                TimeFrameButton(
                  text: 'Last Month',
                  isSelected: _selectedTimeFrame == 'Last Month',
                  onTap: () {
                    setState(() {
                      _selectedTimeFrame = 'LastMonth';
                    });
                    fetchParkingSessionsCustomized('LastMonth');
                  },
                ),
                SizedBox(width: 8),
                TimeFrameButton(
                  text: 'Last Year',
                  isSelected: _selectedTimeFrame == 'Last Year',
                  onTap: () {
                    setState(() {
                      _selectedTimeFrame = 'Last Year';
                    });
                    fetchParkingSessionsCustomized('LastYear');
                  },
                ),
              ],
            ),
          ),
        ),
        isLoading
            ? Center(child: CircularProgressIndicator())
            : Expanded(
  child: isLoading
      ? Center(child: CircularProgressIndicator())
      : parkingSessions.isEmpty
          ? Center(
              child: Text(
                'No parking sessions',
                style: TextStyle(fontSize: 18),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Total Price to Pay: ${calculateTotalPriceToPay().toStringAsFixed(2) }TND',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: parkingSessions.length,
                    itemBuilder: (context, index) {
                      var session = parkingSessions[index];
                      DateTime entryTime = DateTime.parse(session['entry_time']);
                      bool isRunning = !session['paid'];
                      double currentPrice = calculateCurrentPrice(entryTime, session['price_per_hour']);

                      return isRunning
                          ? AnimatedRunningSessionCard(
                              key: ValueKey(session['id']),
                              parkingName: session['parkingName'],
                              licensePlate: session['license_plate'],
                              entryTime: entryTime,
                              currentPrice: currentPrice,
                              onPay: () async {
                                String amount = currentPrice.toStringAsFixed(2); // Assuming currentPrice holds the amount of money to pay

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
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => CreditScreen()));
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
                          : CompletedSessionCard(
                              parkingName: session['parkingName'],
                              licensePlate: session['license_plate'],
                              entryTime: entryTime,
                              pricePaid: currentPrice,
                              onRepark: () async {
  try {
    // Fetch parking details using parking ID
    var parking = await fetchParkingById(session['parking']);
    print(parking);
    var parkingModel = NearbyParkingModel(
      id: parking['id'],
      name: parking['name'],
      longitude: parking['longitude'],
      latitude: parking['latitude'],
      address: parking['address'], // Corrected typo here
      totalSpots: parking['total_spots'],
      availableSpots: parking['available_spots'],
      pricePerHour: double.tryParse(parking['price_per_hour']) ?? 0.0,
      image: parking['image'] ?? "images/parkings/parking1.jpg",
      distance: 0, // 0 being a random int
    );
    print(parkingModel);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParkingDetailsPage(parking: parkingModel),
      ),
    );
  } catch (e) {
    print('Error while fetching parking details: $e');
  }
},


                            );
                    },
                  ),
                ],
              ),
            ),
),

      ],
    ),
    bottomNavigationBar: CustomBottomNavigationBar(),
  );
}

  double calculateTotalPriceToPay() {
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
          'parking_id': parkingId
          .toString(),
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
}

class AnimatedRunningSessionCard extends StatelessWidget {
  final String parkingName;
  final DateTime entryTime;
  final double currentPrice;
  final VoidCallback onPay;
  final String licensePlate;


  AnimatedRunningSessionCard({
    required this.parkingName,
    required this.entryTime,
    required this.currentPrice,
    required this.onPay,
    required this.licensePlate, 

    Key? key,
  }) : super(key: key);

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_parking, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  parkingName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.directions_car, color: Colors.grey),
                SizedBox(width: 8),
                Text('${licensePlate}'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey),
                SizedBox(width: 8),
                Text('Start Time: ${_formatDateTime(entryTime)}'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer, color: Colors.grey),
                SizedBox(width: 8),
                Text('Duration: ${_formatDuration(DateTime.now().difference(entryTime))}'),
              ],
            ),
            SizedBox(height: 8),
            Text('Current Price: ${currentPrice.toStringAsFixed(2)} TND'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: onPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text('Pay', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeFrameButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  TimeFrameButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}

class CompletedSessionCard extends StatelessWidget {
  final String parkingName;
  final DateTime entryTime;
  final double pricePaid;
  final VoidCallback onRepark;
  final String licensePlate;

  CompletedSessionCard({
    required this.parkingName,
    required this.entryTime,
    required this.pricePaid,
    required this.onRepark,
    required this.licensePlate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  parkingName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.directions_car, color: Colors.grey),
                SizedBox(width: 8),
                Text('${licensePlate}'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey),
                SizedBox(width: 8),
                Text('Parked on: ${_formatDateTime(entryTime)}'),
              ],
            ),
            SizedBox(height: 8),
            Text('Price Paid: ${pricePaid.toStringAsFixed(2)} TND'),
            SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRepark,
              icon: Icon(Icons.directions_car, color: Colors.teal),
              label: Text('Re-Park'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }
}
