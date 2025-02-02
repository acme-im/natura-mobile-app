import 'package:flutter/material.dart';
import 'package:natura/services/places.dart';
import 'package:natura/utils/misc.dart';

class AddressSearch extends SearchDelegate<Suggestion?> {
  final String sessionToken;

  AddressSearch(this.sessionToken) {
    apiClient = PlaceApiProvider(sessionToken);
  }

  late PlaceApiProvider apiClient;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(
          Icons.clear,
          size: 24,
          color: Colors
              .white, // TODO White for now. Next fix: clear input string onPressed, color: blue, hidden when input string empty
        ),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildResults(BuildContext context) {
    return SizedBox.shrink();
  }

  @override
  Widget buildLeading(BuildContext context) {
    return SizedBox.shrink(); // empty widget
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
        future: query == '' ? null : apiClient.fetchSuggestions(query, Localizations.localeOf(context).languageCode),
        builder: (context, AsyncSnapshot<List<Suggestion>> snapshot) {
          if (query == '') {
            return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width * 0.4,
                            maxWidth: MediaQuery.of(context).size.width * 0.8),
                        child: Text(
                          'NaturaTest contains questions about your local elected officials. Enter your full residential address to see your local information or press SKIP button below to exclude these questions from the test.',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                          ),
                        ),
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      close(context, null);
                      await logEvent(name: 'search_address_skip');
                    },
                    child: Text('SKIP'),
                  ),
                ]);
          } else {
            if (snapshot.hasData) {
              var data = snapshot.data!;
              return Container(
                child: ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    title: Text((data[index]).description),
                    onTap: () async {
                      await logEvent(name: 'search_address_found');
                      close(context, data[index]);
                    },
                  ),
                  itemCount: data.length,
                ),
              );
            } else {
              return Container(child: Text('Searching for address...'));
            }
          }
        });
  }
}
