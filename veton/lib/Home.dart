import 'dart:async';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veton/ClientModel.dart';
import 'package:veton/Model/CallModel.dart';
import 'package:veton/Model/LoacleCallModel.dart';
import 'package:call_log/call_log.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  String userID,name;

  Home(this.userID,this.name);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  String tabIndicator = 'Assigned Leads';
  int currentIndex=0;
  bool hasInternet = false;
  bool dataSendLoading = false;
  late StreamSubscription subscription;
  TextEditingController searchController = TextEditingController();
  String query = '';
  List<LeadModel> leadList = <LeadModel>[];
  List<LeadModel> searchLeadList = <LeadModel>[];
  bool loading = true;
  PhoneStateStatus status = PhoneStateStatus.NOTHING;
  bool granted = false;

  void getCallLogs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Iterable<CallLogEntry> entries = await CallLog.get();
    var singleCallLog = entries.first;
    List<LocalStorageCalls> sendingList = [];
    List<CallModel> sendingCallList = [];

    bool isVerified = false;
    String clientNum = preferences.getString('ClientPhoneNo') ?? '0';
    String employeeID = widget.userID;
    String duration = singleCallLog.duration.toString();
    String clientID = preferences.getString('clientID') ?? '0';
    String completeNum = '0$clientNum';
    print('================0000000??????${employeeID}');
    print('================0000000??????${clientID}');

    if (singleCallLog.number.toString() == completeNum) {
      singleCallLog.duration! >= 20 ? isVerified = true : isVerified = false;
      var tempCallData = LocalStorageCalls()
        ..clientId = clientID
        ..isVerified = isVerified
        ..totalLength = duration
        ..employeeId = employeeID;
      var callRec=CallModel(totalLength: duration, isVerified: isVerified, from: employeeID, to: clientID);

      sendingList.add(tempCallData);
      sendingCallList.add(callRec);
      dataManagingBlock(sendingCallList);
    } else {
      return;
    }
  }

  void dataManagingBlock(List<CallModel> listOfCalls) async{
    if (hasInternet) {
      sendDataToServer(listOfCalls);
    } else {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setBool('IsDataStoredInDB', true);
      var singleCallData = listOfCalls.first;

      addCallDataToDB(singleCallData.totalLength, singleCallData.isVerified,
          singleCallData.to, singleCallData.from);
    }
  }

  String formatDate(DateTime dt) {
    return DateFormat('d-MMM-y H:m:s').format(dt);
  }

  String getTime(int duration) {
    Duration d1 = Duration(seconds: duration);
    String formatedDuration = "";
    if (d1.inHours > 0) {
      formatedDuration += d1.inHours.toString() + "h ";
    }
    if (d1.inMinutes > 0) {
      formatedDuration += d1.inMinutes.toString() + "m ";
    }
    if (d1.inSeconds > 0) {
      formatedDuration += d1.inSeconds.toString() + "s";
    }
    if (formatedDuration.isEmpty) return "0s";
    return formatedDuration;
  }

  ///......server functions to fetch and send
  Future<ClientModel> getLeads() async {
    setState(() {
      loading = true;
      leadList.clear();
      searchLeadList.clear();
    });
    var baseUrl = 'http://44.203.240.206:5000/lead/mobile?assignedto=';
    var url = Uri.parse('$baseUrl+6289ec2a894e709193eb14e9');
    var response =
    await http.get(url, headers: {"content-type": "application/json"});

    var productData = jsonDecode(response.body);
    if (response.statusCode != 200) {
      print('error code ye h===== ${response.statusCode}');
      return ClientModel.fromJson(productData);
    } else {
      for (var value in ClientModel.fromJson(productData).data!) {
        var client = LeadModel(
            number: value.client!.phone.toString(),
            name: value.client!.name.toString(),
            id: value.client!.id.toString(),
            projectName: value.intrested!.project!);

        leadList.add(client);
        searchLeadList.add(client);
      }
      setState(() {
        loading = false;
      });
      return ClientModel.fromJson(productData);
    }
  }

  Future<bool> sendDataToServer(List<dynamic> callsData) async {

    var baseUrl = 'http://44.203.240.206:5000/call';
    var url = Uri.parse(baseUrl);
    CallModel callRec;
    List<CallModel> list = [];


    callsData.map((e) => {
callRec = CallModel(
totalLength: e.totalLength,
isVerified: e.isVerified,
to:e.to,
from: e.from
),
    list.add(callRec),
}) .toList()  ;

    // var e=callsData.first;
    // callRec = CallModel(
    //     totalLength: e.totalLength,
    //     isVerified: e.isVerified,
    //     to:e.to,
    //     from: e.from
    // );
  // list.add(callRec);
    var response = await http.post(url,
        body: json.encode(list),
        headers: {"content-type": "application/json"});

    if (response.statusCode != 200) {
      print('errpr ha');

      print(response.body);
      return false;
    } else {
      print('errpr nae');
      print(response.body);

      return true;
    }
  }
  Future<bool> sendDataLocaleToServer(List<dynamic> callsData) async {

    var baseUrl = 'http://44.203.240.206:5000/call';
    var url = Uri.parse(baseUrl);
    CallModel callRec;
    List<CallModel> list = [];


    callsData.map((e) => {
      callRec = CallModel(
          totalLength: e.totalLength,
          isVerified: e.isVerified,
          to:e.clientId,
          from: e.employeeId
      ),
      list.add(callRec),
    }) .toList()  ;

    // var e=callsData.first;
    // callRec = CallModel(
    //     totalLength: e.totalLength,
    //     isVerified: e.isVerified,
    //     to:e.to,
    //     from: e.from
    // );
    // list.add(callRec);
    var response = await http.post(url,
        body: json.encode(list),
        headers: {"content-type": "application/json"});

    if (response.statusCode != 200) {
      print('errpr ha');

      print(response.body);
      return false;
    } else {
      print('errpr nae');
      print(response.body);

      return true;
    }
  }
  ///.... save calls data to locale DB and get data from locale DB
  Future addCallDataToDB(String totalLength, bool isVerified, String clientIds,
      String employeeIds) async {
    var callData = LocalStorageCalls()
      ..totalLength = totalLength
      ..isVerified = isVerified
      ..employeeId = employeeIds
      ..clientId = clientIds;
    var box = Boxes.getTransactions();
    box.add(callData);
    print('done');
  }

  Future<List<LocalStorageCalls>> getCallsFromDB() async {
    List<LocalStorageCalls> callsData = [];
    var box = Boxes.getTransactions();
    callsData = box.values.toList();
    return callsData.toList();
  }

  Future<bool> requestPermission() async {
    var status = await Permission.phone.request();

    switch (status) {
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.permanentlyDenied:
        return false;
      case PermissionStatus.granted:
        print('permission out');

        return true;
    }
  }

  void showConnectivitySnackBar(ConnectivityResult result) async {
    List<LocalStorageCalls> fetchedDBList = [];
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool dBHasData = preferences.getBool('IsDataStoredInDB') ?? false;

    hasInternet = result != ConnectivityResult.none;
    final message = hasInternet
        ? 'You have again ${result.toString()}'
        : 'You have no internet';

    if (hasInternet && dBHasData) {
      print('data in db===========>$dBHasData');
      fetchedDBList = await getCallsFromDB();
      sendDataLocaleToServer(fetchedDBList);
      var box = Boxes.getTransactions();
      box.clear();
      preferences.setBool('IsDataStoredInDB', false);
    } else {
      print('no data in db');
    }
  }

  void permission() async {
    print('start');
    bool temp = await requestPermission();
    setState(() {
      granted = temp;
      if (granted) {
        setStream();
      }
    });
    print('stop');
  }

  void setStream() {
    PhoneState.phoneStateStream.listen((event) {
      setState(() {
        if (event != null) {
          status = event;
          if (status == PhoneStateStatus.CALL_STARTED) {
            print('=================>call started');
          } else if (status == PhoneStateStatus.CALL_ENDED) {
            getCallLogs();

            showDialog(
              // barrierColor: Colors.grey[100],
              barrierDismissible: false,
              context: context,
              builder: (ctx) {
                Timer(const Duration(seconds: 4), () {
                  Navigator.of(context).pop();
                });
                return AlertDialog(
                  insetPadding: EdgeInsets.all(40),

                  elevation: 100,
                  shape: const RoundedRectangleBorder(
                      side: BorderSide.none,

                      borderRadius: BorderRadius.all(Radius.circular(15.0))),
                  title: Center(
                      child: Image.asset("assets/taskImg.png",
                          width: 80, height: 90)),
                  content: Container(
                      height: 80,
                      width: 30,
                      child: Center(
                          child: Column(
                            children: [
                              const Text(
                                "Uploading Your Call",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                  height: 40,
                                  width: 40,
                                  child: const CircularProgressIndicator(
                                    color: Colors.blueAccent,
                                    backgroundColor: Colors.deepPurpleAccent,
                                  )),
                            ],
                          ))),
                );
              },
            );
            print('===============>CALL_ENDED');

            // endingTime=DateTime.now();
            // if (hasInternet) {
            //   List<LocalStorageCalls> _lst=[];
            //
            //   sendLocaleDataToServer(_lst);

            //   }
            // else {
            // addCallDataToDB(callData);
            //
            //   }
          } else if (status == PhoneStateStatus.NOTHING) {
            print('=========>nothing');
          } else {
            print('=========>coming');
          }
        }
      });
    });
  }

  void searchLead(String query) {
    final suggestion = searchLeadList.where((lead) {
      final leadtile = lead.name.toUpperCase();
      final input = searchController.text.toUpperCase();
      return leadtile.contains(input);
    }).toList();
    setState(() {
      searchLeadList = suggestion;
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    Hive.close();
    super.dispose();
  }

  @override
  void initState() {
    getCallLogs();
    subscription =
        Connectivity().onConnectivityChanged.listen(showConnectivitySnackBar);
    setStream();
    permission();
    getLeads().then((value) => {loading = false});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: currentIndex==0? Colors.blueAccent:Colors.blue[900],
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color:currentIndex==0? Colors.blueAccent:Colors.blue[900],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const CircleAvatar(
                              radius: 39,
                              backgroundImage: NetworkImage(
                                  ('https://www.w3schools.com/howto/img_avatar.png')),
                            ),
                            InkWell(
                                onTap: () async {
                                  // SharedPreferences p = await SharedPreferences.getInstance();
                                  // p.setBool('IsDataStoredInDB', false);
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 35,
                                      width: 35,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey,
                                              offset: const Offset(0.0, 0.0),
                                              blurRadius: 9.0,
                                              spreadRadius: 4.0,
                                            ),
                                          ],
                                          shape: BoxShape.circle),
                                      child: const Icon(
                                        Icons.power_settings_new,
                                        size: 30,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ))
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0,top: 5),
                          child: Text(
                            '#${widget.name}',textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          tabIndicator,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                    flex: 5,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30))),
                      child: DefaultTabController(
                          length: 2,
                          animationDuration: const Duration(seconds: 1),
                          initialIndex: currentIndex,
                          child: Column(
                            children: [
                              TabBar(
                                indicatorPadding: EdgeInsets.only(top: 10),
                                onTap: (index){
                                  setState(() {
                                    currentIndex=index;
                                    tabIndicator=currentIndex==0?'Assigned Leads':'Edit Profile';
                                  });
                                },
                                labelPadding: EdgeInsets.only(top: 10),
                                unselectedLabelColor: Colors.grey,
                                labelColor: Colors.blueAccent,
                                labelStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                    fontSize: 17),
                                indicatorSize: TabBarIndicatorSize.tab,
                                isScrollable: false,

                                tabs: [
                                  Tab(
                                    text: 'Assigned Leads',
                                  ),
                                  Tab(
                                    text: 'Edit Profile',
                                  ),
                                ],
                              ),
                              Container(
                                height:
                                MediaQuery.of(context).size.height * 0.60,
                                width: double.infinity,
                                child: TabBarView(
                                  children: [
                                    Column(
                                      children: [
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        // Container(
                                        //
                                        //     width: MediaQuery.of(context)
                                        //             .size
                                        //             .width *
                                        //         0.70,
                                        //     decoration: BoxDecoration(
                                        //         color: Colors.grey[300],
                                        //         borderRadius:
                                        //             BorderRadius.circular(
                                        //                 30)),
                                        //     child: Padding(
                                        //       padding: const EdgeInsets.only(
                                        //           left: 18.0),
                                        //       child: TextField(
                                        //         controller: searchController,
                                        //         decoration: InputDecoration(
                                        //           prefixIcon: const Icon(
                                        //               Icons.search),
                                        //           suffixIcon: GestureDetector(
                                        //               onTap: () {
                                        //                 setState(() {
                                        //                   searchLeadList = leadList;
                                        //                   searchController
                                        //                       .clear();
                                        //                 });
                                        //               },
                                        //               child: const Icon(
                                        //                   Icons.close)),
                                        //           border: InputBorder.none,
                                        //         ),
                                        //         onChanged: searchLead,
                                        //       ),
                                        //     )),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Expanded(
                                          child: Container(
                                            // height: MediaQuery.of(context)
                                            //         .size
                                            //         .height *
                                            //     0.61,
                                              child: RefreshIndicator(
                                                key: _refreshIndicatorKey,
                                                onRefresh: () async {
                                                  leadList.clear();
                                                  searchLeadList.clear();
                                                  getLeads();
                                                },
                                                child: loading
                                                    ? Center(
                                                    child: Container(
                                                        height: 30,
                                                        width: 30,
                                                        child:
                                                        const CircularProgressIndicator()))
                                                    : ListView.builder(
                                                    itemCount:
                                                    leadList
                                                        .length,
                                                    itemBuilder:
                                                        (BuildContext
                                                    context,
                                                        int index) {
                                                      return Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal:
                                                            18.0,
                                                            vertical:
                                                            10),
                                                        child: LeadTile(
                                                          name: leadList[
                                                          index]
                                                              .name,
                                                          number: leadList[
                                                          index]
                                                              .number,
                                                          intrestedIn:
                                                          leadList[
                                                          index]
                                                              .projectName,
                                                          id: leadList[index].id,
                                                        ),
                                                      );
                                                    }),
                                              )

                                          ),
                                        ),
                                      ],
                                    ),
                                    Center(child: const Text('Module Disable',style: TextStyle(fontSize: 17 ,fontWeight: FontWeight.w700,color: Colors.red),)),
                                  ],
                                ),
                              )
                            ],
                          )),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LeadTile extends StatefulWidget {
  String name, number, intrestedIn,id;
  LeadTile(
      {required this.name, required this.number, required this.intrestedIn,required this.id});

  @override
  State<LeadTile> createState() => _LeadTileState();
}

