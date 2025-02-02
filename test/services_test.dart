import 'package:flutter_test/flutter_test.dart';
import 'package:natura/services/civic_info.dart';
import 'package:natura/services/places.dart';
import 'package:uuid/uuid.dart';

void main() {
  test('get representative by address', () async {
    assert(await getRepresentative('9171 WILSHIRE BLVD, BEVERLY HILLS, CA, 90210') == 'Ted Lieu');
    assert(await getRepresentative('669 Pilgrim Dr., Foster City, CA, 94404') == 'Jackie Speier');
    assert(await getRepresentative('1710 Rhode Island Ave NW #12 Washington, District of Columbia(DC), 20036') ==
        'Eleanor Holmes Norton');
    assert(await getRepresentative('100 Woodrose Pl, Lahaina, HI 96761, USA') == "Kaiali'i \"Kai\" Kahele");
    assert(await getRepresentative('1105 King Street Christiansted, VI 00820') == null);
    assert(await getRepresentative('1834 Kongens Gade Charlotte Amalie, St Thomas 00802') == null);
    assert(await getRepresentative('1155 Pale San Vitores Road, Tumon, Guam, United States, 96913-4206') == null);
  });

  test('get suggestions by address', () async {
    final sessionToken = Uuid().v4();
    var apiClient = PlaceApiProvider(sessionToken);
    var repr = await apiClient.fetchSuggestions('669 Pilgrim', 'en');
    assert(repr.length > 1);
  });
}
