class NearbyParkingModel {
  final int id;
  final String name;
  final String address;
  final int totalSpots;
  final int availableSpots;
  final double pricePerHour;
  final String image;
  final double distance; 
  final double latitude; 
  final double longitude; 

  NearbyParkingModel({
    required this.id,
    required this.name,
    required this.address,
    required this.totalSpots,
    required this.availableSpots,
    required this.pricePerHour,
    required this.image,
    required this.distance,
    required this.latitude,
    required this.longitude,
  });

  factory NearbyParkingModel.fromJson(Map<String, dynamic> json) {
  return NearbyParkingModel(
    id: json['id'],
    name: json['name'],
    address: json['address'],
    totalSpots: json['total_spots'] ?? 0, // Provide a default value if null
    availableSpots: json['available_spots'] ?? 0, // Provide a default value if null
    pricePerHour: json['price_per_hour'] != null ? json['price_per_hour'].toDouble() : 0.0, // Convert to double, provide default value if null
    longitude: json['longitude'] != null ? json['longitude'].toDouble() : 0.0, // Convert to double, provide default value if null
    latitude: json['latitude'] != null ? json['latitude'].toDouble() : 0.0, // Convert to double, provide default value if null
    image: json['image'] ?? 'images/parkings/parking1.jpg',
    distance: json['distance'] != null ? json['distance'].toDouble() : 0.0, // Convert to double, provide default value if null
  );
}
}