class _LeadTileState extends State<LeadTile> {
  late AndroidIntent intent;

  @override
  void initState() {
    super.initState();
  }

  // Future<void> LaunchCall(String num) async {
  //   var completeNum='0$num';
  //   print('================');
  //
  //   print(completeNum);
  //   AndroidIntent intent = AndroidIntent(
  //     action: 'android.intent.action.CALL',
  //     data: 'tel:$completeNum',
  //   );
  //   await intent.launch();
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                      'https://cutewallpaper.org/24/avatar-icon-png/1240-x-1240-0-avatar-profile-icon-png-transparent-png-transparent-png-image-pngitem.png'),
                ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name.toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(widget.number,
                        style: const TextStyle(color: Colors.green)),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(widget.id,
                        style: const TextStyle(color: Colors.red))
                  ],
                ),
                const Spacer(),
                CircleAvatar(
                  child: InkWell(
                      onTap: () async {
                        SharedPreferences pref = await SharedPreferences.getInstance();
                        pref.setString('ClientPhoneNo', widget.number);
                        pref.setString('clientID', widget.id);
                        // pref.setString('to', widget.name);

                        // launch('tel://03131533387'),
                        await Permission.phone.request();
                        var completeNum = '0${widget.number}';
                        await FlutterPhoneDirectCaller.callNumber(completeNum);

                        // LaunchCall(widget.number),
                      },
                      child: const Icon(
                        Icons.call,
                        color: Colors.amberAccent,
                        size: 30,
                      )),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LeadModel {
  String name, number, id, projectName;

  LeadModel(
      {required this.number,
        required this.name,
        required this.id,
        required this.projectName});
}

class Boxes {
  static Box<LocalStorageCalls> getTransactions() =>
      Hive.box<LocalStorageCalls>('CallsHistory');
}
