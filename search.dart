import 'package:flutter/material.dart';
import 'package:sparks_flutter/colors/colour.dart';


class JobSearchScreen extends StatefulWidget {
  @override
  _JobSearchScreenState createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              elevation: 0.7,
              automaticallyImplyLeading: true,
              backgroundColor: kLight_orange,
              actions: [
                IconButton(
                  icon: Icon(Icons.search),
                  color: Colors.white,
                  onPressed: () {
                    showSearch(context: context, delegate: JobSearch());
                  },
                )
              ],
            ),
            body: Container(
              child: Text("Search Here"),
            )));
  }
}

class JobSearch extends SearchDelegate<String>{
final searchSuggestion = ["Software Engineer", "Programmer","designer","data scientist"];

final recent = ["devops","web developer","app developer"];

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
   return [
     IconButton(
       icon: Icon(Icons.clear),
       color: Colors.red,
       onPressed: () {
        query = "";
       },
     )
   ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return
      IconButton(
        icon: AnimatedIcon(
           icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        color: Colors.red,
        onPressed: () {
                  close(context, null);
        },
      );

  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    final suggestionList = query.isEmpty ? recent:searchSuggestion.where((j) => j.startsWith(query)).toList();
    return ListView.builder(itemBuilder: (context,index)=>ListTile(
        leading: Icon(Icons.clear),
      title: Text(suggestionList[index]),

    ),
        itemCount: suggestionList.length
    );
  }
  
}