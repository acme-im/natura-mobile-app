import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:natura/models/civics_test.dart';
import 'package:natura/models/civics_test_question.dart';
import 'package:natura/utils/conf.dart';
import 'package:natura/utils/misc.dart';

const String title = 'Civics Test QnA';

class Item {
  Item({
    required this.headerValue,
    required this.expandedValue,
    this.isExpanded = true,
  });

  List<String> headerValue;
  List<String> expandedValue;
  bool isExpanded;
}

List<Item> generateItems(List<CivicsTestQuestion> questions) {
  return questions.map((q) {
    return Item(
      headerValue: [q.id.toString(), q.text],
      expandedValue: q.answers,
    );
  }).toList();
}

class CivicsTestQnAScreen extends StatefulWidget {
  static const routePath = '/civics_test/qna';

  const CivicsTestQnAScreen({super.key});

  @override
  CivicsTestQnAScreenState createState() => CivicsTestQnAScreenState();
}

class CivicsTestQnAScreenState extends State<CivicsTestQnAScreen> {
  final TextEditingController _searchController = TextEditingController();
  Icon _searchIcon = Icon(Icons.search);
  Widget _appBarTitle = Text(title);

  List<Item> _data = [];
  List<Item> _dataFiltered = [];

  // ExpansionPanelList key. Must be updated when list changes (https://github.com/flutter/flutter/issues/13780)
  Key eplKey = Key('pending');

  void _filterData() async {
    var query = _searchController.text.toLowerCase();
    if (query.length > 3) {
      await logEvent(name: 'qna_search');
      setState(() {
        _dataFiltered = _data
            .where((element) =>
                element.headerValue[1].toLowerCase().contains(query) ||
                element.expandedValue.any((element) => element.toLowerCase().contains(query)))
            .toList();
      });
      eplKey = Key(_dataFiltered.length.toString());
    } else if (_dataFiltered.length != _data.length) {
      setState(() {
        _dataFiltered = [..._data];
      });
      eplKey = Key(_dataFiltered.length.toString());
    }
  }

  Widget _answerWidget(final String text, final int color) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        border: Border.all(color: Color(color)),
      ),
      child: Text(text),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    var usTerritoryInfo = Conf().usTerritoryInfo;
    CivicsTest.fromUrl(
      state: usTerritoryInfo?.abbr,
      representative: usTerritoryInfo?.representative,
      is6520: Conf().is6520,
      shuffle: false,
    ).then((CivicsTest ct) {
      setState(() {
        _data = generateItems(ct.questionnaire);
        if (!kReleaseMode) _data = _data.sublist(0, 10); // because rendering is very slow in Debug mode
        _dataFiltered = [..._data];
      });
      eplKey = Key(_dataFiltered.length.toString());
      _searchController.addListener(_filterData);
    });
  }

  void _searchPressed() {
    setState(() {
      if (_searchIcon.icon == Icons.search) {
        _searchIcon = Icon(Icons.close);
        _appBarTitle = TextField(
          controller: _searchController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search',
          ),
        );
      } else {
        _searchIcon = Icon(Icons.search);
        _appBarTitle = Text(title);
        _dataFiltered = [..._data];
        eplKey = Key(_dataFiltered.length.toString());
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: _appBarTitle,
        actions: <Widget>[
          IconButton(
            icon: _searchIcon,
            onPressed: _searchPressed,
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            Container(
              child: _buildPanelList(),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildPanelList() {
    return ExpansionPanelList(
      key: eplKey,
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _dataFiltered[index].isExpanded = !isExpanded;
        });
      },
      children: _dataFiltered.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
          canTapOnHeader: true,
          headerBuilder: (BuildContext context, bool isExpanded) {
            return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Q${item.headerValue[0]}:',
                    style: TextStyle(
                      fontSize: 24.0,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                    child: Text(item.headerValue[1]),
                  ),
                ),
              ]),
            ]);
          },
          body: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [...item.expandedValue.map((e) => _answerWidget(e, 0xffbbdefb))],
                ),
              ),
            ),
          ),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}
