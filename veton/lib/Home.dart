import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veton/CallData.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
void loadData()async{
  final prefs = await SharedPreferences.getInstance();
}

  PhoneStateStatus status = PhoneStateStatus.NOTHING;
  bool granted = false;


  Future<void> getLeads()async{
    print('in');
    var baseUrl = 'http://44.203.240.206:5000/lead/mobile?assignedto=';
    var url = Uri.parse('$baseUrl+6289ec2a894e709193eb14e9');
    var response = await http.get(url,

        headers: {"content-type": "application/json"});

    final Map<String, dynamic> productData = jsonDecode(response.body);
    print(productData);
    if (response.statusCode != 200) {
      print('error code ye h===== ${response.statusCode}');
    //   message = productData['data'];
    //   Fluttertoast.showToast(
    //       msg: message,
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.BOTTOM,
    //       backgroundColor: Colors.grey,
    //       textColor: Colors.white,
    //       fontSize: 16.0);
    // } else {
Map<String,dynamic> myData=json.decode(response.body);
      print(myData['_id']);


    }
  }


  Future<bool>  requestPermission() async {
    print('inpermission');
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

  @override
  void initState() {
    super.initState();
    searchleadList=leadList;

    //if (Platform.isIOS)
      setStream();
    permission();
  }
  void permission()async{
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
          if(status== PhoneStateStatus.CALL_STARTED){
            //call started
            print('call comming');

          }
          else if(status== PhoneStateStatus.CALL_ENDED){
            print('CALL_ENDED');

          }
          else{
            print('comming');
          }
        }
      });
    });
  }

int x=0;
  TextEditingController searchController = TextEditingController();
  List<LeadModel> leadList=[
    LeadModel(number: '03131533387', name: 'Saad'),
    LeadModel(number: '03325536500', name: 'Shaiz'),
    LeadModel(number: '03365569733', name: 'Haroon'),
    LeadModel(number: '03320558995', name: 'Zain'),
    LeadModel(number: '03472792742', name: 'Hassan'),

  ];
  List<LeadModel> searchleadList=[];
  bool listChoice =false;


  void searchLead(String query){
    searchleadList=leadList;

    final suggestion=searchleadList.where((lead)  {
final leadtile=lead.name.toLowerCase();
final input=query.toLowerCase();
return leadtile.contains(input);
    }).toList();
    setState(() {
      searchleadList=suggestion;
    });
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
                    padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:  [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 39,
                              //    backgroundImage: AssetImage(('assets/images/images.png')),
                            ),
                            InkWell(
                                onTap: ()async{
                               await   getLeads();
                                  setState(() {

                                  });
                                },
                                child: Column(
                                  children: [
                                    Text(x.toString()),
                                    Icon(Icons.power_settings_new,size: 30,color: Colors.amber,),
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
                              fontWeight: FontWeight.bold, fontSize: 24,color: Colors.white),
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
                        children:  [
                          const SizedBox(height: 20,),
                          Container(
                              width:MediaQuery.of(context).size.width*0.70 ,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],

                                  borderRadius: BorderRadius.circular(30)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left:18.0),
                                child: TextField(
                                  controller:searchController ,
                                  decoration:  InputDecoration(
                                    prefixIcon:Icon(Icons.search) ,
                                      suffixIcon: GestureDetector(
                                          onTap: (){
                                            setState(() {
                                              searchleadList=leadList;
                                              searchController.clear();
                                            });
                                          },
                                          child: Icon(Icons.close)),
                                      border: InputBorder.none,


                                  ),
                                  onChanged: searchLead,
                                ),
                              )),
                          const  SizedBox(height: 40,),

                          SizedBox(
                            height: MediaQuery.of(context).size.height ,
                            child: ListView.builder(
                                itemCount: searchleadList.length,
                                itemBuilder: (BuildContext context,int index){
                                  var lead=searchleadList[index];

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 23.0,vertical: 10),
                                    child:  LeadTile(name:lead.name ,number: lead.number,),
                                  );
                                }
                            ),
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
  String name,number;
  LeadTile({required this.name,required this.number}) ;

  @override
  State<LeadTile> createState() => _LeadTileState();
}

class _LeadTileState extends State<LeadTile> {
  late AndroidIntent intent;

  @override
  void initState() {
    super.initState();


  }
  Future<void>LaunchCall(String num)async{
    AndroidIntent intent =  AndroidIntent(
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
            children:  [

              const CircleAvatar(
                radius: 30,
                // backgroundImage: AssetImage('assets/images/images.png'),
              )
              ,const SizedBox(width: 20,),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name,style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(widget.number,style: TextStyle(color: Colors.green)),

                ],
              ),
              const Spacer(),
              CircleAvatar(
                child: InkWell(

                    onTap: ()async=>{
                      // launch('tel://03131533387'),
                      await Permission.phone.request(),
                     await FlutterPhoneDirectCaller.callNumber(widget.number)
                      
                      // LaunchCall(widget.number),
                    },




                    child: const Icon(Icons.call,color: Colors.green,size: 30,)),
              )
            ],
          ),

        ],
      ),
    );
  }
}


class LeadModel {
  String name,number;

  LeadModel({required this.number,required this.name});





}