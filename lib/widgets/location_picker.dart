import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class LocationPicker extends StatefulWidget {
  final Function(String) onLocationPicked;

  const LocationPicker({Key? key, required this.onLocationPicked}) : super(key: key);

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late GoogleMapController mapController;
  LatLng? selectedLocation;
  String? locationAddress;

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      setState(() {
        locationAddress = "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (locationAddress != null) {
                widget.onLocationPicked(locationAddress!);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                mapController = controller;
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.7749, -122.4194), // Default to San Francisco
                zoom: 12.0,
              ),
              onTap: (position) async {
                setState(() {
                  selectedLocation = position;
                });
                await _getAddressFromLatLng(position);
              },
              markers: selectedLocation == null
                  ? {}
                  : {
                Marker(
                  markerId: MarkerId('selected-location'),
                  position: selectedLocation!,
                ),
              },
            ),
          ),
          if (locationAddress != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Selected Location: $locationAddress',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
