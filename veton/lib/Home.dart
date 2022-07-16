import 'dart:async';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veton/ClientModel.dart';
import 'package:veton/Model/LoacleCallModel.dart';
import 'package:call_log/call_log.dart';
import 'package:intl/intl.dart';



class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime? startingTime;
  DateTime? endingTime;

  int x = 0;
  bool hasInternet = false;
  late StreamSubscription subscription;
  TextEditingController searchController = TextEditingController();
  String query = '';
  List<LeadModel> leadList = <LeadModel>[
    LeadModel(number: '03335684680', name: 'saad'),
    LeadModel(number: '3322', name: 'zain'),
    LeadModel(number: '00000', name: 'waleed'),
    LeadModel(number: '2233', name: 'haroon'),
    LeadModel(number: '3322', name: 'ayesha'),
    LeadModel(number: '00000', name: 'maaz'),
    LeadModel(number: '3322', name: 'rizwana'),
    LeadModel(number: '3322', name: 'khawar'),
    LeadModel(number: '3322', name: 'ttt'),
  ];
  List<LeadModel> searchleadList = <LeadModel>[];
  bool listChoice = false;
  bool loading = true;


  PhoneStateStatus status = PhoneStateStatus.NOTHING;
  bool granted = false;
  Iterable<CallLogEntry> lst=[];


  void getCallLogs()async{

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String clientNum = preferences.getString('ClientPhoneNo')??'0';
    Iterable<CallLogEntry> entries = await CallLog.get();
   var xx= entries.first;
   if(xx.number.toString()==clientNum){
     print('send this call');
   }
   else{
print('nothing');
   }
   // print(xx.name);
   //  print(xx.number);
   //  print(getTime(xx.duration!));
   //  print(formatDate( DateTime.fromMillisecondsSinceEpoch(xx.timestamp!)));


  }

  String formatDate(DateTime dt){

    return DateFormat('d-MMM-y H:m:s').format(dt);
  }

  String getTime(int duration){
    Duration d1 = Duration(seconds: duration);
    String formatedDuration = "";
    if(d1.inHours > 0){
      formatedDuration += d1.inHours.toString() + "h ";
    }
    if(d1.inMinutes > 0){
      formatedDuration += d1.inMinutes.toString() + "m ";
    }
    if(d1.inSeconds > 0){
      formatedDuration += d1.inSeconds.toString() + "s";
    }
    if(formatedDuration.isEmpty)
      return "0s";
    return formatedDuration;
  }

  ///......server functions to fetch and send
  Future<ClientModel> getLeads() async {
    print('in');
    var baseUrl = 'http://44.203.240.206:5000/lead/mobile?assignedto=';
    var url = Uri.parse('$baseUrl+6289ec2a894e709193eb14e9');
    var response =
        await http.get(url, headers: {"content-type": "application/json"});

    var productData = jsonDecode(response.body);
    if (response.statusCode != 200) {
      print('error code ye h===== ${response.statusCode}');
      return ClientModel.fromJson(productData);

// print(myData[""]);
    } else {
      for (var value in ClientModel.fromJson(productData).data!) {
        //var client=LeadModel(number: value.client!.phone.toString(), name: value.client!.name.toString());
        // print(value.client!.phone);
        // // leadList.add(client);
        // // searchleadList.add(client);
      }
      print('{leadList lenght=================}${leadList.length}');
      print('{leadList lenght=================}${searchleadList.length}');

      return ClientModel.fromJson(productData);
    }
  }

  Future<bool> sendLocaleDataToServer(List<LocalStorageCalls> callsData) async {
    var baseUrl = 'http://44.203.240.206:5000/user/signin';
    var url = Uri.parse(baseUrl);

    var response = await http.post(url,
        body: json.encode(
          {
            "callRecord": callsData,
          },
        ),
        headers: {"content-type": "application/json"});

    if (response.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> sendDataToServer(List<LocalStorageCalls> callsData) async {
    var baseUrl = 'http://44.203.240.206:5000/user/signin';
    var url = Uri.parse(baseUrl);

    var response = await http.post(url,
        body: json.encode(
          {
            "callRecord": callsData,
          },
        ),
        headers: {"content-type": "application/json"});

    if (response.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }




  ///.... save calls data to locale DB and get data from locale DB
  Future addCallDataToDB(
      int totalLength, bool isVerified, String clientIds) async {
    var callData = LocalStorageCalls()
      ..totalLength = totalLength
      ..isVerified = isVerified
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

  void showConnectivitySnackBar(ConnectivityResult result) {
    setState(() {
      hasInternet = result != ConnectivityResult.none;
      final message = hasInternet
          ? 'You have again ${result.toString()}'
          : 'You have no internet';
      final color = hasInternet ? Colors.green : Colors.red;

      if (hasInternet) {
      } else {
        print('nothing to do with list');
      }
    });
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

  void dataSendingBlock(){


    if(hasInternet){




    }
  }


  void setStream() {
    PhoneState.phoneStateStream.listen((event) {
      setState(() {

        if (event != null) {
          status = event;
          if (status == PhoneStateStatus.CALL_STARTED) {
            //call started
            startingTime=DateTime.now();
            print('=================>call started');
          } else if (status == PhoneStateStatus.CALL_ENDED){
            getCallLogs();

            showDialog(
              barrierDismissible: false,

              context: context,
              builder: (ctx) =>
                  
                  AlertDialog(
                title: Text("Alert!"),
                content: Text("You have raised a Alert Dialog Box"),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () async{
Navigator.of(context).pop();
},
                    child: Text("Ok"),
                  ),
                ],
              ),
            );
            print('===============>CALL_ENDED');


            // endingTime=DateTime.now();
            // if (hasInternet) {
            //   List<LocalStorageCalls> _lst=[];
            //
            //   sendLocaleDataToServer(_lst);


          //   }
          // else {
          //     // addCallDataToDB(callData);
          //
          //   }
          } else if(status == PhoneStateStatus.NOTHING) {
            print('=========>nothing');
          }
          else{
            print('=========>coming');

          }
        }
      });
    });
  }

  void searchLead(String query) {
    // setState(() {
    //   searchleadList=leadList;
    // });

    final suggestion = searchleadList.where((lead) {
      final leadtile = lead.name.toLowerCase();
      final input = searchController.text.toLowerCase();
      return leadtile.contains(input);
    }).toList();
    setState(() {
      searchleadList = suggestion;
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
    loading = false;
    searchleadList = leadList;

    super.initState();

    // getLeads().then((value) => {
    //   setState(() {
    //     searchleadList=leadList;
    //     loading=false;
    //     print(searchleadList.length);
    //   })
    // });

    //if (Platform.isIOS)
    setStream();
    permission();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.blueAccent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 39,

                              //    backgroundImage: AssetImage(('assets/images/images.png')),
                            ),
                            InkWell(
                                onTap: () async {
                                  getCallLogs();

                                },
                                child: Column(
                                  children: [
                                    Text(x.toString()),
                                    Icon(
                                      Icons.power_settings_new,
                                      size: 30,
                                      color: Colors.amber,
                                    ),
                                  ],
                                ))
                          ],
                        ),
                        const Text(
                          'sssssss',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                        const Spacer(),
                        const Text(
                          'Assigned Leads',
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
                  flex: 4,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.30,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30))),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.70,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(30)),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 18.0),
                                child: TextField(
                                  controller: searchController,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.search),
                                    suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            searchleadList = leadList;
                                            searchController.clear();
                                          });
                                        },
                                        child: Icon(Icons.close)),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: searchLead,
                                ),
                              )),
                          SizedBox(
                            height: 20,
                          ),
                          Text('Pull Down To Refresh'),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                              height: MediaQuery.of(context).size.height * 0.47,
                              child: ListView.builder(
                                  itemCount: searchleadList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 23.0, vertical: 10),
                                      child: LeadTile(
                                        name: leadList[index].name,
                                        number: leadList[index].number,
                                      ),
                                    );
                                  })
                              // FutureBuilder<ClientModel>(
                              //   future: getLeads(),
                              //   builder: (context, snapshot) {
                              //     if(snapshot.hasData){
                              //       return ListView.builder(
                              //           itemCount: snapshot.data!.data!.length,
                              //           itemBuilder: (BuildContext context,int index){
                              //
                              //             for (var element in snapshot.data!.data!) {
                              //               var lead=LeadModel(number: element.client!.phone!.toString(), name: element.client!.name!);
                              //               leadList.add(lead);
                              //               print('======${leadList.length}');
                              //             }
                              //             return Padding(
                              //               padding: const EdgeInsets.symmetric(horizontal: 23.0,vertical: 10),
                              //               child:  LeadTile(name:leadList[index].name,number: leadList[index].number,),
                              //             );
                              //           }
                              //       );
                              //     }
                              //     else{
                              //       return Center(child: CircularProgressIndicator());
                              //     }
                              //
                              //   }
                              // ),
                              ),
                        ],
                      ),
                    ),
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

