import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sparks_flutter/jobs/colors/colors.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sparks_flutter/jobs/components/generalComponent.dart';
import 'package:sparks_flutter/jobs/screens/cardTest.dart';
import 'package:sparks_flutter/jobs/subScreens/resume/resume.dart';


class Professional1 extends StatefulWidget {
   Professional1({
    Key key,
    this.professionalsStreamController,
    this.professionalsDocumentList,
    this.listScrollController,
    this.pShowMainCard,
    this.pShowSearchCard,
    this.pShowFilterCard,
    this.professionalSearchQuery,
    this.pFilterDisplayCard,
  });

  final bool pShowMainCard ;
  final bool pShowSearchCard ;
  final bool pShowFilterCard;
  final String professionalSearchQuery;
  final StreamBuilder<QuerySnapshot> pFilterDisplayCard;

  StreamController<List<DocumentSnapshot>> professionalsStreamController;
  ScrollController listScrollController = ScrollController();
  List<DocumentSnapshot> professionalsDocumentList;

  @override
  _Professional1State createState() => _Professional1State();
}



class _Professional1State extends State<Professional1> {
  Stream _professionalStreams;
  Stream _streamSearch;


  StreamController<List<DocumentSnapshot>> professionalsStreamController = StreamController<List<DocumentSnapshot>>.broadcast();

  List<DocumentSnapshot> professionalsDocumentList;



  int  check          = 0;
  bool shouldCheck    = false;
  bool shouldRunCheck = true;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    VariableStorage.changeProfessionalStreamOfData = false;



    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top, SystemUiOverlay.bottom]);



    widget.listScrollController.addListener(() {

      bool   outOfRange    = widget.listScrollController.position.outOfRange;
      double offset        = widget.listScrollController.offset;
      double maxScroll     = widget.listScrollController.position.maxScrollExtent;

      //double currentScroll = listScrollController.position.pixels;
      //double delta         = MediaQuery.of(context).size.height * 0.20;

      if (offset >= maxScroll && !outOfRange) {

        shouldCheck = true;

        if (shouldRunCheck) {

          fetchProfessionalsNextTen();

        }

      }
      else {

        shouldRunCheck = true;

      }

    });

    fetchProfessionalsFirstTen();











