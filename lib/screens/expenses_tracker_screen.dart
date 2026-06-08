import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'reports_screen.dart'; // This is fine since it lives in the same screens folder

// Fixed to absolute package imports:
import 'package:kilimopro/database_helper.dart';
import 'package:kilimopro/expense_model.dart';

class ExpensesTrackerScreen extends StatefulWidget {
  const ExpensesTrackerScreen({super.key});

  @override
  State<ExpensesTrackerScreen> createState() => _ExpensesTrackerScreenState();
}

class _ExpensesTrackerScreenState extends State<ExpensesTrackerScreen> {
  final TextEditingController itemController = TextEditingController();
  final TextEditingController costController = TextEditingController();

  DateTime? selectedDate;
  DateTime today = DateTime.now();
  List<ExpenseEntry> expenseEntries = [];

  @override
  void initState() {
    super.initState();
    _loadExpensesFromDatabase(); // Load data from disk on screen startup
  }

  @override
  void dispose() {
    itemController.dispose();
    costController.dispose();
    super.dispose();
  }

  // Fetch from SQLite and sync it with our local UI state table array
  Future<void> _loadExpensesFromDatabase() async {
    final databaseRecords = await DatabaseHelper.instance.fetchAllExpenses();
    setState(() {
      expenseEntries = databaseRecords.map((record) {
        return ExpenseEntry(
          id: record.id,
          item: record.category,
          cost: record.amount,
          date: DateTime.parse(record.date),
        );
      }).toList();
    });
  }

  void _saveExpenseEntry() async {
    if (itemController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter item name')),
      );
      return;
    }
    if (costController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter cost')),
      );
      return;
    }
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    // 1. Map UI input fields to our SQLite Data Model format
    final newDbExpense = Expense(
      category: itemController.text,
      amount: double.parse(costController.text),
      date: selectedDate!.toIso8601String(),
    );

    // 2. Insert into the local device storage asynchronously
    await DatabaseHelper.instance.insertExpense(newDbExpense);

    // 3. Clear text fields and re-load our records list cleanly
    itemController.clear();
    costController.clear();
    setState(() {
      selectedDate = null;
    });

    _loadExpensesFromDatabase();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense saved permanently!')),
      );
    }
  }

  void _removeExpenseEntry(int index) async {
    final entryId = expenseEntries[index].id;
    
    if (entryId != null) {
      // Delete directly from database file via primary key ID autoincrement
      await DatabaseHelper.instance.deleteExpense(entryId);
      _loadExpensesFromDatabase(); // Refresh layout items
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry removed from storage')),
        );
      }
    }
  }

  double _getTotalExpenses() {
    return expenseEntries.fold(0, (sum, entry) => sum + entry.cost);
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
          'Expenses Tracker',
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
            // Item Input
            const Text(
              'Item',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: itemController,
              decoration: InputDecoration(
                hintText: 'Enter item name',
                filled: true,
                fillColor: Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Cost Input
            const Text(
              'Cost',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: costController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter cost amount',
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
                  onPressed: _saveExpenseEntry,
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
                    'Save Expense',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedDate = null;
                      itemController.clear();
                      costController.clear();
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

            // Expense Entries Section
            if (expenseEntries.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Expenses:',
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
                        DataColumn(label: Text('Item')),
                        DataColumn(label: Text('Cost')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: expenseEntries.asMap().entries.map((entry) {
                        int index = entry.key;
                        ExpenseEntry item = entry.value;
                        return DataRow(cells: [
                          DataCell(Text(item.item)),
                          DataCell(Text('KES ${item.cost.toStringAsFixed(2)}')),
                          DataCell(
                            Text(item.date.toLocal().toString().split(' ')[0]),
                          ),
                          DataCell(
                            GestureDetector(
                              onTap: () => _removeExpenseEntry(index),
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
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF2ECC71)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Expenses:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'KES ${_getTotalExpenses().toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2ECC71),
                          ),
                        ),
                      ],
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
                    // After returning back from the reports screen, pull records cleanly
                    ).then((_) => _loadExpensesFromDatabase());
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

// Updated data class structure to track primary keys safely from SQLite
class ExpenseEntry {
  final int? id;
  final String item;
  final double cost;
  final DateTime date;

  ExpenseEntry({
    this.id,
    required this.item,
    required this.cost,
    required this.date,
  });
}