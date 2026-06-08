import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:kilimopro/database_helper.dart'; // Changed to absolute package import
import 'reports_screen.dart'; // This is fine since reports is in the same folder // Ensure this points to your database helper file

class FeedingTrackerScreen extends StatefulWidget {
  const FeedingTrackerScreen({super.key});

  @override
  State<FeedingTrackerScreen> createState() => _FeedingTrackerScreenState();
}

class _FeedingTrackerScreenState extends State<FeedingTrackerScreen> {
  final TextEditingController feedTypeController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  DateTime? selectedDate;
  DateTime today = DateTime.now();
  List<FeedingEntry> feedingEntries = [];

  @override
  void initState() {
    super.initState();
    _loadFeedingsFromDatabase(); // Load history from database when screen loads
  }

  @override
  void dispose() {
    feedTypeController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  // Fetch histories directly from SQLite local file
  Future<void> _loadFeedingsFromDatabase() async {
    final databaseRecords = await DatabaseHelper.instance.fetchAllFeedings();
    setState(() {
      feedingEntries = databaseRecords.map((record) {
        return FeedingEntry(
          id: record['id'] as int?,
          feedType: record['feedType'] as String,
          quantity: record['quantity'].toString(),
          date: DateTime.parse(record['date'] as String),
        );
      }).toList();
    });
  }

  void _saveFeedingEntry() async {
    if (feedTypeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter feed type')),
      );
      return;
    }
    if (quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter quantity')),
      );
      return;
    }
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    // 1. Pack state properties into a Map format structured for SQL tables
    Map<String, dynamic> row = {
      'feedType': feedTypeController.text,
      'quantity': quantityController.text,
      'date': selectedDate!.toIso8601String(),
    };

    // 2. Commit transaction asynchronously to local device file path
    await DatabaseHelper.instance.insertFeeding(row);

    // 3. Clear UI entry components and force layout hydration reload
    feedTypeController.clear();
    quantityController.clear();
    setState(() {
      selectedDate = null;
    });

    _loadFeedingsFromDatabase();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feeding entry saved permanently')),
      );
    }
  }

  void _removeFeedingEntry(int index) async {
    final entryId = feedingEntries[index].id;

    if (entryId != null) {
      // Direct physical row removal matching autoincrement ID primary key value
      await DatabaseHelper.instance.deleteFeeding(entryId);
      _loadFeedingsFromDatabase(); // Refresh local view array configuration

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry removed from storage')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Feeding Tracker',
          style: TextStyle(
            color: Color(0xFF2ECC71),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Feed Type Input
            const Text(
              'Feed type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: feedTypeController,
              decoration: InputDecoration(
                hintText: 'Enter feed type',
                filled: true,
                fillColor: Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quantity Input
            const Text(
              'Quantity',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter quantity',
                filled: true,
                fillColor: Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Calendar Picker for Date Selection
            const Text(
              'Date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TableCalendar(
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                focusedDay: selectedDate ?? today,
                selectedDayPredicate: (day) {
                  return selectedDate != null &&
                      day.day == selectedDate!.day &&
                      day.month == selectedDate!.month &&
                      day.year == selectedDate!.year;
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    selectedDate = selectedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF2ECC71),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: const TextStyle(color: Colors.red),
                  defaultTextStyle: const TextStyle(color: Colors.black),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Selected Date Display
            if (selectedDate != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2ECC71)),
                ),
                child: Text(
                  'Selected: ${selectedDate!.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2ECC71),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _saveFeedingEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Save Feeding',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedDate = null;
                      feedTypeController.clear();
                      quantityController.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Feeding Entries Table Header
            if (feedingEntries.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Feeding History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Feed Type')),
                        DataColumn(label: Text('Quantity')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: feedingEntries.asMap().entries.map((entry) {
                        int index = entry.key;
                        FeedingEntry item = entry.value;
                        return DataRow(cells: [
                          DataCell(Text(item.feedType)),
                          DataCell(Text(item.quantity)),
                          DataCell(
                            Text(item.date.toLocal().toString().split(' ')[0]),
                          ),
                          DataCell(
                            GestureDetector(
                              onTap: () => _removeFeedingEntry(index),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),

            // Bottom Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFDB913),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Go back',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReportsScreen(),
                      ),
                    ).then((_) => _loadFeedingsFromDatabase()); // Reload state data if changes occurred on the reports page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFDB913),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'View reports',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Updated locally to handle nullable IDs generated inside SQLite files automatically
class FeedingEntry {
  final int? id;
  final String feedType;
  final String quantity;
  final DateTime date;

  FeedingEntry({
    this.id,
    required this.feedType,
    required this.quantity,
    required this.date,
  });
}