//    _professionalStreams = Firestore.instance
//        .collectionGroup('professionals')
//        .orderBy('time', descending: true)
//        .snapshots();
//TODO: Get stream of professionals for the search before the page loads
    _streamSearch = Firestore.instance.collection('professionals').snapshots();



  }


  //TODO: for professional custom pagination function

  Future fetchProfessionalsFirstTen() async {

    Firestore.instance
        .collectionGroup('professionals')
        .orderBy('time', descending: true)
        .snapshots()
        .asBroadcastStream().listen((data) => onChangeDataOfProfessionals(data.documentChanges));

    professionalsDocumentList =

        (await Firestore.instance
            .collectionGroup('professionals')
            .orderBy('time', descending: true)
            .limit(3)
            .getDocuments())
            .documents;



    setState(() {

      professionalsStreamController.add(professionalsDocumentList);

    });

  }

  fetchProfessionalsNextTen() async {

    if (shouldCheck) {

      shouldRunCheck = false;
      shouldCheck    = false;

      print('Check count: ${check.toString()}');

      check++;

      List<DocumentSnapshot> newProfessionalsDocumentList =

          (await Firestore.instance
              .collectionGroup('professionals')
              .orderBy('time', descending: true)
              .startAfterDocument(professionalsDocumentList[professionalsDocumentList.length - 1])
              .limit(3)
              .getDocuments())
              .documents;

      professionalsDocumentList.addAll(newProfessionalsDocumentList);


      setState(() {

        professionalsStreamController.add(professionalsDocumentList);

      });

    }


  }

  void onChangeDataOfProfessionals(List<DocumentChange> documentChanges) {

    var isChange = false;

    documentChanges.forEach(( change) {

      if (change.type == DocumentChangeType.removed) {

        professionalsDocumentList.removeWhere( (professional) {

          return change.document.documentID == professional.documentID;

        });

        isChange = true;
      }
      else if (change.type == DocumentChangeType.modified) {

        int indexWhere = professionalsDocumentList.indexWhere( (professional) {

          return change.document.documentID == professional.documentID;

        });

        if (indexWhere >= 0) {

          professionalsDocumentList[indexWhere] = change.document;

        }

        isChange = true;

      }
      else if (change.type == DocumentChangeType.added) {

        professionalsDocumentList.add(change.document);

        isChange = true;

      }

    });

    if (isChange) {

      professionalsStreamController.add(professionalsDocumentList);

    }

  }




  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        //TODO: Displaying all professionals
        Visibility(
          visible: widget.pShowMainCard,
          child:  StreamBuilder(

              stream:VariableStorage.changeProfessionalStreamOfData == false ? professionalsStreamController.stream : widget.professionalsStreamController.stream,

              builder: (context, snapshot) {

                if (snapshot.data == null) {

                  return Center(
                    child: Container( child: Column(
                      children: [
                        CircularProgressIndicator(
                          backgroundColor: Colors.black,
                        ),
                        Text("Loading"),
                      ],
                    ),),

                  );

                }
                else {
                  return ListView.builder (
                      physics: NeverScrollableScrollPhysics(), ///
                      shrinkWrap: true, ///
                      scrollDirection: Axis.vertical, //
                      padding: EdgeInsets.all (10.0),

                      itemCount: snapshot.data.length,

                      itemBuilder: (context, index) {
                        DocumentSnapshot professional = snapshot.data[index];
                        return  ProfessionalCard(
                          professionalProfile: professional.data['imageUrl'],
                          professionalName: professional.data['name'],
                          jobTitle: professional.data['pTitle'],
                          professionalLocation: professional.data['location'],
                          jobCategory: professional.data['ajc'],
                          jobType: professional.data['ajt'],
                          professionalId: professional.data['userId'],
                          date:professional.data['date'],
                          status: professional.data['status'],
                          minSalary: professional.data['srn'],
                          maxSalary: professional.data['srx'],
                        );
                      }

                  );
                }
              }
          ),
        ),

        //TODO: show professional cards during search
        Visibility(
          visible: widget.pShowSearchCard,
          child: StreamBuilder<QuerySnapshot>(
            stream: _streamSearch,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final professionals = snapshot.data.documents.where((a) =>
                    a['pTitle'].contains(ReusableFunctions.capitalizeWords(widget.professionalSearchQuery)));
                if(professionals.isEmpty){
                  return NoResult(message: "No Result",);
                }else{
                  List<Widget> cardWidgets = [];
                  for (var professional in professionals) {
                    final professionalName = professional.data['name'];
                    final professionalProfile = professional.data['imageUrl'];
                    final professionalLocation = professional.data['location'];
                    final date = professional.data['date'];
                    final jobTitle = professional.data['pTitle'];
                    final jobType = professional.data['ajt'];
                    final professionalId = professional.data['userId'];
                    final jobCategory = professional.data['ajc'];
                    final status = professional.data['status'];
                    final minSalary = professional.data['srn'];
                    final maxSalary = professional.data['srx'];


                    final cardWidget = ProfessionalCard(
                      professionalProfile: professionalProfile,
                      professionalName: professionalName,
                      jobTitle: jobTitle,
                      professionalLocation: professionalLocation,
                      jobCategory: jobCategory,
                      jobType: jobType,
                      professionalId: professionalId,
                      date:date,
                      status: status,
                      minSalary: minSalary,
                      maxSalary: maxSalary,
                    );
                    cardWidgets.add(cardWidget);
                  }
                  return Column(
                    children: cardWidgets,
                  );
                }
              } else if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),

        //TODO: showing job cards after applying filters
        Visibility(
          visible: widget.pShowFilterCard,
          child: widget.pFilterDisplayCard,
        ),
      ],),
    );
  }
}

class ProfessionalCard extends StatelessWidget {
  const ProfessionalCard({
    Key key,
    @required this.professionalProfile,
    @required this.professionalName,
    @required this.jobTitle,
    @required this.professionalLocation,
    @required this.jobCategory,
    @required this.jobType,
    @required this.professionalId,
    @required this.date,
    @required this.status,
    @required this.minSalary,
    @required this.maxSalary,
  });

