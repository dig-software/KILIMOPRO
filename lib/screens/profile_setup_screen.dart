import 'package:flutter/material.dart';

class UserProfile {
  final String email;
  final String farmName;
  final int chickenStock;
  final int cattleStock;
  final int duckStock;
  final int goatStock;
  final double? latitude;
  final double? longitude;

  UserProfile({
    required this.email,
    required this.farmName,
    required this.chickenStock,
    required this.cattleStock,
    required this.duckStock,
    required this.goatStock,
    this.latitude,
    this.longitude,
  });

  UserProfile copyWith({
    String? email,
    String? farmName,
    int? chickenStock,
    int? cattleStock,
    int? duckStock,
    int? goatStock,
    double? latitude,
    double? longitude,
  }) {
    return UserProfile(
      email: email ?? this.email,
      farmName: farmName ?? this.farmName,
      chickenStock: chickenStock ?? this.chickenStock,
      cattleStock: cattleStock ?? this.cattleStock,
      duckStock: duckStock ?? this.duckStock,
      goatStock: goatStock ?? this.goatStock,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class ProfileSetupScreen extends StatefulWidget {
  final String email;
  final Function(UserProfile) onProfileCreated;

  const ProfileSetupScreen({
    super.key,
    required this.email,
    required this.onProfileCreated,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController farmNameController = TextEditingController();
  final TextEditingController chickenController = TextEditingController(text: '0');
  final TextEditingController cattleController = TextEditingController(text: '0');
  final TextEditingController duckController = TextEditingController(text: '0');
  final TextEditingController goatController = TextEditingController(text: '0');

  @override
  void dispose() {
    farmNameController.dispose();
    chickenController.dispose();
    cattleController.dispose();
    duckController.dispose();
    goatController.dispose();
    super.dispose();
  }

  void _createProfile() {
    if (farmNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your farm name')),
      );
      return;
    }

    final profile = UserProfile(
      email: widget.email,
      farmName: farmNameController.text,
      chickenStock: int.tryParse(chickenController.text) ?? 0,
      cattleStock: int.tryParse(cattleController.text) ?? 0,
      duckStock: int.tryParse(duckController.text) ?? 0,
      goatStock: int.tryParse(goatController.text) ?? 0,
    );

    widget.onProfileCreated(profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(
            color: Colors.black,
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
            const Text(
              'Welcome to kilimopro!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2ECC71),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Let\'s set up your farm profile',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Email Display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.email, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Text(
                    widget.email,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Farm Name Input
            const Text(
              'Farm Name',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: farmNameController,
              decoration: InputDecoration(
                hintText: 'Enter your farm name',
                filled: true,
                fillColor: Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Poultry Stock Title
            const Text(
              'Your Poultry & Livestock Stock',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2ECC71),
              ),
            ),
            const SizedBox(height: 16),

            // Chicken Stock
            _buildStockInput(
              label: 'Chickens',
              controller: chickenController,
              icon: Icons.egg,
            ),
            const SizedBox(height: 16),

            // Cattle Stock
            _buildStockInput(
              label: 'Cattle',
              controller: cattleController,
              icon: Icons.agriculture,
            ),
            const SizedBox(height: 16),

            // Duck Stock
            _buildStockInput(
              label: 'Ducks',
              controller: duckController,
              icon: Icons.pets,
            ),
            const SizedBox(height: 16),

            // Goat Stock
            _buildStockInput(
              label: 'Goats',
              controller: goatController,
              icon: Icons.agriculture,
            ),
            const SizedBox(height: 40),

            // Complete Setup Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Complete Setup',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2ECC71), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '0',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
