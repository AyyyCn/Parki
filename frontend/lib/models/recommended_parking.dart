// ignore_for_file: public_member_api_docs, sort_constructors_first
class RecommendedParkingModel {
  final String image;
  final double rating;
  final String location;
  RecommendedParkingModel({
    required this.image,
    required this.rating,
    required this.location,
  });
}

List<RecommendedParkingModel> recommendedParkings = [
  RecommendedParkingModel(
    image: "images/parkings/parking3.jpeg",
    rating: 4.4,
    location: "St. Regis Bora Bora",
  ),
    RecommendedParkingModel(
    image: "images/parkings/parking2.jpg",
    rating: 4.4,
    location: "St. Regis Bora Bora",
  ),
  RecommendedParkingModel(
    image: "images/parkings/parking1.jpg",
    rating: 4.4,
    location: "St. Regis Bora Bora",
  ),
  RecommendedParkingModel(
    image: "images/parkings/parking5.jpg",
    rating: 4.4,
    location: "St. Regis Bora Bora",
  ),
  
];