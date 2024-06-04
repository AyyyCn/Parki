import 'package:flutter/material.dart';
import 'package:frontend/widgets/search_parking_card.dart'; // Import the correct widget for each parking item
import 'package:ionicons/ionicons.dart';
import 'package:dio/dio.dart';
import 'package:frontend/models/nearby_parking_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<NearbyParkingModel> _searchResults = [];

  void _performSearch(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final dio = Dio();
      final response = await dio.get('http://10.0.2.2:8000/parking', queryParameters: {'name': query});
      if (response.statusCode == 200) {
        setState(() {
          _searchResults = (response.data as List).map((data) {
            return NearbyParkingModel(
              id: data['id'],
              name: data['name'],
              longitude: data['longitude'],
              latitude: data['latitude'],
              address: data['address'],
              totalSpots: data['total_spots'],
              availableSpots: data['available_spots'],
              pricePerHour: double.tryParse(data['price_per_hour'].toString()) ?? 0.0,
              image: data['image'] ?? 'images/parkings/parking1.jpg',
              distance: double.tryParse(data['distance'].toString()) ?? 0.0, // Assuming distance is provided
            );
          }).toList();
          _isSearching = false;
        });
      } else {
        throw Exception('Failed to load search results');
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching search results: $e')),
      );
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 102, 187, 236),
        foregroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Ionicons.close_circle),
                    onPressed: _clearSearch,
                  )
                : null,
          ),
          onChanged: (query) {
            if (query.isNotEmpty) {
              _performSearch(query);
            } else {
              setState(() {
                _searchResults.clear();
              });
            }
          },
        ),
      ),
      body: _isSearching
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _searchResults.isEmpty
              ? const Center(
                  child: Text(
                    'No results found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final parking = _searchResults[index];
                    return SearchParkingCard(parking: parking);
                  },
                ),
    );
  }
}
