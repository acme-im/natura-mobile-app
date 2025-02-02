import 'package:flutter/material.dart';
import 'package:natura/models/us_territory_info.dart';
import 'package:natura/widgets/image.dart';

class UsTerritoryInfoWidget extends StatefulWidget {
  final UsTerritoryInfo? _usTerritoryInfo;

  const UsTerritoryInfoWidget({super.key, UsTerritoryInfo? usTerritoryInfo})
      : _usTerritoryInfo = usTerritoryInfo;

  @override
  _UsTerritoryInfoWidgetState createState() => _UsTerritoryInfoWidgetState();
}

Widget personInfoWidget(final String? name, final String? photoUrl, final String? party) {
  return Card(
    elevation: 1,
    clipBehavior: Clip.antiAlias,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        imageWidget(
          photoUrl,
          height: 64,
          width: 64,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name ?? 'N/A',
                  style: TextStyle(
                    fontSize: 16,
                  )),
              if (party != null) Text(party),
            ],
          ),
        ),
      ],
    ),
  );
}

class _UsTerritoryInfoWidgetState extends State<UsTerritoryInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget._usTerritoryInfo?.capital != null) // check if D.C.
              Card(
                elevation: 1,
                clipBehavior: Clip.antiAlias,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    imageWidget(
                      widget._usTerritoryInfo?.skylineBackgroundUrl,
                      height: 64.0,
                      width: 128.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget._usTerritoryInfo!.capital!,
                              style: TextStyle(
                                fontSize: 16,
                              )),
                          Text('State capital'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0),
              child: Text(
                'YOUR REPRESENTATIVE',
                style: TextStyle(fontSize: 12.0),
              ),
            ),
            personInfoWidget(widget._usTerritoryInfo?.representative?.name,
                widget._usTerritoryInfo?.representative?.photoUrl, widget._usTerritoryInfo?.representative?.party),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0),
              child: Text(
                'YOUR SENATORS',
                style: TextStyle(fontSize: 12.0),
              ),
            ),
            if (widget._usTerritoryInfo?.senators != null)
              ...widget._usTerritoryInfo!.senators!
                  .map<Widget>((e) => personInfoWidget(e.name, e.photoUrl, e.party))
                  
            else
              personInfoWidget(null, null, null),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0),
              child: Text(
                'YOUR GOVERNOR',
                style: TextStyle(fontSize: 12.0),
              ),
            ),
            personInfoWidget(widget._usTerritoryInfo?.governor?.name, widget._usTerritoryInfo?.governor?.photoUrl,
                widget._usTerritoryInfo?.governor?.party),
          ],
        ),
      ),
      // ),
    );
  }
}
