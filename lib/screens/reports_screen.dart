import 'package:flutter/material.dart';

// Fixed to absolute package imports:
import 'package:kilimopro/database_helper.dart';
import 'package:kilimopro/expense_model.dart';
import 'package:kilimopro/feeding_model.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
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
          'Reports',
          style: TextStyle(
            color: Color(0xFF2ECC71),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      // We wrap the body in a FutureBuilder to read SQLite data
      body: FutureBuilder(
        future: Future.wait([
          DatabaseHelper.instance.fetchAllExpenses(),
          DatabaseHelper.instance.fetchAllFeedings(),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          // 1. Show a loading spinner while the database reads files
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2ECC71)),
            );
          }

          // 2. Fallback check if something goes wrong
          if (snapshot.hasError) {
            return Center(child: Text('Error loading reports: ${snapshot.error}'));
          }

          // 3. Extract lists safely from parallel data fetch (Fixes QueryResultSet Exception)
          final List<Expense> expenses = (snapshot.data?[0] as List?)
                  ?.map((e) => e is Expense ? e : Expense.fromMap(e as Map<String, dynamic>))
                  .toList() ?? [];

          final List<FeedingRecord> feedingLogs = (snapshot.data?[1] as List?)
                  ?.map((f) => f is FeedingRecord ? f : FeedingRecord.fromMap(f as Map<String, dynamic>))
                  .toList() ?? [];

          // 4. PERFORM THE REAL MATH CALCULATIONS
          double totalFeeds = feedingLogs.fold(0.0, (sum, item) => sum + item.quantity);
          double totalExpenses = expenses.fold(0.0, (sum, item) => sum + item.amount);
          
          // Calculate average daily cost dynamically based on unique entry dates
          final uniqueDays = expenses.map((e) => e.date.split('T')[0]).toSet().length;
          double avgDailyCost = uniqueDays > 0 ? totalExpenses / uniqueDays : totalExpenses;

          // 5. RENDER THE ORIGINAL UI USING DYNAMIC VALUES
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards Row
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'TOTAL FEEDS',
                        value: '${totalFeeds.toStringAsFixed(1)} kg',
                        backgroundColor: Colors.grey[300]!,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'TOTAL EXPENSES',
                        value: 'KES ${totalExpenses.toStringAsFixed(0)}',
                        backgroundColor: Colors.grey[300]!,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Weekly Expenses Chart Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'WEEKLY EXPENSES',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD32F2F),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 280,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.show_chart,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                expenses.isEmpty 
                                    ? 'No expense logs found yet' 
                                    : 'Chart Data Available (${expenses.length} logs)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Weekly Feeding Chart Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'WEEKLY FEEDING',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFDB913),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 280,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.show_chart,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                feedingLogs.isEmpty 
                                    ? 'No feeding logs found yet' 
                                    : 'Chart Data Available (${feedingLogs.length} logs)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Monthly Summary Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monthly Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryRow('Total Feed Used', '${totalFeeds.toStringAsFixed(1)} kg'),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Total Expenses', 'KES ${totalExpenses.toStringAsFixed(0)}'),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Avg Daily Cost', 'KES ${avgDailyCost.toStringAsFixed(0)}'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Bottom Navigation Buttons (Fixed RenderFlex overflow issue)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFDB913),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Go back',
                          style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Exporting report database entries...')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFDB913),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Export',
                          style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2ECC71),
          ),
        ),
      ],
    );
  }
}