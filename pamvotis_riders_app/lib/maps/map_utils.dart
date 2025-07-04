

import 'package:url_launcher/url_launcher.dart';

class MapUtils{
  MapUtils._();

  static void launchMapFromSourceToDestination(sourceLat, sourceLng, destinationLat, destinationLng) async {
    String mapOptions = [
      'saddr=$sourceLat,$sourceLng',
      'daddr=$destinationLat,$destinationLng',
      'dir_action=navigate'
    ].join('&');

    final mapUrl = 'https://www.google.com/maps?$mapOptions';

    if(await launchUrl(Uri.parse(mapUrl))){
      await launchUrl(Uri.parse(mapUrl));
    }
    else{
      throw "Could not launch $mapUrl";

    }
  }
}