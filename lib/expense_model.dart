class Expense {
  final int? id;
  final String category;
  final double amount;
  final String date;

  Expense({
    this.id,
    required this.category,
    required this.amount,
    required this.date,
  });

  // Convert an Expense object into a Map (for saving to the database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'date': date,
    };
  }

  // Create an Expense object from a Map (for reading from the database)
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: map['date'] as String,
    );
  }
}