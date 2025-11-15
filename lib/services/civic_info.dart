import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:google_geocoding_api/google_geocoding_api.dart';
import 'package:http/http.dart' as http;
import 'package:natura/utils/conf.dart';

Future<String?> getRepresentative(String address) async {
  // Also referred to as a congressman or congresswoman, each representative is elected to a two-year term serving the
  // people of a specific congressional district.
  try {
    final geocoding = GoogleGeocodingApi(googleApiKey());
    final geoResponse = await geocoding.search(address);

    if (geoResponse.results.isNotEmpty) {
      final geometry = geoResponse.results.first.geometry;
      if (geometry != null) {
        final location = geometry.location;
        final lat = location.lat;
        final lng = location.lng;

        final url =
            'https://v3.openstates.org/people.geo?lat=$lat&lng=$lng&include=sources&apikey=${openStatesApiKey()}';

        final response = await http.get(
          Uri.parse(url),
          headers: {'accept': 'application/json'},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['results'] != null && data['results'].isNotEmpty) {
            // Typically we're looking for the US House Representative
            final representative = data['results'].firstWhere(
              (person) =>
                  person['current_role'] != null &&
                  person['current_role']['title'] == 'Representative',
              orElse: () => null,
            );
            if (representative != null) {
              return representative['name'];
            }
          }
        }
      }
    }
    return null;
  } catch (e) {
    debugPrint(e.toString());
    return null;
  }
}
