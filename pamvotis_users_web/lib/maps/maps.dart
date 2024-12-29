import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MapsUtils{

  MapsUtils._();

  static Future<void> openMapWithPosition(double latitude, double longitude) async {
    // String? googleMapUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    //
    // if(await launch(googleMapUrl)){
    //     await launch(googleMapUrl);
    // }
    // else {
    //   throw "Could not open the map.";
    // }
    String mapOptions = '$latitude,$longitude';

    final googleMapUrl = ('https://www.google.com/maps/search/?api=1&query=$mapOptions');
    Uri googleMapUrlUri = Uri.parse(googleMapUrl);

    if(!await launchUrl(googleMapUrlUri)){
      throw Exception('Could not launch $googleMapUrl');
    }
  }

  static Future<void> openMapWithAddress(String fullAddress) async{
      String query = Uri.encodeComponent(fullAddress);
      String googleMapUrl = "https://www.google.com/maps/search/?api=1&query=$query";

      if(await canLaunchUrlString(googleMapUrl)){
        await canLaunchUrlString(googleMapUrl);
      }
      else {
        throw "Could not open the map";
      }
  }
}