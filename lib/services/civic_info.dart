import 'package:flutter/cupertino.dart';
import 'package:googleapis/civicinfo/v2.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:natura/utils/conf.dart';

Future<String?> getRepresentative(String address) async {
  // Also referred to as a congressman or congresswoman, each representative is elected to a two-year term serving the
  // people of a specific congressional district.
  final httpClient = clientViaApiKey(googleApiKey());
  try {
    final ci = CivicInfoApi(httpClient);
    final reprs = await ci.representatives
        .representativeInfoByAddress(address: address, includeOffices: true, levels: ['country']);
    return reprs.officials?.last.name;
  } catch (e) {
    debugPrint(e.toString());
    return null;
  } finally {
    httpClient.close();
  }
}
