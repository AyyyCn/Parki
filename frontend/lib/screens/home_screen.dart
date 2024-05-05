import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_bottom_navigation_bar.dart';
import 'package:frontend/widgets/custom_icon.dart';
import 'package:frontend/widgets/location.dart';
import 'package:ionicons/ionicons.dart';
import 'package:frontend/widgets/recommended_parking.dart';
import 'package:frontend/widgets/nearby_parking.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String name;
  late bool isLoading = true;

   @override
  void initState() {
    super.initState();
    fetchUserProfile();
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
        name = userData['first_name'].toString() + " " +userData['last_name'].toString()  ;
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: 
      AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: isLoading
          ? Text("Good Morning") // Show static text during loading
          : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Good Morning"),
            Text(
              name,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        actions: const [
          CustomIconButton(
            icon: Icon(Ionicons.search_outline),
          ),
          Padding(
            padding: EdgeInsets.only(left: 8.0, right: 12),
            child: CustomIconButton(
              icon: Icon(Ionicons.notifications_outline),
            ),
          ),
        ],
      ),
      body: 
      ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(14),
        children: [
          // LOCATION CARD
          const Location(),
          const SizedBox(
            height: 15,
          ),
          
          // CATEGORIES
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recommendation",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(onPressed: () {}, child: const Text("View All"))
            ],
          ),
          const SizedBox(height: 10),
          const RecommendedParkings(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Nearby From You",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(onPressed: () {}, child: const Text("View All"))
            ],
          ),
          const SizedBox(height: 10),
          const NearbyParkings(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
