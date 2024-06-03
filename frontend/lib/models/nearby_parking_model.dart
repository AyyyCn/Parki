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
      totalSpots: json['totalSpots'],
      availableSpots: json['availableSpots'],
      pricePerHour: json['pricePerHour'],
      longitude: json['longitude'],
      latitude: json['latitude'],
      image: json['image'] ?? 'images/parkings/parking1.jpg',
      distance: json['distance'],
    );
  }
}
