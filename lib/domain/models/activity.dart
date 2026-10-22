class Activity {
  const Activity({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.location,
    required this.maxPeople,
    required this.price,
  });

  final String id;
  final String title;
  final String imageUrl;
  final String category;
  final String location;
  final int maxPeople;
  final double price;
}
