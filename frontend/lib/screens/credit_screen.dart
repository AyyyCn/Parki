import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_bottom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreditScreen extends StatefulWidget {
  @override
  _CreditScreenState createState() => _CreditScreenState();
}

class _CreditScreenState extends State<CreditScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  static late  double credit=0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
    fetchCredit();
  }

  Future<void> fetchCredit() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString('sessionId');
    String? csrfToken = prefs.getString('csrfToken');
    var dio = Dio();
    dio.options.headers['Cookie'] = 'sessionid=$sessionId; csrftoken=$csrfToken';

    var url = 'http://10.0.2.2:8000/self?field=credit';
    var response = await dio.get(url);

    if (response.statusCode == 200) {
      final userData = response.data;
      setState(() {
        credit = (userData['credit'] ?? 0).toDouble();
        isLoading = false;
      });
    } else {
      print('Failed to fetch credit');
    }
  } catch (e) {
    print('Error fetching credit: $e');
  }
}


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 102, 187, 236),
        title: Row(
          children: [
            Text(
              'Your Credits',
              style: TextStyle(color: Colors.white), // Set text color to white
            ),
            Spacer(), // Add spacer to push the money icon to the right
            Icon(
              Icons.attach_money,
              color: Colors.white, // Set icon color to white
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TotalCreditsWidget(userCredits: credit),
              SizedBox(height: 20),
              AnimatedTitle(),
              SizedBox(height: 20),
              CreditOption(
                title: 'Recharge Téléphonique',
                description: 'Get 1 DT for each DT from your mobile sold',
                creditEarned: 1.0, // You earn 1 DT for each DT from your mobile sold
                image: 'images/mobile_sold_image.png', // Placeholder image for mobile sold
                onTap: () {
                  // Implement your logic for mobile recharge
                },
              ),
              SizedBox(height: 10),
              CreditOption(
                title: 'Watch Ads',
                description: 'Watch 5 ads to earn 0.5 DT daily',
                creditEarned: 0.5, // You earn 0.5 DT for watching 5 ads
                image: 'images/watch_ads_image.jpg', // Placeholder image for watching ads
                onTap: () {
                  // Implement your logic for watching ads
                },
              ),
              SizedBox(height: 10),
              CreditOption(
                title: 'Refer a Friend',
                description: 'Get 1 DT for each referred friend',
                creditEarned: 1.0, // You earn 1 DT for each referred friend
                image: 'images/refer_friend_image.jpg', // Placeholder image for referring a friend
                onTap: () {
                  // Implement your logic for referring a friend
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}

class TotalCreditsWidget extends StatelessWidget {
  final double userCredits;

  TotalCreditsWidget({
    Key? key,
    required this.userCredits,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width), // Limit width to screen width
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Total Credits',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 10),
          Row(
            children: [
              Icon(Icons.monetization_on, size: 30, color: Color.fromARGB(255, 102, 187, 236)),
              SizedBox(width: 5),
              Text(
                '${userCredits.toStringAsFixed(2)} DT',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



class AnimatedTitle extends StatefulWidget {
  @override
  _AnimatedTitleState createState() => _AnimatedTitleState();
}

class _AnimatedTitleState extends State<AnimatedTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(
          'Need more credit?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class CreditOption extends StatelessWidget {
  final String title;
  final String description;
  final double creditEarned;
  final String image;
  final VoidCallback onTap;

  const CreditOption({
    Key? key,
    required this.title,
    required this.description,
    required this.creditEarned,
    required this.image,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Earn: ${creditEarned.toStringAsFixed(2)} DT', // Ensured as a double
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color.fromARGB(255, 102, 187, 236)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