class LeadTile extends StatefulWidget {
  String name, number;
  LeadTile({required this.name, required this.number});

  @override
  State<LeadTile> createState() => _LeadTileState();
}

class _LeadTileState extends State<LeadTile> {
  late AndroidIntent intent;

  @override
  void initState() {
    super.initState();
  }

  Future<void> LaunchCall(String num) async {
    AndroidIntent intent = AndroidIntent(
      action: 'android.intent.action.CALL',
      data: 'tel:$num',
    );
    await intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                // backgroundImage: AssetImage('assets/images/images.png'),
              ),
              const SizedBox(
                width: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(widget.number, style: TextStyle(color: Colors.green)),
                ],
              ),
              const Spacer(),
              CircleAvatar(
                child: InkWell(
                    onTap: () async  {
                      SharedPreferences pref = await SharedPreferences.getInstance();
                      pref.setString('ClientPhoneNo', widget.number);
                          // launch('tel://03131533387'),
                          await Permission.phone.request();
                          await FlutterPhoneDirectCaller.callNumber(
                              widget.number);

                          // LaunchCall(widget.number),
                        },
                    child: const Icon(
                      Icons.call,
                      color: Colors.green,
                      size: 30,
                    )),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class LeadModel {
  String name, number;

  LeadModel({required this.number, required this.name});
}

class Boxes {
  static Box<LocalStorageCalls> getTransactions() =>
      Hive.box<LocalStorageCalls>('CallsHistory');
}
