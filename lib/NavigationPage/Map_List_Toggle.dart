import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:uahage/homepagelist/sublist/restaurant_sublist.dart';
import 'dart:convert';
class Map_List_Toggle extends StatefulWidget {
  Map_List_Toggle({Key key, this.latitude, this.longitude, this.searchkey , this.userId, this.loginOption})
      : super(key: key);
  String userId;
  String loginOption;
  String latitude;
  String longitude;
  var searchkey;
  @override
  _Map_List_ToggleState createState() => _Map_List_ToggleState();
}

class _Map_List_ToggleState extends State<Map_List_Toggle> {
 @override
  var iconimage = [
    "./assets/listPage/menu.png",
    "./assets/listPage/bed.png",
    "./assets/listPage/tableware.png",
    "./assets/listPage/meetingroom.png",
    "./assets/listPage/diapers.png",
    "./assets/listPage/playroom.png",
    "./assets/listPage/carriage.png",
    "./assets/listPage/nursingroom.png",
    "./assets/listPage/chair.png",
  ];
  String userId = "";
  String loginOption = "";

  var switchbtn = false;
  WebViewController controller;
  var searchbtn = false;
  var i = 0;
  var Message;
  var star_color = false;
   var index = 1;
  List<String> store_namelist = List(500);
  List<String> addresslist = List(500);
  void initState() {
    super.initState();
    loginOption = widget.loginOption;
    userId = widget.userId ?? "";
  }
  Future click_star() async {
    print("clicking start $star_color");
    Map<String, dynamic> ss = {
      "user_id": userId + loginOption,
      "store_name": Message[0],
      "address": Message[1],
      "phone": Message[2],
      "menu": Message[3],
      "bed": Message[4],
      "tableware": Message[5],
      "meetingroom": Message[6],
      "diapers": Message[7],
      "playroom": Message[8],
      "carriage": Message[9],
      "nursingroom": Message[10],
      "chair": Message[11],
      "star_color": star_color,
      "Examination_item": null
    };
    print(ss);
    var response = await http.post(
      "http://13.209.41.43/star",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(ss),
    );
  }
  Widget build(BuildContext context) {
    var latitude = widget.latitude;
    var longitude = widget.longitude;
    var searchkey = widget.searchkey;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    var ScreenHeight = MediaQuery.of(context).size.height;
    var ScreenWidth = MediaQuery.of(context).size.width;
    double screenHeight = 2668 / MediaQuery.of(context).size.height;
    double screenWidth = 1500 / MediaQuery.of(context).size.width;

    return switchbtn
        ? WillPopScope(
            onWillPop: _onbackpressed,
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                toolbarHeight: 250 / screenHeight,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Row(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(
                      top: 500 / screenHeight,
                    )),
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_sharp),
                      iconSize: 100 / screenWidth,
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          searchbtn = false;
                          print(searchbtn);
                        });
                      },
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                      left: 900 / screenWidth,
                    )),
                    InkWell(
                      child: Image.asset(
                        './assets/off.png',
                        width: 290 / screenWidth,
                        height: 183 / screenHeight,
                      ),
                      onTap: () {
                        setState(() {
                          switchbtn = false;
                          print(searchbtn);
                          i = 0;
                        });
                      },
                    ),
                  ],
                ),
              ),
              body: ListView.builder(
                  itemCount: i,
                  itemBuilder: (context, index) {
                    print('snapshot.data.length');
                    // print(snapshot.data.id[index]);
                    return Card(
                      elevation: 0.3,
                      child: InkWell(
                        child: Container(
                            height: 400 / screenHeight,
                            padding: EdgeInsets.only(
                              top: 30 / screenHeight,
                              left: 26 / screenWidth,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(
                                  top: 200 /
                                      (1501 /
                                          MediaQuery.of(context).size.width),
                                )),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 750 / screenWidth,
                                      height: 100 / screenHeight,
                                      child: Text(
                                        store_namelist[index],
                                        style: TextStyle(
                                          fontSize: 56 / screenWidth,
                                          fontFamily: 'NotoSansCJKkr_Medium',
                                        ),
                                      ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(
                                      top: 10 / screenHeight,
                                    )),
                                    SafeArea(
                                      child: Container(
                                        height: 80 / screenHeight,
                                        width: 800 / screenWidth,
                                        child: Text(
                                          addresslist[index],
                                          style: TextStyle(
                                            // fontFamily: 'NatoSans',
                                            color: Colors.grey,
                                            fontSize: 45 / screenWidth,
                                            fontFamily: 'NotoSansCJKkr_Medium',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                      ),
                    );
                  }),
            ),
          )
        : WillPopScope(
            onWillPop: _onbackpressed,
            child: Scaffold(
              body: SafeArea(
                child: Stack(children: [
                  WebView(
                    onWebViewCreated:
                        (WebViewController webViewController) async {
                      controller = webViewController;
                      await controller.loadUrl(
                          "http://112.187.123.9:3000/homesearch?lat=$latitude&long=$longitude&address='$searchkey'");
                    },
                    javascriptMode: JavascriptMode.unrestricted,
                    javascriptChannels: Set.from([
                      JavascriptChannel(
                          name: 'Print',
                          onMessageReceived: (JavascriptMessage message) {
                            var messages = message.message;
                            var ex = messages.split(",");
                            print(ex);
                            setState(() {
                              for (int j = 0; j < 2; j++) {
                                store_namelist[i] = ex[0];
                                addresslist[i] = ex[1];
                                print(i.toString() +
                                    "store_namelist" +
                                    store_namelist[i]);
                                print(i.toString() +
                                    "addresslist" +
                                    addresslist[i]);
                              }
                              i++;
                            });
                          }),
                      JavascriptChannel(
                          name: 'Print1',
                          onMessageReceived: (JavascriptMessage message) {
                            var messages = message.message;
                             Message = messages.split(",");
                            showPopUpbottomMenu(
                                context, screenHeight, screenWidth);
                          })
                    ]),
                  ),
                  Row(
                    children: [
                      Padding(
                          padding: EdgeInsets.only(
                        top: 250 / screenHeight,
                      )),
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_sharp),
                        iconSize: 100 / screenWidth,
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            searchbtn = false;

                            print(searchbtn);
                          });
                        },
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                        left: 950 / screenWidth,
                      )),
                      FutureBuilder(
                        future: Future.delayed(Duration(milliseconds: 550)),
                        builder: (c, s) =>
                            s.connectionState == ConnectionState.done
                                ? InkWell(
                                    child: Image.asset(
                                      './assets/on.png',
                                      width: 290 / screenWidth,
                                      height: 183 / screenHeight,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        switchbtn = true;
                                        print(switchbtn);
                                      });
                                    },
                                  )
                                : Text(
                                    "Loading..",
                                    style: TextStyle(
                                      fontSize: 45 / screenWidth,
                                      fontFamily: 'NotoSansCJKkr_Bold',
                                      letterSpacing: 0,
                                      color: Color(0xffff7292),
                                    ),
                                  ),
                      ),
                    ],
                  )
                ]),
              ),
            ),
          );
  }
  Future<Object> showPopUpbottomMenu(
      BuildContext context, double screenHeight, double screenWidth) {
    setState(() => {
      star_color = false,
    });
    return showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext buildContext, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return StatefulBuilder(builder: (context, setState) {
            return Builder(builder: (context) {
              return Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: 2100 / (screenHeight),
                        bottom: 50 / screenHeight,
                        left: 33 / screenWidth,
                        right: 33 / screenWidth),
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      elevation: 1,
                      color: Colors.white,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: restaurant_sublist(
                                  index: index++,
                                  storename: Message[0],
                                  address: Message[1],
                                  phone: Message[2],
                                  menu: Message[3],
                                  bed: Message[4],
                                  tableware: Message[5],
                                  meetingroom: Message[6],
                                  diapers: Message[7],
                                  playroom: Message[8],
                                  carriage: Message[9],
                                  nursingroom: Message[10],
                                  chair: Message[11],
                                  userId: userId,
                                  loginOption: loginOption,
                                ),
                                duration: Duration(milliseconds: 100),
                                reverseDuration: Duration(milliseconds: 100),
                              ));
                        },
                        child: Row(
                          children: [
                            Padding(
                                padding: EdgeInsets.only(
                                  left: 30 /
                                      (1501 / MediaQuery.of(context).size.width),
                                )),
                            Image.asset(
                              "./assets/listPage/clipGroup1.png",
                              height: 414 / screenHeight,
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                  left: 40 /
                                      (1501 / MediaQuery.of(context).size.width),
                                )),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Padding(
                                //     padding: EdgeInsets.only(
                                //   top: 20 / screenHeight,
                                // )),
                                Row(
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          width: 680 / screenWidth,
                                          // height: 100 / screenHeight,
                                          child: Text(Message[0],
                                              style: TextStyle(
                                                  color:
                                                  const Color(0xff010000),
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily:
                                                  "NotoSansCJKkr_Bold",
                                                  fontStyle: FontStyle.normal,
                                                  fontSize: 56 / screenWidth),
                                              textAlign: TextAlign.left),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      // padding: EdgeInsets.all(0),
                                      icon: Image.asset(
                                          star_color
                                              ? "./assets/listPage/star_color.png"
                                              : "./assets/listPage/star_grey.png",
                                          height: 60 / screenHeight),
                                      onPressed: () {
                                        setState(() {
                                          star_color = !star_color;
                                        });
                                        loginOption != "login"
                                            ? click_star()
                                            : null;
                                      },
                                    ),
                                  ],
                                ),
                                Padding(
                                    padding: EdgeInsets.only(
                                      top: 10 / screenHeight,
                                    )),
                                Container(
                                  // height: 150 / screenHeight,
                                  width: 800 / screenWidth,
                                  child: Text(Message[1],
                                      style: TextStyle(
                                          color: const Color(0xffb0b0b0),
                                          fontWeight: FontWeight.w500,
                                          fontFamily: "NotoSansCJKkr_Medium",
                                          fontStyle: FontStyle.normal,
                                          fontSize: 45 / screenWidth),
                                      textAlign: TextAlign.left),
                                ),
                                Container(
                                  height: 150 / screenHeight,
                                  width: 800 / screenWidth,
                                  alignment: Alignment.bottomRight,
                                  child: Row(children: [
                                    menu(Message[3]),
                                    bed(Message[4]),
                                    tableware(Message[5]),
                                    meetingroom(Message[6]),
                                    diapers(Message[7]),
                                    playroom(Message[8]),
                                    carriage(Message[9]),
                                    nursingroom(Message[10]),
                                    chair(Message[11]),
                                  ]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            });
          });
        },
        barrierDismissible: true,
        barrierLabel:
        MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: null,
        transitionDuration: const Duration(milliseconds: 150));
  }
  Future<bool> _onbackpressed() {
    setState(() {
      //  searchbtn = false;
      //  switchbtn = false;
      return Navigator.pop(context, 'Yep!');
      i = 0;
    });
  }
  menu(String menu) {
    var menus = menu.toString();

    return menus == "○"
        ? Container(
      child: Image.asset(iconimage[0], width: 30, height: 30),
      padding: EdgeInsets.only(
          left: 20 / (1501 / MediaQuery.of(context).size.width)),
    )
        : Container(
      child: Image.asset(iconimage[0], width: 0, height: 0),
      padding: EdgeInsets.only(
          left: 0 / (1501 / MediaQuery.of(context).size.width)),
    );
  }

  bed(String bed) {
    var beds = bed.toString();

    return beds == "○"
        ? Container(
      child: Image.asset(iconimage[1], width: 30, height: 30),
      padding: EdgeInsets.only(
          left: 20 / (1501 / MediaQuery.of(context).size.width)),
    )
        : Container(
      child: Image.asset(iconimage[1], width: 0, height: 0),
      padding: EdgeInsets.only(
          left: 0 / (1501 / MediaQuery.of(context).size.width)),
    );
  }

  tableware(String tableware) {
    var tablewares = tableware.toString();

    return tablewares == "○"
        ? Container(
      child: Image.asset(iconimage[2], width: 30, height: 30),
      padding: EdgeInsets.only(
          left: 20 / (1501 / MediaQuery.of(context).size.width)),
    )
        : Container(
      child: Image.asset(iconimage[2], width: 0, height: 0),
      padding: EdgeInsets.only(
          left: 0 / (1501 / MediaQuery.of(context).size.width)),
    );
  }

  meetingroom(String meetingroom) {
    var meetingrooms = meetingroom.toString();

    return meetingrooms == "○"
        ? Container(
      child: Image.asset(iconimage[3], width: 30, height: 30),
      padding: EdgeInsets.only(
          left: 20 / (1501 / MediaQuery.of(context).size.width)),
    )
        : Container(
      child: Image.asset(iconimage[3], width: 0, height: 0),
      padding: EdgeInsets.only(
          left: 0 / (1501 / MediaQuery.of(context).size.width)),
    );
  }

  diapers(String diapers) {
    var diaperss = diapers.toString();

    return diaperss == "○"
        ? Container(
      child: Image.asset(iconimage[4], width: 30, height: 30),
      padding: EdgeInsets.only(
          left: 20 / (1501 / MediaQuery.of(context).size.width)),
    )
        : Container(
      child: Image.asset(iconimage[4], width: 0, height: 0),
      padding: EdgeInsets.only(
          left: 0 / (1501 / MediaQuery.of(context).size.width)),
    );
  }

  playroom(String playroom) {
    var playrooms = playroom.toString();

    return playrooms == "○"
        ? Container(
      child: Image.asset(iconimage[5], width: 30, height: 30),
      padding: EdgeInsets.only(
          left: 20 / (1501 / MediaQuery.of(context).size.width)),
    )
        : Container(
      child: Image.asset(iconimage[5], width: 0, height: 0),
      padding: EdgeInsets.only(
          left: 0 / (1501 / MediaQuery.of(context).size.width)),
    );
  }

  carriage(String carriage) {
    var carriages = carriage.toString();

    return carriages == "○"
        ? Container(
      child: Image.asset(iconimage[6], width: 30, height: 30),
      padding: EdgeInsets.only(
          left: 20 / (1501 / MediaQuery.of(context).size.width)),
    )
        : Container(
      child: Image.asset(iconimage[6], width: 0, height: 0),
    );
  }

  nursingroom(String nursingroom) {
    var nursingrooms = nursingroom.toString();

    return nursingrooms == "○"
        ? Container(
      child: Image.asset(iconimage[7], width: 30, height: 30),
      padding: EdgeInsets.only(
          left: 20 / (1501 / MediaQuery.of(context).size.width)),
    )
        : Container(
      child: Image.asset(iconimage[7], width: 0, height: 0),
      padding: EdgeInsets.only(
          left: 0 / (1501 / MediaQuery.of(context).size.width)),
    );
  }

  chair(String chair) {
    var chairs = chair.toString();

    return chairs == "○"
        ? Container(
      child: Image.asset(iconimage[8], width: 30, height: 30),
      padding: EdgeInsets.only(
          left: 20 / (1501 / MediaQuery.of(context).size.width)),
    )
        : Container(
      child: Image.asset(iconimage[8], width: 0, height: 0),
      padding: EdgeInsets.only(
          left: 0 / (1501 / MediaQuery.of(context).size.width)),
    );
  }
}
