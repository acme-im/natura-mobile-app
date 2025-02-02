import 'package:google_maps_webservice/places.dart';
import 'package:natura/models/location_address.dart';
import 'package:natura/utils/conf.dart';

// TODO: "mp" (Northern Mariana Islands) doesn't fit, API limits max amount of components to 5
const List<String> kUsTerritories = ['us', 'as', 'gu', 'pr', 'vi'];

class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}

class PlaceApiProvider {
  final String sessionToken;
  final client = GoogleMapsPlaces(apiKey: googleApiKey());

  PlaceApiProvider(this.sessionToken);

  Future<List<Suggestion>> fetchSuggestions(String input, String lang) async {
    final response = await client.autocomplete(
      input,
      language: lang,
      types: ['address'],
      components: kUsTerritories.map<Component>((e) => Component(Component.country, e)).toList(),
      sessionToken: sessionToken,
    );
    if (response.isOkay) {
      return response.predictions.map<Suggestion>((p) => Suggestion(p.placeId!, p.description!)).toList();
    } else if (response.hasNoResults) {
      return [];
    } else {
      throw Exception(response.errorMessage);
    }
  }

  Future<LocationAddress> getPlaceDetailFromId(String placeId) async {
    final response = await client.getDetailsByPlaceId(
      placeId,
      fields: [
        'name',
        'place_id',
        'address_component',
        'formatted_address'
      ], // TODO: drop "name", "place_id" (https://github.com/lejard-h/google_maps_webservice/issues/90#issuecomment-832409599)
      sessionToken: sessionToken,
    );

    if (response.isOkay) {
      final components = response.result.addressComponents;
      final place = LocationAddress(formatted: response.result.formattedAddress);
      for (var c in components) {
        final List type = c.types;
        if (type.contains('country')) {
          place.countryAbbr = c.shortName;
          place.countryName = c.longName;
        } else if (type.contains('street_number')) {
          place.streetNumber = c.longName;
        } else if (type.contains('route')) {
          place.street = c.longName;
        } else if (type.contains('locality')) {
          place.city = c.longName;
        } else if (type.contains('administrative_area_level_1')) {
          place.stateAbbr = c.shortName;
          place.stateName = c.longName;
        } else if (type.contains('postal_code')) {
          place.zipCode = c.longName;
        }
      }
      return place;
    } else {
      throw Exception(response.errorMessage);
    }
  }
}
