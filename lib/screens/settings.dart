import 'package:flutter/material.dart';
import 'package:natura/engines/store.dart';
import 'package:natura/models/location_address.dart';
import 'package:natura/models/us_territory_info.dart';
import 'package:natura/screens/intro.dart';
import 'package:natura/screens/main_menu.dart';
import 'package:natura/screens/search_address.dart';
import 'package:natura/services/civic_info.dart';
import 'package:natura/services/places.dart';
import 'package:natura/utils/conf.dart';
import 'package:natura/utils/misc.dart';
import 'package:natura/widgets/location_address.dart';
import 'package:natura/widgets/us_territory_info.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

Future<void> _updateUsTerritoryInfo(LocationAddress? locationAddress) async {
  UsTerritoryInfo? usTerritoryInfo;
  if (locationAddress != null) {
    var state = locationAddress.countryAbbr == 'US' ? locationAddress.stateAbbr : locationAddress.countryAbbr;
    usTerritoryInfo = await UsTerritoryInfo.fromUrl(state: state);
    var repr = locationAddress.formatted != null ? await getRepresentative(locationAddress.formatted!) : null;
    usTerritoryInfo.setRepresentative(repr);
  }
  Conf().usTerritoryInfo = usTerritoryInfo;
}

Future<void> updateLocation(BuildContext context) async {
  final sessionToken = Uuid().v4();
  final result = await showSearch(
    context: context,
    delegate: AddressSearch(sessionToken),
  );
  LocationAddress? newLocationAddress;
  if (result != null) {
    newLocationAddress = await PlaceApiProvider(sessionToken).getPlaceDetailFromId(result.placeId);
  }
  Conf().locationAddress = newLocationAddress;
  await _updateUsTerritoryInfo(newLocationAddress);
}

class SettingsScreen extends StatefulWidget {
  static const routePath = '/settings';

  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _is6520 = Conf().is6520;
  bool _diversifyVoices = Conf().diversifyVoices;
  LocationAddress? _locationAddress = Conf().locationAddress;
  UsTerritoryInfo? _usTerritoryInfo = Conf().usTerritoryInfo;
  late Store _store;

  void purchaseListener(String productId, bool succeeded) {
    if (productId == kRemoveAdsProductId) {
      Conf().showAds = !succeeded;
    }
    setState(() {});
  }

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var args = ModalRoute.of(context)!.settings.arguments;
      if (args == IntroScreen.routePath) {
        await updateLocation(context);
        setState(() {
          _locationAddress = Conf().locationAddress;
          _usTerritoryInfo = Conf().usTerritoryInfo;
        });
      }
    });
    _initPackageInfo();
    _store = Store()..init([kRemoveAdsProductId], purchaseListener);
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Local settings'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.close,
            ),
            onPressed: () {
              if (ModalRoute.of(context)!.settings.arguments == IntroScreen.routePath) {
                Navigator.pushReplacementNamed(context, MainMenuScreen.routePath, arguments: SettingsScreen.routePath);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: LocationAddressWidget(locationAddress: _locationAddress),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.edit),
                        color: Colors.lightBlue,
                        highlightColor: Colors.grey,
                        onPressed: () async {
                          await updateLocation(context);
                          setState(() {
                            _locationAddress = Conf().locationAddress;
                            _usTerritoryInfo = Conf().usTerritoryInfo;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                UsTerritoryInfoWidget(usTerritoryInfo: _usTerritoryInfo),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width * 0.4,
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 10,
                              child:
                                  Text("I'm over 65 years old and/or I have lived in the US for more than 20 years."),
                            ),
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Checkbox(
                                  value: _is6520,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _is6520 = newValue!;
                                      Conf().is6520 = newValue;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 10,
                              child: Text('Diversify Question Voices'),
                            ),
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Switch(
                                  value: _diversifyVoices,
                                  onChanged: (value) {
                                    setState(() {
                                      _diversifyVoices = value;
                                      Conf().diversifyVoices = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        /* TODO: check why pause param is ignored in underlying module
                        Row(
                          children: [
                            Expanded(
                              flex: 10,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text('Response Timeout, s'),
                              ),
                            ),
                            NumberPicker(
                              axis: Axis.horizontal,
                              itemWidth: 50,
                              value: _responseTimeout,
                              minValue: DefaultSttResponseTimeout,
                              maxValue: 20,
                              onChanged: (newValue) {
                                setState(() {
                                  _responseTimeout = newValue;
                                  Conf().responseTimeout = newValue;
                                });
                              },
                            ),
                          ],
                        ),
                        */
                        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                          if (Conf().showAds)
                            TextButton(
                              onPressed: () async {
                                await logEvent(name: 'restore_purchases_tap');
                                await _store.restorePurchases();
                              },
                              child: Text('Restore Purchases'),
                            ),
                          // Text('|'),
                          TextButton(
                            onPressed: () {
                              launchUrl(Uri.parse('${appLandingUrl()}/privacy_policy.txt'));
                            },
                            child: Text('Privacy Policy'),
                          ),
                          // Text('|'),
                          Text('   V.${_packageInfo.version}+${_packageInfo.buildNumber}   '),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
