class NearbyParkingModel {
  final int id;
  final String name;
  final String address;
  final int totalSpots;
  final int availableSpots;
  final double pricePerHour;
  final String image;
  final double distance; 

  NearbyParkingModel({
    required this.id,
    required this.name,
    required this.address,
    required this.totalSpots,
    required this.availableSpots,
    required this.pricePerHour,
    required this.image,
    required this.distance,
  });

  factory NearbyParkingModel.fromJson(Map<String, dynamic> json) {
    return NearbyParkingModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      totalSpots: json['totalSpots'],
      availableSpots: json['availableSpots'],
      pricePerHour: json['pricePerHour'],
      image: json['image'] ?? 'images/parkings/parking1.jpg',
      distance: json['distance'],
    );
  }
}
