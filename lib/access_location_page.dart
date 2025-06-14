import 'package:flutter/material.dart';
import 'package:foodapp/core/colors/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart'; 
import 'package:geolocator/geolocator.dart';
import 'package:foodapp/main.dart'; 

class AccessLocationPage extends StatefulWidget {
  const AccessLocationPage({super.key});

  @override
  State<AccessLocationPage> createState() => _AccessLocationPageState();
}

class _AccessLocationPageState extends State<AccessLocationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'ACCESS LOCATION',
                textAlign: TextAlign.center,
                style: GoogleFonts.sen(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors1.slateGreyBlue, 
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'FOOD WILL ACCESS YOUR LOCATION ONLY WHILE USING THE APP',
                textAlign: TextAlign.center,
                style: GoogleFonts.sen(
                  fontSize: 16,
                  color: Colors1.trueGrey,
                ),
              ),
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.all(20),
           
                child: Image.asset(
                  'assets/icons/location_pin.jpg', 
                ),
              ),
              const SizedBox(height: 70),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors1.primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await _handleLocationPermissionAndAccess();
                  },
                  child: Text(
                    'ACCESS LOCATION',
                    style: GoogleFonts.sen(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Optionally, add a "Skip" or "Maybe Later" button
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLocationPermissionAndAccess() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      // Optionally, open app settings
      // await Geolocator.openAppSettings();
      return;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      // Do something with the position
      print('Current location: ${position.latitude}, ${position.longitude}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Location: Lat: ${position.latitude}, Lon: ${position.longitude}')));
      // Navigate to the next page, e.g., home page
      // context.go(AppRoutes.home); // Make sure AppRoutes.home is defined
    } catch (e) {
      print('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')));
    }
  }
}