  final  professionalProfile;
  final String professionalName;
  final  jobTitle;
  final  professionalLocation;
  final  jobCategory;
  final  jobType;
  final professionalId;
  final date;
  final status;
  final minSalary;
  final maxSalary;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 3,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth:  double.infinity,
              minHeight: ScreenUtil().setSp(150)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              color: Colors.white,
            ),
            child: Padding(
              padding:EdgeInsets.only(right:10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(10.0, 15.0, 0.0, 15.0),
                    height: ScreenUtil().setHeight(50.0),
                    width: ScreenUtil().setWidth(50),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 32,
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: professionalProfile,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                          fit: BoxFit.cover,
                          width: 40.0,
                          height: 40.0,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: ScreenUtil().setSp(180),
                              minWidth: ScreenUtil().setSp(0),
                              minHeight: ScreenUtil().setSp(10)),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom:8.0),
                            child: Text(
                              ReusableFunctions.smallSentence(25, 25, professionalName),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style:GoogleFonts.rajdhani(
                                textStyle:TextStyle(
                                    fontSize:ScreenUtil().setSp(15.0),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),),
                            ),
                          ),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: ScreenUtil().setSp(180),
                              minWidth: ScreenUtil().setSp(0),
                              minHeight: ScreenUtil().setSp(10)),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom:8.0),
                            child: Text(
                              ReusableFunctions.smallSentence(25, 25, jobTitle),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style:GoogleFonts.rajdhani(
                                textStyle:TextStyle(
                                    fontSize:ScreenUtil().setSp(15.0),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),),
                            ),
                          ),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: ScreenUtil().setSp(180),
                              minWidth: ScreenUtil().setSp(0),
                              minHeight: ScreenUtil().setSp(10)),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom:8.0),
                            child: Text(
                              ReusableFunctions.smallSentence(25, 25, professionalLocation),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style:GoogleFonts.rajdhani(
                                textStyle:TextStyle(
                                    fontSize:ScreenUtil().setSp(15.0),
                                    fontWeight: FontWeight.bold,
                                    color: kShade),),
                            ),
                          ),
                        ),
                        GestureDetector(
                            onTap: (){
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      child: CardTest()));
                            },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: kNavBg,
                            ),
                            // margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                            height: ScreenUtil().setHeight(30.0),
                            width: ScreenUtil().setWidth(120.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.star,
                                  color:Colors.yellow,
                                  size:  ScreenUtil().setSp(14.0),
                                ),
                                Text(
                                  status,
                                  style:GoogleFonts.rajdhani(
                                    textStyle:TextStyle(
                                        fontSize:ScreenUtil().setSp(14.0),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom:8.0),
                            child: Text(
                              'Available For',
                              style:GoogleFonts.rajdhani(
                                textStyle:TextStyle(
                                    fontSize:ScreenUtil().setSp(18.0),
                                    fontWeight: FontWeight.bold,
                                    color: kMore),),
                            ),
                          ),
                        ),
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom:8.0),
                            child: Text(
                              '$jobCategory  -  $jobType',
                              style:GoogleFonts.rajdhani(
                                textStyle:TextStyle(
                                    fontSize:ScreenUtil().setSp(13.0),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),),
                            ),
                          ),
                        ),
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom:8.0),
                            child: Text(
                              '\$$minSalary - \$$maxSalary',
                              style:GoogleFonts.rajdhani(
                                textStyle:TextStyle(
                                    fontSize:ScreenUtil().setSp(16.0),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange),),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            ProfessionalStorage.id = professionalId;
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: Resume()));
                          },
                          child:  Container(

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.red,
                            ),
                            // margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                            height: ScreenUtil().setHeight(30.0),
                            width: ScreenUtil().setWidth(90.0),

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Resume',
                                  textAlign: TextAlign.center,
                                  style:GoogleFonts.rajdhani(
                                    textStyle:TextStyle(
                                        fontSize:ScreenUtil().setSp(18.0),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
  }
}
