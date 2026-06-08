import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapLocationPickerScreen extends StatefulWidget {
  final Function(double latitude, double longitude) onLocationSelected;

  const MapLocationPickerScreen({
    super.key,
    required this.onLocationSelected,
  });

  @override
  State<MapLocationPickerScreen> createState() => _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  late GoogleMapController mapController;
  LatLng? selectedLocation;
  Set<Marker> markers = {};
  bool isLoading = true;

  // Default location (Kenya center)
  static const LatLng defaultLocation = LatLng(-1.286389, 36.817223);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        selectedLocation = LatLng(position.latitude, position.longitude);
        isLoading = false;
        _addMarker(selectedLocation!);
      });

      mapController.animateCamera(
  CameraUpdate.newLatLngBounds(
    LatLngBounds(
      southwest: LatLng(position.latitude - 0.01, position.longitude - 0.01),
      northeast: LatLng(position.latitude + 0.01, position.longitude + 0.01),
    ),
    16.0, // Padding (in pixels) so your location isn't pinned right against the screen edge
  ),
);
    } catch (e) {
      setState(() {
        selectedLocation = defaultLocation;
        isLoading = false;
        _addMarker(defaultLocation);
      });
    }
  }

  void _addMarker(LatLng location) {
    setState(() {
      markers.clear();
      markers.add(
        Marker(
          markerId: MarkerId('farm_location'),
          position: location,
          infoWindow: const InfoWindow(title: 'Farm Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Farm Location',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: selectedLocation ?? defaultLocation,
                    zoom: 15,
                  ),
                  markers: markers,
                  onTap: (LatLng location) {
                    setState(() {
                      selectedLocation = location;
                      _addMarker(location);
                    });
                  },
                  zoomControlsEnabled: true,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      if (selectedLocation != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Selected Location',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Lat: ${selectedLocation!.latitude.toStringAsFixed(4)}\nLng: ${selectedLocation!.longitude.toStringAsFixed(4)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: selectedLocation != null
                              ? () {
                                  widget.onLocationSelected(
                                    selectedLocation!.latitude,
                                    selectedLocation!.longitude,
                                  );
                                  Navigator.pop(context);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ECC71),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Confirm Location',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
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
