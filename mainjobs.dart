import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:sparks_flutter/jobs/strings/jobs_Strings.dart';
import 'package:sparks_flutter/jobs/subScreens/details/jobDetails.dart';



class MainJobs extends StatefulWidget {
   MainJobs({
    Key key,
    this.showMainCard,
    this.showSearchCard,
    this.showFilterCard,
    this.jobSearchQuery,
    this.filterDisplayCard,
    this.jobsStreamController,
     this.listScrollController,
     this.jobsDocumentList
  });

  final bool showMainCard ;
  final bool showSearchCard ;
  final bool showFilterCard;
  final String jobSearchQuery;
  final StreamBuilder<QuerySnapshot> filterDisplayCard;
  StreamController<List<DocumentSnapshot>> jobsStreamController;
   ScrollController listScrollController = ScrollController();
   List<DocumentSnapshot> jobsDocumentList;
  @override
  _MainJobsState createState() => _MainJobsState();
}


class _MainJobsState extends State<MainJobs> {

  /// Function to capitalize the first character in a query string
  String capitalize(String word) {
    if (word == null) {
      throw ArgumentError("string: $word");
    }

    if (word.isEmpty) {
      return word;
    }

    return word[0].toUpperCase() + word.substring(1);
  }


  Stream _jobStreams;
  Stream _streamSearch;
  StreamBuilder<QuerySnapshot> filterDisplayCard;




  StreamController<List<DocumentSnapshot>> jobsStreamController = StreamController<List<DocumentSnapshot>>.broadcast();

  List<DocumentSnapshot> jobsDocumentList;



  int  check          = 0;
  bool shouldCheck    = false;
  bool shouldRunCheck = true;



  @override
  void initState() {
    super.initState();
    VariableStorage.changeStreamOfData = false;
//    _jobStreams = Firestore.instance
//        .collectionGroup('companyJobs')
//        .orderBy('time', descending: true)
//        .snapshots();

    //TODO: Initialize the filter display card
    filterDisplayCard = StreamBuilder<QuerySnapshot>(
        stream: _streamSearch,
        builder: (context, snapshot) {
          return NoResult(message: kFilterMessage,);
        });
    UserStorage.getCurrentUser();


    //TODO: Get stream of jobs for the search before the page loads
    _streamSearch = Firestore.instance.collectionGroup('companyJobs').snapshots();



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

          fetchNextTen();

        }

      }
      else {

        shouldRunCheck = true;

      }

    });

    fetchFirstTen();


  }

  Future fetchFirstTen() async {

    Firestore.instance
        .collectionGroup('companyJobs')
        .orderBy('time', descending: true)
        .snapshots()
        .asBroadcastStream().listen((data) => onChangeData(data.documentChanges));

    jobsDocumentList =

        (await Firestore.instance
            .collectionGroup('companyJobs')
            .orderBy('time', descending: true)
            .limit(3)
            .getDocuments())
            .documents;

    //_jobsDocumentList.sort( (a, b) => a['timestamp'].compareTo(b['timestamp']));

    setState(() {

      jobsStreamController.add(jobsDocumentList);

    });

  }

  fetchNextTen() async {

    if (shouldCheck) {

      shouldRunCheck = false;
      shouldCheck    = false;

      print('Check count: ${check.toString()}');

      check++;

      List<DocumentSnapshot> newDocumentList =

          (await Firestore.instance
              .collectionGroup('companyJobs')
              .orderBy('time', descending: true)
              .startAfterDocument(jobsDocumentList[jobsDocumentList.length - 1])
              .limit(3)
              .getDocuments())
              .documents;

      jobsDocumentList.addAll(newDocumentList);
      // _jobsDocumentList.sort( (a, b) => a['timestamp'].compareTo(b['timestamp']));

      setState(() {

        jobsStreamController.add(jobsDocumentList);

      });

    }



  }

  void onChangeData(List<DocumentChange> documentChanges) {

    var isChange = false;

    documentChanges.forEach(( change) {

      if (change.type == DocumentChangeType.removed) {

        jobsDocumentList.removeWhere( (job) {

          return change.document.documentID == job.documentID;

        });

        isChange = true;
      }
      else if (change.type == DocumentChangeType.modified) {

        int indexWhere = jobsDocumentList.indexWhere( (job) {

          return change.document.documentID == job.documentID;

        });

        if (indexWhere >= 0) {

          jobsDocumentList[indexWhere] = change.document;

        }

        isChange = true;

      }
      else if (change.type == DocumentChangeType.added) {

        jobsDocumentList.add(change.document);

        isChange = true;

      }

    });

    if (isChange) {

      // _jobsDocumentList.sort( (a, b) => a['timestamp'].compareTo(b['timestamp']));
      jobsStreamController.add(jobsDocumentList);

    }

  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();


  }


  Widget build(BuildContext context) {
    return ListView(
      //TODO: List of scrollable content for jobs.
      children: [
        //TODO: Displaying all jobs
        Visibility(
          visible: widget.showMainCard,
          child:  StreamBuilder(

              stream:VariableStorage.changeStreamOfData == false ? jobsStreamController.stream : widget.jobsStreamController.stream,

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
                        DocumentSnapshot singleJob = snapshot.data[index];

                        return JobCard(
                            companyLogo: singleJob.data['lur'],
                            jobTitle: singleJob.data['jtl'],
                            companyName: singleJob.data['cnm'],
                            jobLocation: singleJob.data['jlt'],
                            minSalary: singleJob.data['srn'],
                            maxSalary:singleJob.data['srx'],
                            jobType: singleJob.data['jtp'],
                            jobCategory: singleJob.data['jcg'],
                            jobTime: singleJob.data['jtm'],
                            jobId: singleJob.data['id'],
                            companyId: singleJob.data['cid'],
                            mainId:singleJob.data['mainId']
                        );
                      }

                  );
                }
              }
          ),
        ),

        //TODO: show job cards during search
        Visibility(
          visible: widget.showSearchCard,
          child: StreamBuilder<QuerySnapshot>(
            stream: _streamSearch,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final jobs = snapshot.data.documents.where((a) =>
                    a['jtl'].contains(capitalize(widget.jobSearchQuery)));
                if (jobs.isEmpty) {
                  return NoResult(message: kSearchResult,);
                } else {
                  List<Widget> cardWidgets = [];
                  for (var singleJob in jobs) {
                    final companyName = singleJob.data['cnm'];
                    final companyLogo = singleJob.data['lur'];
                    final jobLocation = singleJob.data['jlt'];
                    final jobTime = singleJob.data['jtm'];
                    final jobTitle = singleJob.data['jtl'];
                    final jobType = singleJob.data['jtp'];
                    final minSalary = singleJob.data['srn'];
                    final maxSalary = singleJob.data['srx'];
                    final jobId = singleJob.data['id'];
                    final jobCategory = singleJob.data['jcg'];
                    final companyId = singleJob.data['cid'];
                    final mainId = singleJob.data['mainId'];

                    final cardWidget = JobCard(
                        companyLogo: companyLogo,
                        jobTitle: jobTitle,
                        companyName: companyName,
                        jobLocation: jobLocation,
                        minSalary: minSalary,
                        maxSalary: maxSalary,
                        jobType: jobType,
                        jobCategory: jobCategory,
                        jobTime: jobTime,
                        jobId: jobId,
                        companyId: companyId,
                        mainId:mainId
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return NoResult(message: "Oops Something Went Wrong",);
              } else {
                return NoResult(message: "No Jobs Available",);
              }
            },
          ),
        ),

        //TODO: showing job cards after applying filters
        Visibility(
          visible: widget.showFilterCard,
          child: widget.filterDisplayCard,
        ),
      ],
    );
  }
}


