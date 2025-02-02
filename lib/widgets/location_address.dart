import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:natura/models/location_address.dart';

class LocationAddressWidget extends StatefulWidget {
  final LocationAddress? _locationAddress;

  const LocationAddressWidget({super.key, LocationAddress? locationAddress})
      : _locationAddress = locationAddress;

  @override
  _LocationAddressWidgetState createState() => _LocationAddressWidgetState();
}

class _LocationAddressWidgetState extends State<LocationAddressWidget> {
  String _title(LocationAddress? locationAddress) {
    var title = '';
    if (locationAddress == null) {
      title = 'Tap EDIT icon to enter address';
    } else {
      var isState = locationAddress.countryAbbr == 'US' && locationAddress.stateAbbr != 'DC';
      if (isState) {
        title = 'State of ${locationAddress.stateName}';
      } else {
        if (locationAddress.stateAbbr == 'DC') {
          title = 'Washington, D.C.';
        } else {
          title = locationAddress.countryName!; // US Territory
        }
      }
    }
    return title;
  }

  String _subTitle(LocationAddress? locationAddress) {
    var subTitle = '';
    if (locationAddress == null) {
      subTitle = 'and see local representatives information.';
    } else {
      if (locationAddress.street != null) {
        if (locationAddress.streetNumber != null) {
          subTitle += '${locationAddress.streetNumber} ';
        }
        subTitle += '${locationAddress.street}';
      }
      if (locationAddress.city != null && locationAddress.stateAbbr != 'DC') {
        subTitle += ', ${locationAddress.city}';
      }
      if (locationAddress.stateAbbr != null) {
        subTitle += ', ${locationAddress.stateAbbr}';
      }
      if (locationAddress.zipCode != null) {
        subTitle += ' ${locationAddress.zipCode}';
      }
    }
    return subTitle;
  }

  @override
  Widget build(BuildContext context) {
    var hasInfo = widget._locationAddress != null;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FractionallySizedBox(
          widthFactor: 0.8,
          child: Text(
            _title(widget._locationAddress),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: hasInfo ? MediaQuery.of(context).size.width * 0.06 : MediaQuery.of(context).size.width * 0.04,
            ),
          ),
        ),
        FractionallySizedBox(
          widthFactor: 0.8,
          child: Text(
            _subTitle(widget._locationAddress),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.04,
            ),
          ),
        ),
      ],
    );
  }
}
