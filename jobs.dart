import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sparks_flutter/colors/colour.dart';
import 'package:sparks_flutter/dimens/dimens.dart';
import 'package:sparks_flutter/jobs/colors/colors.dart';
import 'package:sparks_flutter/jobs/components/generalBottomBar.dart';
import 'package:sparks_flutter/jobs/components/generalComponent.dart';
import 'package:sparks_flutter/jobs/components/navBarComponent.dart';
import 'package:sparks_flutter/jobs/screens/companies.dart';
import 'package:sparks_flutter/jobs/screens/employment1.dart';
import 'package:sparks_flutter/jobs/screens/mainJobs.dart';
import 'package:sparks_flutter/jobs/screens/professional.dart';
import 'package:sparks_flutter/jobs/subScreens/company/CreateCompanyAccount/entry.dart';
import 'package:sparks_flutter/jobs/subScreens/professionals/entry.dart';
import 'package:sparks_flutter/sparks_enums/fab_enum.dart';
import 'package:sparks_flutter/sparks_enums/sparks_bottom_munus_enums.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sparks_flutter/jobs/strings/jobs_Strings.dart';
import 'package:sparks_flutter/jobs/subScreens/resume/resume.dart';



class Jobs extends StatefulWidget {
  @override
  _JobsState createState() => _JobsState();
}