//TODO: Job Card widget
class JobCard extends StatelessWidget {
  const JobCard({
    Key key,
    @required this.companyLogo,
    @required this.jobTitle,
    @required this.companyName,
    @required this.jobLocation,
    @required this.minSalary,
    @required this.maxSalary,
    @required this.jobType,
    @required this.jobCategory,
    @required this.jobTime,
    @required this.jobId,
    @required this.companyId,
    @required this.mainId,
  }) : super(key: key);

  final companyLogo;
  final mainId;
  final jobTitle;
  final jobLocation;
  final minSalary;
  final maxSalary;
  final companyName;
  final jobType;
  final jobCategory;
  final jobTime;
  final jobId;
  final companyId;

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
                        imageUrl: companyLogo,
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
                        child: Text(
                          ReusableFunctions.smallSentence(25, 25, jobTitle),
                          style:GoogleFonts.rajdhani(
                            textStyle:TextStyle(
                                fontSize:ScreenUtil().setSp(18.0),
                                fontWeight: FontWeight.bold,
                                color: Colors.black),),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: ScreenUtil().setSp(180),
                            minWidth: ScreenUtil().setSp(0),
                            minHeight: ScreenUtil().setSp(10)),
                        child: Padding(
                          padding: const EdgeInsets.only(top:8.0),
                          child: Text(
                            ReusableFunctions.smallSentence(25, 25, companyName),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style:GoogleFonts.rajdhani(
                              textStyle:TextStyle(
                                  fontSize:ScreenUtil().setSp(18.0),
                                  fontWeight: FontWeight.w500,
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
                          padding: const EdgeInsets.only(top:8.0),
                          child: Text(
                            ReusableFunctions.smallSentence(25, 25, jobLocation),
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
                      Padding(
                        padding: const EdgeInsets.only(top:8.0),
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
                                "\$${minSalary}k - \$${maxSalary}k",
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
                          padding: const EdgeInsets.only(bottom:15.0),
                          child: Text(
                            'Job Type',
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
                          padding: const EdgeInsets.only(bottom:12.0),
                          child: Text(
                            '$jobType - $jobCategory',
                            style:GoogleFonts.rajdhani(
                              textStyle:TextStyle(
                                  fontSize:ScreenUtil().setSp(13.0),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),),
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
                          child: Padding(
                            padding: const EdgeInsets.only(bottom:8.0),
                            child: Text(
                              jobTime,
                              style:GoogleFonts.rajdhani(
                                textStyle:TextStyle(
                                    fontSize:ScreenUtil().setSp(16.0),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange),),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          PostJobFormStorage.jobId = jobId;
                          PostJobFormStorage.companyId = companyId;
                          PostJobFormStorage.logoUrl= companyLogo;
                          PostJobFormStorage.jobType= jobType;
                          PostJobFormStorage.jobTitle= jobTitle;
                          PostJobFormStorage.jobCategory= jobCategory;
                          PostJobFormStorage.mainCompanyId = mainId;
                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: JobDetails()));
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
                                'Details',
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