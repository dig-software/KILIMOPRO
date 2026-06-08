class FeedingRecord {
  final int? id;
  final String date;
  final double quantity;
  final String? feedType; // Optional: e.g., "Layers Mash", "Broiler Starter"

  FeedingRecord({
    this.id,
    required this.date,
    required this.quantity,
    this.feedType,
  });

  // Convert a FeedingRecord into a Map to store it in SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'quantity': quantity,
      'feedType': feedType,
    };
  }

  // Convert a Map from SQLite back into a FeedingRecord object
  factory FeedingRecord.fromMap(Map<String, dynamic> map) {
    return FeedingRecord(
      id: map['id'] as int?,
      date: map['date'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      feedType: map['feedType'] as String?,
    );
  }
}