class _JobsState extends State<Jobs>
    with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController _tabController;
  //TODO: setting up the controller for controlling the search inputs.
  TextEditingController controller = TextEditingController();




  //TODO: Bottom navigation variables
  SparksBottomMenu bottomMenuPressed = SparksBottomMenu.JOBS;
  FabActivity fabCurrentState;
  bool isPressed;



  //TODO: Declare and initializing the filter variables
  /// string variable for setting the two radio buttons to true or false
  String jobTypeGroupValue = "In-Person";
  /// I am setting the In-Person button to true by default
  String jobType = "In-Person";

  ///  string variable for setting the three check buttons to true or false
  ///  and I am setting the fullTimeCheckboxValue to true by default
  bool fullTimeCheckboxValue = true;
  bool partTimeCheckboxValue = false;
  bool contractCheckboxValue = false;
  bool disableFilter = false;


  /// string variable for storing filter values
  String fullTimeValue = "Full-Time";
  String partTimeValue = "Part-Time";
  String contractValue = "Contract";
  String jobLocation;
  String mainMinSalary;
  String minSalary;
  var _dateTime;
  bool hideFilter = false;
  StreamBuilder<QuerySnapshot> filterDisplayCard;
  StreamBuilder<QuerySnapshot>pFilterDisplayCard;


  //TODO: function to capitalize first letter of the search queries
  String capitalize(String word) {
    if (word == null) {
      throw ArgumentError("string: $word");
    }

    if (word.isEmpty) {
      return word;
    }

    return word[0].toUpperCase() + word.substring(1);
  }


  //TODO: Get values for the Job type details
  void changeJobTypeState(value) {
    if (value == "In-Person") {
      setState(() {
        jobTypeGroupValue = "In-Person";
        jobType = "In-Person";
      });
    } else if (value == "Remote") {
      setState(() {
        jobTypeGroupValue = "Remote";
        jobType = "Remote";
      });
    }
    print(jobType);
  }


  //TODO: The filter function without location and Date
  void filterFunction() {
    //TODO: Run seven possible queries for the 3 checkboxes when the are set to true or checked
    //TODO: Set the query result to the filter display card and set other display card to false once condition returns true

    //TODO: setting minSalary to Default if null
    if (minSalary == null) {
      setState(() {
        mainMinSalary = kMainMinimum;
      });
    } else {
      setState(() {
        mainMinSalary = minSalary;
      });
    }

    //TODO:
    if (fullTimeCheckboxValue == true &&
        partTimeCheckboxValue == false &&
        contractCheckboxValue == false) {
      setState(() {
        print('first');
        print(_dateTime);
        //.where("jlt", isEqualTo: capitalize(jobLocation)) which can be added to the filter later
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg", whereIn: [fullTimeValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId:mainId);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == true &&
        partTimeCheckboxValue == true &&
        contractCheckboxValue == false) {
      setState(() {
        print('second');
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg",
              whereIn: [fullTimeValue, partTimeValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == true &&
        partTimeCheckboxValue == true &&
        contractCheckboxValue == true) {
      setState(() {
        print('third');
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg", whereIn: [
            fullTimeValue,
            partTimeValue,
            contractValue
          ]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == false &&
        partTimeCheckboxValue == true &&
        contractCheckboxValue == false) {
      setState(() {
        print("fourth");
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg", whereIn: [partTimeValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == false &&
        partTimeCheckboxValue == true &&
        contractCheckboxValue == true) {
      setState(() {
        print('five');
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg",
              whereIn: [partTimeValue, contractValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == false &&
        partTimeCheckboxValue == false &&
        contractCheckboxValue == true) {
      setState(() {
        print('six');
        print(mainMinSalary);
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg", whereIn: [contractValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == true &&
        partTimeCheckboxValue == false &&
        contractCheckboxValue == true) {
      setState(() {
        print('seven');
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg",
              whereIn: [fullTimeValue, contractValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else {
      print('why empty');
      setState(() {
        showFilterCard = false;
        showMainCard = true;
        showSearchCard = false;
      });
    }
    //TODO: Else show a flutter toast showing no value checked
  }


  //TODO: The filter function with location and Date
  void locationAndDateFilterFunction() {
    // TODO: Run seven possible queries for the 3 checkboxes when the are set to true or checked
    //TODO: Set the query result to the filter display card and set other display card to false once condition returns true

    //TODO: setting minSalary to Default if null
    if (minSalary == null) {
      setState(() {
        mainMinSalary = kMainMinimum;
      });
    } else {
      setState(() {
        mainMinSalary = minSalary;
      });
    }


    //TODO:
    if (fullTimeCheckboxValue == true &&
        partTimeCheckboxValue == false &&
        contractCheckboxValue == false) {
      setState(() {
        print('first');
        print(_dateTime);
        ///.where("jlt", isEqualTo: capitalize(jobLocation)) which can be added to the filter later
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("jlt", isEqualTo: capitalize(jobLocation))
              .where("jtm",
              isEqualTo:
              DateFormat("yyyy-MM-dd").format(_dateTime).toString())
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg", whereIn: [fullTimeValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == true &&
        partTimeCheckboxValue == true &&
        contractCheckboxValue == false) {
      setState(() {
        print('second');
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("jlt", isEqualTo: capitalize(jobLocation))
              .where("jtm",
              isEqualTo:
              DateFormat("yyyy-MM-dd").format(_dateTime).toString())
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg",
              whereIn: [fullTimeValue, partTimeValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == true &&
        partTimeCheckboxValue == true &&
        contractCheckboxValue == true) {
      setState(() {
        print('third');
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("jlt", isEqualTo: capitalize(jobLocation))
              .where("jtm",
              isEqualTo:
              DateFormat("yyyy-MM-dd").format(_dateTime).toString())
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg", whereIn: [
            fullTimeValue,
            partTimeValue,
            contractValue
          ]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == false &&
        partTimeCheckboxValue == true &&
        contractCheckboxValue == false) {
      setState(() {
        print("fourth");
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("jlt", isEqualTo: capitalize(jobLocation))
              .where("jtm",
              isEqualTo:
              DateFormat("yyyy-MM-dd").format(_dateTime).toString())
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg", whereIn: [partTimeValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == false &&
        partTimeCheckboxValue == true &&
        contractCheckboxValue == true) {
      setState(() {
        print('five');
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("jlt", isEqualTo: capitalize(jobLocation))
              .where("jtm",
              isEqualTo:
              DateFormat("yyyy-MM-dd").format(_dateTime).toString())
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg",
              whereIn: [partTimeValue, contractValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == false &&
        partTimeCheckboxValue == false &&
        contractCheckboxValue == true) {
      setState(() {
        print('six');
        print(mainMinSalary);
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("jlt", isEqualTo: capitalize(jobLocation))
              .where("jtm",
              isEqualTo:
              DateFormat("yyyy-MM-dd").format(_dateTime).toString())
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg", whereIn: [contractValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == true &&
        partTimeCheckboxValue == false &&
        contractCheckboxValue == true) {
      setState(() {
        print('seven');
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("jlt", isEqualTo: capitalize(jobLocation))
              .where("jtm",
              isEqualTo:
              DateFormat("yyyy-MM-dd").format(_dateTime).toString())
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg",
              whereIn: [fullTimeValue, contractValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else {
      print('why empty');
      setState(() {
        showFilterCard = false;
        showMainCard = true;
        showSearchCard = false;
      });
    }
    //TODO: Else show a flutter toast showing no value checked
  }


  //TODO: The filter function with location only
  void locationFilterFunction() {
    //TODO: Run seven possible queries for the 3 checkboxes when the are set to true or checked
    //TODO: Set the query result to the filter display card and set other display card to false once condition returns true

    //TODO: setting minSalary to Default if null
    if (minSalary == null) {
      setState(() {
        mainMinSalary = kMainMinimum;
      });
    } else {
      setState(() {
        mainMinSalary = minSalary;
      });
    }

    //TODO:
    if (fullTimeCheckboxValue == true &&
        partTimeCheckboxValue == false &&
        contractCheckboxValue == false) {
      setState(() {
        print('first');
        print(_dateTime);
        ///.where("jlt", isEqualTo: capitalize(jobLocation)) which can be added to the filter later
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("jlt", isEqualTo: capitalize(jobLocation))
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg", whereIn: [fullTimeValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == true &&
        partTimeCheckboxValue == true &&
        contractCheckboxValue == false) {
      setState(() {
        print('second');
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("jlt", isEqualTo: capitalize(jobLocation))
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg",
              whereIn: [fullTimeValue, partTimeValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == true &&
        partTimeCheckboxValue == true &&
        contractCheckboxValue == true) {
      setState(() {
        print('third');
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("jlt", isEqualTo: capitalize(jobLocation))
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg", whereIn: [
            fullTimeValue,
            partTimeValue,
            contractValue
          ]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == false &&
        partTimeCheckboxValue == true &&
        contractCheckboxValue == false) {
      setState(() {
        print("fourth");
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("jlt", isEqualTo: capitalize(jobLocation))

              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg", whereIn: [partTimeValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == false &&
        partTimeCheckboxValue == true &&
        contractCheckboxValue == true) {
      setState(() {
        print('five');
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("jlt", isEqualTo: capitalize(jobLocation))
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg",
              whereIn: [partTimeValue, contractValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == false &&
        partTimeCheckboxValue == false &&
        contractCheckboxValue == true) {
      setState(() {
        print('six');
        print(mainMinSalary);
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("jlt", isEqualTo: capitalize(jobLocation))

              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg", whereIn: [contractValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == true &&
        partTimeCheckboxValue == false &&
        contractCheckboxValue == true) {
      setState(() {
        print('seven');
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("jlt", isEqualTo: capitalize(jobLocation))
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg",
              whereIn: [fullTimeValue, contractValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else {
      print('why empty');
      setState(() {
        showFilterCard = false;
        showMainCard = true;
        showSearchCard = false;
      });
    }
    //TODO: Else show a flutter toast showing no value checked
  }


  //TODO: The filter function with date only
  void dateFilterFunction() {
    // TODO: Run seven possible queries for the 3 checkboxes when the are set to true or checked
    //TODO: Set the query result to the filter display card and set other display card to false once condition returns true

    //TODO: setting minSalary to Default if null
    if (minSalary == null) {
      setState(() {
        mainMinSalary = kMainMinimum;
      });
    } else {
      setState(() {
        mainMinSalary = minSalary;
      });
    }

    //TODO:
    if (fullTimeCheckboxValue == true &&
        partTimeCheckboxValue == false &&
        contractCheckboxValue == false) {
      setState(() {
        print('first');
        print(_dateTime);
        /// which can be added to the filter later
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("jtm",
              isEqualTo:
              DateFormat("yyyy-MM-dd").format(_dateTime).toString())
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg", whereIn: [fullTimeValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == true &&
        partTimeCheckboxValue == true &&
        contractCheckboxValue == false) {
      setState(() {
        print('second');
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("jtm",
              isEqualTo:
              DateFormat("yyyy-MM-dd").format(_dateTime).toString())
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg",
              whereIn: [fullTimeValue, partTimeValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == true &&
        partTimeCheckboxValue == true &&
        contractCheckboxValue == true) {
      setState(() {
        print('third');
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("jtm",
              isEqualTo:
              DateFormat("yyyy-MM-dd").format(_dateTime).toString())
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg", whereIn: [
            fullTimeValue,
            partTimeValue,
            contractValue
          ]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == false &&
        partTimeCheckboxValue == true &&
        contractCheckboxValue == false) {
      setState(() {
        print("fourth");
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("jtm",
              isEqualTo:
              DateFormat("yyyy-MM-dd").format(_dateTime).toString())
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg", whereIn: [partTimeValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == false &&
        partTimeCheckboxValue == true &&
        contractCheckboxValue == true) {
      setState(() {
        print('five');
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("jtm",
              isEqualTo:
              DateFormat("yyyy-MM-dd").format(_dateTime).toString())
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg",
              whereIn: [partTimeValue, contractValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == false &&
        partTimeCheckboxValue == false &&
        contractCheckboxValue == true) {
      setState(() {
        print('six');
        print(mainMinSalary);
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("jtm",
              isEqualTo:
              DateFormat("yyyy-MM-dd").format(_dateTime).toString())
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg", whereIn: [contractValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else if (fullTimeCheckboxValue == true &&
        partTimeCheckboxValue == false &&
        contractCheckboxValue == true) {
      setState(() {
        print('seven');
        filterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collectionGroup('companyJobs')
              .where("jtp", isEqualTo: jobType)
              .where("jtm",
              isEqualTo:
              DateFormat("yyyy-MM-dd").format(_dateTime).toString())
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("jcg",
              whereIn: [fullTimeValue, contractValue]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return NoResult(message: kFilterMessage,);
            } else {
              final jobs = snapshot.data.documents;
              if (jobs.isEmpty) {
                return NoResult(message: kFilterMessage,);
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
                  mainId: mainId,);
                  cardWidgets.add(cardWidget);
                }
                return Column(
                  children: cardWidgets,
                );
              }
            }
          },
        );
        showFilterCard = true;
        showMainCard = false;
        showSearchCard = false;
      });
    } else {
      print('why empty');
      setState(() {
        showFilterCard = false;
        showMainCard = true;
        showSearchCard = false;
      });
    }
    //TODO: Else show a flutter toast showing no value checked
  }


  //TODO: professional location filter functionality
  void professionalLocationQuery(){
      //TODO: Run seven possible queries for the 3 checkboxes when the are set to true or checked
      //TODO: Set the query result to the filter display card and set other display card to false once condition returns true

      //TODO: setting minSalary to Default if null
      if (minSalary == null) {
        setState(() {
          mainMinSalary = kMainMinimum;
        });
      } else {
        setState(() {
          mainMinSalary = minSalary;
        });
      }

      //TODO:
      if (fullTimeCheckboxValue == true &&
          partTimeCheckboxValue == false &&
          contractCheckboxValue == false) {
        setState(() {
          print('first');
          pFilterDisplayCard = StreamBuilder<QuerySnapshot>(
            stream:  Firestore.instance.collection('professionals')
              .where("ajt", isEqualTo: jobType)
              .where("location", isEqualTo: capitalize(jobLocation))
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("ajc", whereIn: [fullTimeValue]).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final professionals = snapshot.data.documents;
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
          );
           showProfessionalMainCard = false;
           showProfessionalSearchCard = false;
           showProfessionalFilterCard = true;
        });
      } else if (fullTimeCheckboxValue == true &&
          partTimeCheckboxValue == true &&
          contractCheckboxValue == false) {
        setState(() {
          print('second');
          pFilterDisplayCard = StreamBuilder<QuerySnapshot>(
            stream:  Firestore.instance.collection('professionals')
                .where("ajt", isEqualTo: jobType)
                .where("location", isEqualTo: capitalize(jobLocation))
                .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
                .where("ajc", whereIn: [fullTimeValue,partTimeValue]).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final professionals = snapshot.data.documents;
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
          );
          showProfessionalMainCard = false;
          showProfessionalSearchCard = false;
          showProfessionalFilterCard = true;
        });
      } else if (fullTimeCheckboxValue == true &&
          partTimeCheckboxValue == true &&
          contractCheckboxValue == true) {
        setState(() {
          print('third');
          pFilterDisplayCard = StreamBuilder<QuerySnapshot>(
            stream:  Firestore.instance.collection('professionals')
                .where("ajt", isEqualTo: jobType)
                .where("location", isEqualTo: capitalize(jobLocation))
                .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
                .where("ajc", whereIn: [fullTimeValue,partTimeValue,contractValue]).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final professionals = snapshot.data.documents;
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
          );
          showProfessionalMainCard = false;
          showProfessionalSearchCard = false;
          showProfessionalFilterCard = true;
        });
      } else if (fullTimeCheckboxValue == false &&
          partTimeCheckboxValue == true &&
          contractCheckboxValue == false) {
        setState(() {
          print("fourth");
          pFilterDisplayCard = StreamBuilder<QuerySnapshot>(
            stream:  Firestore.instance.collection('professionals')
                .where("ajt", isEqualTo: jobType)
                .where("location", isEqualTo: capitalize(jobLocation))
                .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
                .where("ajc", whereIn: [partTimeValue]).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final professionals = snapshot.data.documents;
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
          );
          showProfessionalMainCard = false;
          showProfessionalSearchCard = false;
          showProfessionalFilterCard = true;
        });
      } else if (fullTimeCheckboxValue == false &&
          partTimeCheckboxValue == true &&
          contractCheckboxValue == true) {
        setState(() {
          print('five');
          pFilterDisplayCard = StreamBuilder<QuerySnapshot>(
            stream:  Firestore.instance.collection('professionals')
                .where("ajt", isEqualTo: jobType)
                .where("location", isEqualTo: capitalize(jobLocation))
                .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
                .where("ajc", whereIn: [partTimeValue,contractValue]).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final professionals = snapshot.data.documents;
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
          );
          showProfessionalMainCard = false;
          showProfessionalSearchCard = false;
          showProfessionalFilterCard = true;
        });
      } else if (fullTimeCheckboxValue == false &&
          partTimeCheckboxValue == false &&
          contractCheckboxValue == true) {
        setState(() {
          print('six');
          print(mainMinSalary);
          pFilterDisplayCard = StreamBuilder<QuerySnapshot>(
            stream:  Firestore.instance.collection('professionals')
                .where("ajt", isEqualTo: jobType)
                .where("location", isEqualTo: capitalize(jobLocation))
                .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
                .where("ajc", whereIn: [contractValue]).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final professionals = snapshot.data.documents;
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
          );
          showProfessionalMainCard = false;
          showProfessionalSearchCard = false;
          showProfessionalFilterCard = true;
        });
      } else if (fullTimeCheckboxValue == true &&
          partTimeCheckboxValue == false &&
          contractCheckboxValue == true) {
        setState(() {
          print('seven');
          pFilterDisplayCard = StreamBuilder<QuerySnapshot>(
            stream:  Firestore.instance.collection('professionals')
                .where("ajt", isEqualTo: jobType)
                .where("location", isEqualTo: capitalize(jobLocation))
                .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
                .where("ajc", whereIn: [fullTimeValue,contractValue]).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final professionals = snapshot.data.documents;
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
          );
          showProfessionalMainCard = false;
          showProfessionalSearchCard = false;
          showProfessionalFilterCard = true;
        });
      } else {
        print('why empty');
        setState(() {
          showProfessionalMainCard = true;
          showProfessionalSearchCard = false;
          showProfessionalFilterCard = false;
        });
      }
      //TODO: Else show a flutter toast showing no value checked
    }


    //TODO: Normal professional filter functonality
  void normalProfessionalFilter(){
    //TODO: Run seven possible queries for the 3 checkboxes when the are set to true or checked
    //TODO: Set the query result to the filter display card and set other display card to false once condition returns true

    //TODO: setting minSalary to Default if null
    if (minSalary == null) {
      setState(() {
        mainMinSalary = kMainMinimum;
      });
    } else {
      setState(() {
        mainMinSalary = minSalary;
      });
    }

    //TODO:
    if (fullTimeCheckboxValue == true &&
        partTimeCheckboxValue == false &&
        contractCheckboxValue == false) {
      setState(() {
        print('first');
        pFilterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream:  Firestore.instance.collection('professionals')
              .where("ajt", isEqualTo: jobType)
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("ajc", whereIn: [fullTimeValue]).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final professionals = snapshot.data.documents;
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
        );
        showProfessionalMainCard = false;
        showProfessionalSearchCard = false;
        showProfessionalFilterCard = true;
      });
    } else if (fullTimeCheckboxValue == true &&
        partTimeCheckboxValue == true &&
        contractCheckboxValue == false) {
      setState(() {
        print('second');
        pFilterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream:  Firestore.instance.collection('professionals')
              .where("ajt", isEqualTo: jobType)
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("ajc", whereIn: [fullTimeValue,partTimeValue]).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final professionals = snapshot.data.documents;
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
        );
        showProfessionalMainCard = false;
        showProfessionalSearchCard = false;
        showProfessionalFilterCard = true;
      });
    } else if (fullTimeCheckboxValue == true &&
        partTimeCheckboxValue == true &&
        contractCheckboxValue == true) {
      setState(() {
        print('third');
        pFilterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream:  Firestore.instance.collection('professionals')
              .where("ajt", isEqualTo: jobType)
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("ajc", whereIn: [fullTimeValue,partTimeValue,contractValue]).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final professionals = snapshot.data.documents;
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
        );
        showProfessionalMainCard = false;
        showProfessionalSearchCard = false;
        showProfessionalFilterCard = true;
      });
    } else if (fullTimeCheckboxValue == false &&
        partTimeCheckboxValue == true &&
        contractCheckboxValue == false) {
      setState(() {
        print("fourth");
        pFilterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream:  Firestore.instance.collection('professionals')
              .where("ajt", isEqualTo: jobType)
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("ajc", whereIn: [partTimeValue]).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final professionals = snapshot.data.documents;
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
        );
        showProfessionalMainCard = false;
        showProfessionalSearchCard = false;
        showProfessionalFilterCard = true;
      });
    } else if (fullTimeCheckboxValue == false &&
        partTimeCheckboxValue == true &&
        contractCheckboxValue == true) {
      setState(() {
        print('five');
        pFilterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream:  Firestore.instance.collection('professionals')
              .where("ajt", isEqualTo: jobType)
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("ajc", whereIn: [partTimeValue,contractValue]).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final professionals = snapshot.data.documents;
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
        );
        showProfessionalMainCard = false;
        showProfessionalSearchCard = false;
        showProfessionalFilterCard = true;
      });
    } else if (fullTimeCheckboxValue == false &&
        partTimeCheckboxValue == false &&
        contractCheckboxValue == true) {
      setState(() {
        print('six');
        print(mainMinSalary);
        pFilterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream:  Firestore.instance.collection('professionals')
              .where("ajt", isEqualTo: jobType)
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("ajc", whereIn: [contractValue]).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final professionals = snapshot.data.documents;
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
        );
        showProfessionalMainCard = false;
        showProfessionalSearchCard = false;
        showProfessionalFilterCard = true;
      });
    } else if (fullTimeCheckboxValue == true &&
        partTimeCheckboxValue == false &&
        contractCheckboxValue == true) {
      setState(() {
        print('seven');
        pFilterDisplayCard = StreamBuilder<QuerySnapshot>(
          stream:  Firestore.instance.collection('professionals')
              .where("ajt", isEqualTo: jobType)
              .where("srn", isGreaterThanOrEqualTo: mainMinSalary)
              .where("ajc", whereIn: [fullTimeValue,contractValue]).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final professionals = snapshot.data.documents;
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
        );
        showProfessionalMainCard = false;
        showProfessionalSearchCard = false;
        showProfessionalFilterCard = true;
      });
    } else {
      print('why empty');
      setState(() {
        showProfessionalMainCard = true;
        showProfessionalSearchCard = false;
        showProfessionalFilterCard = false;
      });
    }
    //TODO: Else show a flutter toast showing no value checked
  }


  String searchHint = "search by job title";

  Function searchFunction;

  //TODO:Declaring and initializing Job variables
  String jobSearchQuery;
  Stream _streamSearch;
  Stream _streamProfessionalSearch;
  bool showMainCard = true;
  bool showSearchCard = false;
  bool showFilterCard = false;
  bool enable = true;



  //TODO:Declaring and initializing Professional variables
  String professionalSearchQuery;
  bool showProfessionalMainCard = true;
  bool showProfessionalSearchCard = false;
  bool showProfessionalFilterCard = false;
  bool professionalEnable = true;
  bool filterColor = false;

  //TODO: job search functionality
void searchJobFunction(value){
  jobSearchQuery = controller.text;
  if (controller.text == null || controller.text.length == 0) {
    //TODO: reload streams of jobs data


    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top, SystemUiOverlay.bottom]);



    listScrollController.addListener(() {

      bool   outOfRange    = listScrollController.position.outOfRange;
      double offset        = listScrollController.offset;
      double maxScroll     = listScrollController.position.maxScrollExtent;

      //double currentScroll = listScrollController.position.pixels;
      //double delta         = MediaQuery.of(context).size.height * 0.20;

      if (offset >= maxScroll && !outOfRange) {

        shouldCheck = true;

        if (shouldRunCheck) {

          fetchJobsNextTen();

        }

      }
      else {

        shouldRunCheck = true;

      }

    });

    fetchJobsFirstTen();
    VariableStorage.changeStreamOfData = true;

    setState(() {
      showMainCard = true;
      showSearchCard = false;
      showFilterCard = false;
    });
  } else {
    setState(() {
      showMainCard = false;
      showSearchCard = true;
      showFilterCard = false;
    });
  }

}


  //TODO: professional search functionality
void searchProfessionals(){
    professionalSearchQuery = controller.text;
    if (controller.text == null || controller.text.length == 0) {

      //TODO: reload streams of jobs data


      SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top, SystemUiOverlay.bottom]);



      listScrollController.addListener(() {

        bool   outOfRange    = listScrollController.position.outOfRange;
        double offset        = listScrollController.offset;
        double maxScroll     = listScrollController.position.maxScrollExtent;

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
      VariableStorage.changeProfessionalStreamOfData = true;






      setState(() {
        showProfessionalMainCard = true;
        showProfessionalSearchCard = false;
        showProfessionalFilterCard = false;
      });
    } else {
      setState(() {
        showProfessionalMainCard = false;
        showProfessionalSearchCard = true;
        showProfessionalFilterCard = false;
        professionalSearchQuery = controller.text;
        print(professionalSearchQuery);
      });
    }
  }
  //TODO:check if the user has a professional account
  bool profState = false;


//TODO: change the filter color once filter is active
  void changeFilterColor(){
if(showProfessionalFilterCard == true){
  setState(() {
    filterColor = true;
  });
}else if(showFilterCard == true){
  setState(() {
    filterColor = true;
  });
}
  }


  //TODO: Job Pagination functionality
  StreamController<List<DocumentSnapshot>> jobsStreamController = StreamController<List<DocumentSnapshot>>.broadcast();

  List<DocumentSnapshot> jobsDocumentList;

  //TODO: Professional Pagination functionality
  StreamController<List<DocumentSnapshot>> professionalsStreamController = StreamController<List<DocumentSnapshot>>.broadcast();

  List<DocumentSnapshot> professionalsDocumentList;


  ScrollController listScrollController = ScrollController();

  int  check          = 0;
  bool shouldCheck    = false;
  bool shouldRunCheck = true;
  int viewReturn = 0;

  int returnCorrectLandingPage(){
    if(UserStorage.fromResume == true){
      return 3;
    }else if(UserStorage.isFromCompanyPage == true){
      setState(() {
        hideFilter = true;
      });
      return 3;
    }else{
      return 0;
    }
  }




  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top, SystemUiOverlay.bottom]);



    listScrollController.addListener(() {

      bool   outOfRange    = listScrollController.position.outOfRange;
      double offset        = listScrollController.offset;
      double maxScroll     = listScrollController.position.maxScrollExtent;

      //double currentScroll = listScrollController.position.pixels;
      //double delta         = MediaQuery.of(context).size.height * 0.20;

      if (offset >= maxScroll && !outOfRange) {

        shouldCheck = true;

        if (shouldRunCheck) {

          fetchJobsNextTen();
          fetchProfessionalsFirstTen();

        }

      }
      else {

        shouldRunCheck = true;

      }

    });

    fetchJobsFirstTen();
    fetchProfessionalsFirstTen();








    _streamSearch = Firestore.instance.collectionGroup('companyJobs').snapshots();
    _streamProfessionalSearch = Firestore.instance.collection('professionals').snapshots();
    //TODO: initialize jobs display card
    filterDisplayCard = StreamBuilder<QuerySnapshot>(
        stream: _streamSearch,
        builder: (context, snapshot) {
          return NoResult(message: kFilterMessage,);
        });
    //TODO: //initialize Professional display card
    pFilterDisplayCard = StreamBuilder<QuerySnapshot>(
        stream: _streamProfessionalSearch,
        builder: (context, snapshot) {
          return NoResult(message: kFilterMessage,);
        });
    _tabController = TabController(vsync: this, initialIndex:returnCorrectLandingPage(), length: 4)
      ..addListener(() {
        setState(() {
          switch(_tabController.index) {
            case 0:
            // some code here
              setState(() {
                searchHint ="search by job title";
                enable = true;
                hideFilter = false;
                //searchFunction = searchJobFunction;
              });
              break;
            case 1:
            // some code here
              setState(() {
                searchHint =" search by title";
                enable = true;
                hideFilter = false;
              });
              break;
            case 2:
              setState(() {
                searchHint = "No search here";
                enable = false;
                hideFilter = true;
              });
              break;
            case 3:
              setState(() {
                searchHint = "No search here";
                enable = false;
                hideFilter = true;
              });
          }
        });
      });
    UserStorage.getCurrentUser();


  }

  //TODO: for jobs custom pagination function

  Future fetchJobsFirstTen() async {

    Firestore.instance
        .collectionGroup('companyJobs')
        .orderBy('time', descending: true)
        .snapshots()
        .asBroadcastStream().listen((data) => onChangeDataOfJobs(data.documentChanges));

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

  fetchJobsNextTen() async {

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

  void onChangeDataOfJobs(List<DocumentChange> documentChanges) {

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

    //_jobsDocumentList.sort( (a, b) => a['timestamp'].compareTo(b['timestamp']));

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
    UserStorage.fromResume = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _tabController.index == 0 ?   Drawer(
          child: ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 20.0),
                      child: Text(
                        'FILTER BY',
                        style:GoogleFonts.rajdhani(
                          textStyle:TextStyle(
                              fontSize:ScreenUtil().setSp(18.0),
                              fontWeight: FontWeight.bold,
                              color: Colors.black),),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0.0, 5.0, 10.0, 20.0),
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            filterColor = false;
                            showMainCard = true;
                            showSearchCard = false;
                            showFilterCard = false;
                          });

                          //TODO: reload streams of data


                          SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top, SystemUiOverlay.bottom]);



                          listScrollController.addListener(() {

                            bool   outOfRange    = listScrollController.position.outOfRange;
                            double offset        = listScrollController.offset;
                            double maxScroll     = listScrollController.position.maxScrollExtent;

                            //double currentScroll = listScrollController.position.pixels;
                            //double delta         = MediaQuery.of(context).size.height * 0.20;

                            if (offset >= maxScroll && !outOfRange) {

                              shouldCheck = true;

                              if (shouldRunCheck) {

                                fetchJobsNextTen();

                              }

                            }
                            else {

                              shouldRunCheck = true;

                            }

                          });

                          fetchJobsFirstTen();
                          VariableStorage.changeStreamOfData = true;





                          Navigator.pop(context);
                        },
                        child: Text(
                          'CLEAR FILTER',
                          style:GoogleFonts.rajdhani(
                            textStyle:TextStyle(
                                fontSize:ScreenUtil().setSp(18.0),
                                fontWeight: FontWeight.bold,
                                color: Colors.red),),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                child: Text(
                  'Job Type',
                  style:GoogleFonts.rajdhani(
                    textStyle:TextStyle(
                        fontSize:ScreenUtil().setSp(18.0),
                        fontWeight: FontWeight.bold,
                        color: kMore),),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Row(
                      children: <Widget>[
                        Radio(
                          value: "In-Person",
                          groupValue: jobTypeGroupValue,
                          activeColor: Colors.red,
                          onChanged: (val) => changeJobTypeState(val),
                        ),
                        Text(
                          'In-Person',
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0.0, 0.0, 60.0, 0.0),
                    child: Row(
                      children: <Widget>[
                        Radio(
                          value: "Remote",
                          groupValue: jobTypeGroupValue,
                          activeColor: Colors.red,
                          onChanged: (val) => changeJobTypeState(val),
                        ),
                        Text(
                          'Remote',
                          style: new TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                child: Divider(
                  color: kShade,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                child: Text(
                  'Location',
                  style:GoogleFonts.rajdhani(
                    textStyle:TextStyle(
                        fontSize:ScreenUtil().setSp(18.0),
                        fontWeight: FontWeight.bold,
                        color: kMore),),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.0, 0.0, 20, 0.0),
                child: Container(
                  child: TextField(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                        hintText: "Enter Job Location",
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: kShade,
                            style: BorderStyle.solid,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black))),
                    onChanged: (value) {
                      setState(() {
                        jobLocation = value;
                      });
                    },
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                child: Divider(
                  color: kShade,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 0.0),
                child: Text(
                  'Enter Salary Range',
                  style:GoogleFonts.rajdhani(
                    textStyle:TextStyle(
                        fontSize:ScreenUtil().setSp(18.0),
                        fontWeight: FontWeight.bold,
                        color: kMore),),
                ),
              ),
              Container(
                child: Row(children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextFormField(
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                        autocorrect: true,
                        cursorColor: (Colors.black),
                        style:GoogleFonts.rajdhani(
                          textStyle:TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black),),
                        decoration: InputDecoration(
                            hintText: "Min Salary",
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: kShade,
                                style: BorderStyle.solid,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black))),
                        onChanged: (value) {
                          setState(() {
                            minSalary = value;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ]),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                child: Divider(
                  color: kShade,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 0.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          'Date',
                          style:GoogleFonts.rajdhani(
                            textStyle:TextStyle(
                                fontSize:ScreenUtil().setSp(18.0),
                                fontWeight: FontWeight.bold,
                                color: kMore),),
                        ),
                        Text(
                          'Pick A Date?',
                          style:GoogleFonts.rajdhani(
                            textStyle:TextStyle(
                                fontSize:ScreenUtil().setSp(18.0),
                                fontWeight: FontWeight.bold,
                                color: kMore),),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 12.0),
                      child: RaisedButton(
                        child: Text(_dateTime == null
                            ? 'Click To Pick A Date'
                            : DateFormat("yyyy-MM-dd")
                            .format(_dateTime)
                            .toString()),
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            initialDate: _dateTime == null
                                ? DateTime.now()
                                : _dateTime,
                            firstDate: DateTime(2019),
                            lastDate: DateTime(2025),
                          ).then((date) {
                            setState(() {
                              _dateTime = date;
                            });
                          });
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                      child: Divider(
                        color: Colors.black,
                        thickness: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 0.0),
                child: Text(
                  'Job Category',
                  style:GoogleFonts.rajdhani(
                    textStyle:TextStyle(
                        fontSize:ScreenUtil().setSp(18.0),
                        fontWeight: FontWeight.bold,
                        color: kMore),),
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                    child: Row(
                      children: <Widget>[
                        Checkbox(
                          value: fullTimeCheckboxValue,
                          activeColor: Colors.transparent,
                          checkColor: Colors.red,
                          onChanged: (bool val) {
                            print(val);
                            setState(() {
                              fullTimeCheckboxValue = val;
                              disableFilter = false;
//                                if(fullTimeCheckboxValue == true){
//                                  fullTimeValue = "Full-Time";
//                                }
                            });
                          },
                        ),
                        Text(
                          'Full Time',
                          style: new TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Checkbox(
                          value: partTimeCheckboxValue,
                          activeColor: Colors.transparent,
                          checkColor: Colors.red,
                          onChanged: (bool val) {
                            print(val);
                            setState(() {
                              partTimeCheckboxValue = val;
                              disableFilter = false;
//                                if(partTimeCheckboxValue == true){
//                                  partTimeValue = "Part-Time";
//                                }
                            });
                          },
                        ),
                        Text(
                          'Part Time',
                          style: new TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Checkbox(
                      value: contractCheckboxValue,
                      activeColor: Colors.transparent,
                      checkColor: Colors.red,
                      onChanged: (bool val) {
                        print(val);
                        setState(() {
                          contractCheckboxValue = val;
                          disableFilter = false;
//                            if(contractCheckboxValue == true){
//                              contractValue = "Contract";
//                            }
                        });
                      },
                    ),
                    Text(
                      'Contract',
                      style: new TextStyle(fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                child: Divider(
                  color: kShade,
                ),
              ),
              FlatButton(
                onPressed: () {
                  //TODO: check if the filter values are empty
                  //TODO: checking if the job category boxes were checked
                  if (fullTimeCheckboxValue == false &&
                      partTimeCheckboxValue == false &&
                      contractCheckboxValue == false) {
                    setState(() {
                      disableFilter = true;
                    });
                    Fluttertoast.showToast(
                        msg: "Job Category Field Was Not Checked",
                        toastLength: Toast.LENGTH_SHORT,
                        backgroundColor: Colors.red,
                        textColor: Colors.white);
                  } else {
                    setState(() {
                      disableFilter = false;
                    });
                    //TODO: perform the filter
                    print(jobLocation);
                    /// performing filter when location value is not null
                    if(jobLocation != null && _dateTime != null){
                      locationAndDateFilterFunction();
                      print('location and date query');
                      setState(() {
                        jobLocation = null;
                        _dateTime = null;
                      });
                      /// performing filter when location value is not null but date value is null
                    }else if(jobLocation != null && _dateTime == null){
                      locationFilterFunction();
                      print('location query');
                      setState(() {
                        jobLocation = null;
                      });
                      /// performing filter when location value is null but date value is not null
                    }else if(jobLocation == null && _dateTime != null){
                      dateFilterFunction();
                      print('Date query');
                      setState(() {
                        _dateTime = null;
                      });
                    }
                    /// performing filter when location and date  values are not present
                    else{
                      filterFunction();
                      print('normal query');
                    }
                    //TODO: remove the drawer context
                    changeFilterColor();
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: disableFilter == true ? Colors.black:Colors.red,
                  ),
                  // margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  height: ScreenUtil().setHeight(50.0),
                  margin: EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        disableFilter == true ?'FILTER DISABLED':'APPLY FILTERS',
                        textAlign: TextAlign.center,
                        style:GoogleFonts.rajdhani(
                          textStyle:TextStyle(
                              fontSize:ScreenUtil().setSp(18.0),
                              fontWeight: FontWeight.bold,
                              color: Colors.white),),
                      ),
                      Container(
                        height: 20,
                        width: 30,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("images/jobs/filter.png"),
                            )),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
         :  Padding(
           padding: const EdgeInsets.only(top:148.0),
           child:  Drawer(
             child: ListView(
               children: <Widget>[
                 Container(
                   margin: EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: <Widget>[
                       Container(
                         margin: EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 20.0),
                         child: Text(
                           'FILTER BY',
                           style:GoogleFonts.rajdhani(
                             textStyle:TextStyle(
                                 fontSize:ScreenUtil().setSp(18.0),
                                 fontWeight: FontWeight.bold,
                                 color: Colors.black),),
                         ),
                       ),
                       Container(
                         margin: EdgeInsets.fromLTRB(0.0, 5.0, 10.0, 20.0),
                         child: GestureDetector(
                           onTap: (){
                             setState(() {
                               filterColor = false;
                               showProfessionalMainCard = true;
                               showProfessionalSearchCard = false;
                               showProfessionalFilterCard = false;
                             });


                             //TODO: reload streams of jobs data


                             SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top, SystemUiOverlay.bottom]);



                             listScrollController.addListener(() {

                               bool   outOfRange    = listScrollController.position.outOfRange;
                               double offset        = listScrollController.offset;
                               double maxScroll     = listScrollController.position.maxScrollExtent;

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
                             VariableStorage.changeProfessionalStreamOfData = true;




                             Navigator.pop(context);
                           },
                           child: Text(
                             'CLEAR FILTER',
                             style:GoogleFonts.rajdhani(
                               textStyle:TextStyle(
                                   fontSize:ScreenUtil().setSp(18.0),
                                   fontWeight: FontWeight.bold,
                                   color: Colors.red),),
                           ),
                         ),
                       ),
                     ],
                   ),
                 ),
                 Container(
                   margin: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                   child: Text(
                     'Job Type',
                     style:GoogleFonts.rajdhani(
                       textStyle:TextStyle(
                           fontSize:ScreenUtil().setSp(18.0),
                           fontWeight: FontWeight.bold,
                           color: kMore),),
                   ),
                 ),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: <Widget>[
                     Container(
                       child: Row(
                         children: <Widget>[
                           Radio(
                             value: "In-Person",
                             groupValue: jobTypeGroupValue,
                             activeColor: Colors.red,
                             onChanged: (val) => changeJobTypeState(val),
                           ),
                           Text(
                             'In-Person',
                             style: TextStyle(fontSize: 14.0),
                           ),
                         ],
                       ),
                     ),
                     Container(
                       margin: EdgeInsets.fromLTRB(0.0, 0.0, 60.0, 0.0),
                       child: Row(
                         children: <Widget>[
                           Radio(
                             value: "Remote",
                             groupValue: jobTypeGroupValue,
                             activeColor: Colors.red,
                             onChanged: (val) => changeJobTypeState(val),
                           ),
                           Text(
                             'Remote',
                             style: new TextStyle(fontSize: 14.0),
                           ),
                         ],
                       ),
                     ),
                   ],
                 ),
                 Container(
                   margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                   child: Divider(
                     color: kShade,
                   ),
                 ),
                 Container(
                   margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                   child: Text(
                     'Location',
                     style:GoogleFonts.rajdhani(
                       textStyle:TextStyle(
                           fontSize:ScreenUtil().setSp(18.0),
                           fontWeight: FontWeight.bold,
                           color: kMore),),
                   ),
                 ),
                 Padding(
                   padding: EdgeInsets.fromLTRB(20.0, 0.0, 20, 0.0),
                   child: Container(
                     child: TextField(
                       style: TextStyle(
                         color: Colors.black,
                       ),
                       decoration: InputDecoration(
                           hintText: "Enter Job Location",
                           enabledBorder: UnderlineInputBorder(
                             borderSide: BorderSide(
                               color: kShade,
                               style: BorderStyle.solid,
                             ),
                           ),
                           focusedBorder: UnderlineInputBorder(
                               borderSide: BorderSide(color: Colors.black))),
                       onChanged: (value) {
                         setState(() {
                           jobLocation = value;
                         });
                       },
                     ),
                   ),
                 ),
                 Container(
                   margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                   child: Divider(
                     color: kShade,
                   ),
                 ),
                 Container(
                   margin: EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 0.0),
                   child: Text(
                     'Enter Salary Range',
                     style:GoogleFonts.rajdhani(
                       textStyle:TextStyle(
                           fontSize:ScreenUtil().setSp(18.0),
                           fontWeight: FontWeight.bold,
                           color: kMore),),
                   ),
                 ),
                 Container(
                   child: Row(children: [
                     Expanded(
                       child: Padding(
                         padding: const EdgeInsets.only(left: 20.0),
                         child: TextFormField(
                           inputFormatters: <TextInputFormatter>[
                             WhitelistingTextInputFormatter.digitsOnly
                           ],
                           keyboardType: TextInputType.number,
                           autocorrect: true,
                           cursorColor: (Colors.black),
                           style:GoogleFonts.rajdhani(
                             textStyle:TextStyle(
                                 fontWeight: FontWeight.bold,
                                 color: Colors.black),),
                           decoration: InputDecoration(
                               hintText: "Min Salary",
                               enabledBorder: UnderlineInputBorder(
                                 borderSide: BorderSide(
                                   color: kShade,
                                   style: BorderStyle.solid,
                                 ),
                               ),
                               focusedBorder: UnderlineInputBorder(
                                   borderSide: BorderSide(color: Colors.black))),
                           onChanged: (value) {
                             setState(() {
                               minSalary = value;
                             });
                           },
                         ),
                       ),
                     ),
                     SizedBox(
                       width: 20,
                     ),
                   ]),
                 ),
                 Container(
                   margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                   child: Divider(
                     color: kShade,
                   ),
                 ),

                 Container(
                   margin: EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 0.0),
                   child: Text(
                     'Job Category',
                     style:GoogleFonts.rajdhani(
                       textStyle:TextStyle(
                           fontSize:ScreenUtil().setSp(18.0),
                           fontWeight: FontWeight.bold,
                           color: kMore),),
                   ),
                 ),
                 Row(
                   children: <Widget>[
                     Container(
                       child: Row(
                         children: <Widget>[
                           Checkbox(
                             value: fullTimeCheckboxValue,
                             activeColor: Colors.transparent,
                             checkColor: Colors.red,
                             onChanged: (bool val) {
                               print(val);
                               setState(() {
                                 disableFilter = false;
                                 fullTimeCheckboxValue = val;
//                                if(fullTimeCheckboxValue == true){
//                                  fullTimeValue = "Full-Time";
//                                }
                               });
                             },
                           ),
                           Text(
                             'Full Time',
                             style: new TextStyle(fontSize: 14.0),
                           ),
                         ],
                       ),
                     ),
                     Container(
                       child: Row(
                         children: <Widget>[
                           Checkbox(
                             value: partTimeCheckboxValue,
                             activeColor: Colors.transparent,
                             checkColor: Colors.red,
                             onChanged: (bool val) {
                               print(val);
                               setState(() {
                                 disableFilter = false;
                                 partTimeCheckboxValue = val;
//                                if(partTimeCheckboxValue == true){
//                                  partTimeValue = "Part-Time";
//                                }
                               });
                             },
                           ),
                           Text(
                             'Part Time',
                             style: new TextStyle(fontSize: 14.0),
                           ),
                         ],
                       ),
                     ),
                   ],
                 ),
                 Container(
                   child: Row(
                     children: <Widget>[
                       Checkbox(
                         value: contractCheckboxValue,
                         activeColor: Colors.transparent,
                         checkColor: Colors.red,
                         onChanged: (bool val) {
                           print(val);
                           setState(() {
                             disableFilter = false;
                             contractCheckboxValue = val;
//                            if(contractCheckboxValue == true){
//                              contractValue = "Contract";
//                            }
                           });
                         },
                       ),
                       Text(
                         'Contract',
                         style: new TextStyle(fontSize: 14.0),
                       ),
                     ],
                   ),
                 ),
                 Container(
                   margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                   child: Divider(
                     color: kShade,
                   ),
                 ),
                 FlatButton(
                   onPressed: () {
                     //TODO: check if the filter values are empty
                     //TODO: checking if the job category boxes were checked
                     if (fullTimeCheckboxValue == false &&
                         partTimeCheckboxValue == false &&
                         contractCheckboxValue == false) {
                       setState(() {
                         disableFilter = true;
                       });
                       Fluttertoast.showToast(
                           msg: "Job Category Field Was Not Checked",
                           toastLength: Toast.LENGTH_SHORT,
                           backgroundColor: Colors.red,
                           textColor: Colors.white);
                     } else {
                       setState(() {
                         disableFilter = false;
                       });
                       //TODO: perform the filter
                       if(jobLocation != null){
                         print('location query');
                         professionalLocationQuery();
                         setState(() {
                           jobLocation = null;
                         });
                       }
                       /// performing filter when location and date  values are not present
                       else{
                         print('normal query');
                         normalProfessionalFilter();
                       }
                       //TODO: remove the drawer context
                       changeFilterColor();
                       Navigator.pop(context);
                     }
                   },
                   child: Container(
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(5.0),
                       color:disableFilter == true? Colors.black  : Colors.red,
                     ),
                     // margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                     height: ScreenUtil().setHeight(50.0),
                     margin: EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 20.0),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: <Widget>[
                         Text(
                           disableFilter == true ?'FILTER DISABLED':'APPLY FILTERS',
                           textAlign: TextAlign.center,
                           style:GoogleFonts.rajdhani(
                             textStyle:TextStyle(
                                 fontSize:ScreenUtil().setSp(18.0),
                                 fontWeight: FontWeight.bold,
                                 color: Colors.white),),
                         ),
                         Container(
                           height: 20,
                           width: 30,
                           decoration: BoxDecoration(
                               image: DecorationImage(
                                 image: AssetImage("images/jobs/filter.png"),
                               )),
                         )
                       ],
                     ),
                   ),
                 ),
               ],
             ),
           ),
         ),
        body: NestedScrollView(
          controller: listScrollController,
          headerSliverBuilder: (context, value) {
            return [
              SliverAppBar(
                expandedHeight: hideFilter == false ? ScreenUtil().setHeight(160.0) : ScreenUtil().setHeight(100.0),
                title: Container(
                  margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.05,
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
//                        GestureDetector(
//                          onTap: (){
//                            Navigator.push(
//                                context,
//                                PageTransition(
//                                    type: PageTransitionType.rightToLeft,
//                                    child: Companies() ));
//                          },
//                          child: Icon(
//                            Icons.account_balance,
//                            color: Colors.white,
//                            size: 30.0,
//                          ),
//                        ),

                        Container(
                          margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.width * 0.02,
                          ),
                          child: SizedBox(
                            child: Image(
                              width: 80.0,
                              height: 40.0,
                              image: AssetImage(
                                'images/brand.png',
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            ProfessionalStorage.id = UserStorage.loggedInUser.uid;
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: UserStorage.profState == true ? Resume ()  : Entry() ));
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.width * 0.02,
                            ),
                            child: Icon(
                              Icons.account_box,
                              color: Colors.white,
                              size: 30.0,
                            ),
                          ),
                        ),
                      ]),
                ),
                titleSpacing: 0.0,
                backgroundColor: kLight_orange,
                floating: true,
                pinned: true,
                automaticallyImplyLeading: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(
                      15.0,
                    ),
                    bottomRight: Radius.circular(
                      15.0,
                    ),
                  ),
                ),
                actions: <Widget>[
                  Container(
                    child: Row(
                      children: <Widget>[

                        BadgeCounter(
                          badgeText: '120',
                          iconData: Icons.notifications_none,
                          showBadge: true,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(15.0, 10.0, 10.0, 0.0),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage("images/jobs/pic22.png"),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.only(top:18.0, left: 8.0),
                      child: Row(
                        children: <Widget>[
                          if(hideFilter == false)
                          Padding(
                            padding:
                            const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                            child: GestureDetector(
                              onTap: () {
                                _scaffoldKey.currentState.openDrawer();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SvgPicture.asset(
                                  "images/jobs/filter.svg",
                                  width: ScreenUtil().setWidth(38),
                                  color: filterColor == true? kActiveNavColor : Colors.white,
                                ),
                              ),
                            ),
                          ),
                          if(hideFilter == false)
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                              child: TextFormField(
                                enabled: enable,
                                onChanged:  (value) {
                                  if(_tabController.index == 0){
                                    searchJobFunction(value);
                                  }
                                  if(_tabController.index == 1){
                                    searchProfessionals();
                                  }

                                },
                                controller: controller,
                                decoration: InputDecoration(
                                  hintText: searchHint,
                                  contentPadding: EdgeInsets.only(left: 24.0),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          if(hideFilter == false)
                          IconButton(
                            icon: Icon(Icons.search),
                            color: Colors.white,
                            onPressed: () {},
                          )
                        ],
                      ),
                    )),
                bottom: TabBar(
                  isScrollable: true,
                  controller: _tabController,
                  indicatorColor: kActiveNavColor,
                  labelColor: kActiveNavColor,
                  unselectedLabelColor: kNavColor,
                  indicatorSize:  TabBarIndicatorSize.label,
                  indicatorWeight: 4.0,
                  indicatorPadding: EdgeInsets.only(
                    left: ScreenUtil().setSp(5.0),
                    right: ScreenUtil().setSp(5.0),
                  ),
                  labelStyle: GoogleFonts.rajdhani(
                    textStyle: TextStyle(
                      fontSize: ScreenUtil().setSp(15.0),
                      fontWeight: FontWeight.bold,
                    ),
                  ), //For Selected tab
                  unselectedLabelStyle: GoogleFonts.rajdhani(
                    textStyle: TextStyle(
                      fontSize: ScreenUtil().setSp(15.0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  tabs: <Widget>[
                    Tab(
                      text: 'Jobs',
                    ),
                    Tab(
                      text: 'Professionals',
                    ),
                    Tab(
                      text: 'Employments',
                    ),
                    Tab(
                      text: 'Company',
                    ),
                  ],
                ),

              ),
            ];
          },
          body: TabBarView(

            controller: _tabController,
            children: [
              MainJobs(
                listScrollController: listScrollController,
                jobsStreamController: jobsStreamController,
                jobsDocumentList: jobsDocumentList,
                showMainCard: showMainCard,
                showSearchCard: showSearchCard,
                showFilterCard: showFilterCard,
                jobSearchQuery: jobSearchQuery,
                filterDisplayCard: filterDisplayCard,
              ),
              Professional(
                listScrollController: listScrollController,
                professionalsStreamController: professionalsStreamController,
                professionalsDocumentList: professionalsDocumentList,
                pShowMainCard: showProfessionalMainCard,
                pShowSearchCard: showProfessionalSearchCard,
                professionalSearchQuery:professionalSearchQuery,
                pShowFilterCard: showProfessionalFilterCard,
                pFilterDisplayCard: pFilterDisplayCard,
              ),
              Employment1(),
              UserStorage.isCompanyAccount == true ? Companies() : CompanyAccountEntry(),
            ],
          ),
        ),
        bottomNavigationBar: CustomCompanyBottomAppBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(
          heroTag: "MainFAB",
          shape: CircleBorder(
            side: BorderSide(
              color: kWhiteColour,
            ),
          ),
          child: fabCurrentState == FabActivity.CLOSE
              ? Container(
            margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.012,
              top: MediaQuery.of(context).size.height * 0.014,
              bottom: MediaQuery.of(context).size.height * 0.012,
            ),
            width: MediaQuery.of(context).size.width * 0.08,
            height: MediaQuery.of(context).size.height * 0.05,
            child: Align(
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  "images/sparks_brand_svg.svg",
                  width: MediaQuery.of(context).size.width * 0.05,
                  height: MediaQuery.of(context).size.height * 0.055,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                )),
          )
              : Icon(
            Icons.clear,
            size: ScreenUtil().setSp(
              kSize_40,
              allowFontScalingSelf: true,
            ),
          ),
          backgroundColor: kProfile,
          onPressed: () {
            setState(() {
              isPressed == true ? isPressed = false : isPressed = true;
              isPressed == false
                  ? fabCurrentState = FabActivity.CLOSE
                  : fabCurrentState = FabActivity.OPEN;
            });
          },
        ),
      ),
    );
  }
}
