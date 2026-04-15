class FeedItem {
  const FeedItem({
    required this.walkId,
    required this.ownerName,
    required this.dogName,
    required this.distanceKm,
    required this.steps,
    required this.endTime,
    required this.elapsed,
    this.dogImageUrl,
  });

  final int walkId;
  final String ownerName;
  final String dogName;
  final String? dogImageUrl;
  final double distanceKm;
  final int steps;
  final DateTime endTime;
  final Duration elapsed;
}
