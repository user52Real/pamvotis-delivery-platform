// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:pamvotis_riders_app/global/global.dart';
//
//
// class UserLocation{
//
//
//   getCurrentLocation() async {
//     LocationPermission permission = await Geolocator.requestPermission();
//     Position newPosition = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.bestForNavigation,
//     );
//     position = newPosition;
//     placeMarks = await placemarkFromCoordinates(
//       position!.latitude,
//       position!.longitude,
//     );
//
//     Placemark pMark = placeMarks![0];
//
//     completeAddress = '${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';
//
//   }
// }


import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../global/global.dart';

class UserLocation {
  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    // Define location settings
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 10,
    );

    // Get current position
    Position newPosition = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
    position = newPosition;

    // Get placemark from coordinates
    List<Placemark> placeMarksList = await placemarkFromCoordinates(
      position!.latitude,
      position!.longitude,
    );

    if (placeMarksList.isNotEmpty) {
      Placemark pMark = placeMarksList[0];
      completeAddress = '${pMark.subThoroughfare ?? ''} ${pMark.thoroughfare ?? ''}, '
          '${pMark.subLocality ?? ''} ${pMark.locality ?? ''}, '
          '${pMark.subAdministrativeArea ?? ''}, ${pMark.administrativeArea ?? ''} '
          '${pMark.postalCode ?? ''}, ${pMark.country ?? ''}';
    } else {
      completeAddress = 'Address not found';
    }
  }
}