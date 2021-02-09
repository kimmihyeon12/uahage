import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'map_list.dart';
import 'package:uahage/homepagelist/sublist/restaurant_sublist.dart';
import 'package:geolocator/geolocator.dart';

import 'package:page_transition/page_transition.dart';
import 'package:fluttertoast/fluttertoast.dart';

class restaurant extends StatefulWidget {
  String loginOption;
  String userId;
  // String oldNickname;
  restaurant({Key key, this.userId, this.loginOption}) : super(key: key);
  @override
  _restaurantState createState() => _restaurantState();
}

class _restaurantState extends State<restaurant> {
  FToast fToast;
  String latitude = "";
  String longitude = "";
  String userId = "";
  String loginOption = "";
  String store_name1,
      address1,
      phone1,
      menu1,
      bed1,
      tableware1,
      meetingroom1,
      diapers1,
      playroom1,
      carriage1,
      nursingroom1,
      chair1;
  var list = true;
  int _currentMax = 0;
  ScrollController _scrollController = ScrollController();
  List<String> star_color_list = List(520);
  var star_color = false;
  bool toggle = false;

  String liststringdata = "restaurant";
  var listimage = [
    "./assets/listPage/clipGroup.png",
    "./assets/listPage/clipGroup1.png",
    "./assets/listPage/layer1.png",
    "./assets/listPage/layer2.png",
  ];
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

  @override
  void initState() {
    setState(() {
      loginOption = widget.loginOption;
      userId = widget.userId ?? "";
      // oldNickname = userId != "" ? getMyNickname().toString() : "";
    });

    _star_color();
    // _scrollController.addListener(() {
    //   if (_scrollController.position.pixels ==
    //       _scrollController.position.maxScrollExtent) {
    //     // setState(() {
    //     //   _isLoading = true;
    //     // });
    //     setState(() {
    //       _currentMax += 10;
    //     });
    //   }
    // });

    print("login opt in res " + loginOption);
    print("id in res " + userId);
    getCurrentLocation();
    super.initState();
  }

  getCurrentLocation() async {
    print("Geolocation started");
    LocationPermission permission = await Geolocator.requestPermission();

    final geoposition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      latitude = '${geoposition.latitude}';
      longitude = '${geoposition.longitude}';
    });
  }

  Future click_star() async {
    Map<String, dynamic> ss = {
      "user_id": userId + loginOption,
      "store_name": store_name1,
      "address": address1,
      "phone": phone1,
      "menu": menu1,
      "bed": bed1,
      "tableware": tableware1,
      "meetingroom": meetingroom1,
      "diapers": diapers1,
      "playroom": playroom1,
      "carriage": carriage1,
      "nursingroom": nursingroom1,
      "chair": chair1,
      "star_color": star_color,
    };
    var response = await http.post(
      "http://211.55.236.196:3000/star",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(ss),
    );
  }

  Future _star_color() async {
    var data = await http.get(
        'http://211.55.236.196:3000/starcolor?user_id=$userId$loginOption&tablename=$liststringdata');
    var dec = jsonDecode(data.body);
    // print(dec);
    for (int i = 0; i < dec.length; i++) {
      //  print(dec[i]["store_name"].toString());
      star_color_list[i] = dec[i]["store_name"].toString();
      print(star_color_list[i]);
    }
  }

  Future<List<Restaurant>> _getrestaurant() async {
    List<Restaurant> restaurants = [];

    var data = await http.get(
        // 'http://211.55.236.196:3000/getList/$liststringdata?maxCount=$_currentMax');
        'http://211.55.236.196:3000/getList/$liststringdata');

    var jsonData = json.decode(data.body);
    for (var r in jsonData) {
      Restaurant restaurant = Restaurant(
          r["id"],
          r["store_name"],
          r["address"],
          r["phone"],
          r["menu"],
          r["bed"],
          r["Tableware"],
          r["meetingroom"],
          r["diapers"],
          r["playroom"],
          r["carriage"],
          r["nursingroom"],
          r["chair"]);

      restaurants.add(restaurant);
    }

    return restaurants;
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var ScreenHeight = MediaQuery.of(context).size.height;
    var ScreenWidth = MediaQuery.of(context).size.width;
    double screenHeight = 2668 / MediaQuery.of(context).size.height;
    double screenWidth = 1500 / MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    Image.asset(
                      "./assets/listPage/backbutton.png",
                      width: 44 / (1501 / ScreenWidth),
                      height: 76 / (2667 / ScreenHeight),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                      left: 45 / screenWidth,
                    )),
                    Container(
                      // width: 310 / screenWidth,
                      child: Text(
                        '식당·카페',
                        style: TextStyle(
                            fontSize: 62 / screenWidth,
                            fontFamily: 'NotoSansCJKkr_Medium',
                            color: Color.fromRGBO(255, 114, 148, 1.0)),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 30 / screenWidth),
                child: toggle
                    ? InkWell(
                        onTap: () {
                          setState(() {
                            toggle = !toggle;
                            if (list) {
                              list = false;
                            } else {
                              list = true;
                            }
                          });
                        },
                        child: Image.asset(
                          './assets/on.png',
                          width: 284 / screenWidth,
                          height: 133 / screenHeight,
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          setState(() {
                            toggle = !toggle;
                            if (list) {
                              list = false;
                            } else {
                              list = true;
                            }
                          });
                        },
                        child: Image.asset(
                          './assets/off.png',
                          width: 284 / screenWidth,
                          height: 133 / screenHeight,
                        ),
                      ),
                // LiteRollingSwitch(
                //   value: false,
                //   textOn: '목록',
                //   textOff: '지도',
                //   colorOn: Color.fromRGBO(255, 114, 148, 1.0),
                //   colorOff: Color.fromRGBO(255, 114, 148, 1.0),

                //   //    iconOn:  , iconOff: , textSize:
                //   onChanged: (bool state) {},
                //   onTap: () {
                //     /*     Navigator.pushReplacement(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => map_list(),
                //           ));*/
                //     setState(() {
                //       if (list) {
                //         list = false;
                //       } else {
                //         list = true;
                //       }
                //     });
                //   },
                // ),
              ),
            ],
          ),
        ),
        body: list
            ? FutureBuilder(
                future: _getrestaurant(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return Center(
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 5.0,
                          valueColor: new AlwaysStoppedAnimation<Color>(
                            Colors.pinkAccent,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return ListView.builder(
                        // controller: _scrollController,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          print('snapshot.data.length');
                          // print(snapshot.data.id[index]);
                          return Card(
                            elevation: 0.3,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      child: restaurant_sublist(
                                          index: index,
                                          storename:
                                              snapshot.data[index].store_name,
                                          address: snapshot.data[index].address,
                                          bed: snapshot.data[index].bed,
                                          phone: snapshot.data[index].phone,
                                          menu: snapshot.data[index].menu,
                                          tableware:
                                              snapshot.data[index].tableware,
                                          meetingroom:
                                              snapshot.data[index].meetingroom,
                                          diapers: snapshot.data[index].diapers,
                                          playroom: snapshot.data[index].playroom,
                                          carriage: snapshot.data[index].carriage,
                                          nursingroom:
                                              snapshot.data[index].nursingroom,
                                          chair: snapshot.data[index].chair,
                                          userId: userId,
                                          loginOption: loginOption),
                                      duration: Duration(milliseconds: 250),
                                      reverseDuration:
                                          Duration(milliseconds: 100),
                                    ));
                              },
                              child: Container(
                                  height: 500 / (2667 / ScreenHeight),
                                  padding: EdgeInsets.only(
                                    top: 30 / (2667 / ScreenHeight),
                                    left: 26 / (1501 / ScreenWidth),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ((){
                                        if(index % 4 == 1){
                                         return Image.asset(
                                            listimage[0],
                                            height: 414 / (2667 / ScreenHeight),
                                          );
                                        }
                                        else if(index % 4 == 2){
                                          return Image.asset(
                                            listimage[1],
                                            height:
                                            414 / (2667 / ScreenHeight),
                                          );
                                        }
                                        else if(index % 4 == 3){
                                          return Image.asset(
                                            listimage[2],
                                            height:
                                            414 / (2667 / ScreenHeight),
                                          );
                                        }else{
                                          return Image.asset(
                                            listimage[3],
                                            height:
                                            414 / (2667 / ScreenHeight),
                                          );
                                        }
                                      }()),

                                      Padding(
                                          padding: EdgeInsets.only(
                                        left: 53 /
                                            screenWidth,
                                      )),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width:
                                                    750 / (1501 / ScreenWidth),
                                                height:
                                                    100 / (2667 / ScreenHeight),
                                                child: Text(
                                                  snapshot
                                                      .data[index].store_name,
                                                  style: TextStyle(
                                                    fontSize: 56 /
                                                        screenWidth,
                                                    fontFamily:
                                                        'NotoSansCJKkr_Medium',
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                padding: EdgeInsets.all(0),
                                                constraints: BoxConstraints(
                                                  maxWidth: 170 /
                                                      (1501 / ScreenWidth),
                                                  maxHeight: 170 /
                                                      (2667 / ScreenHeight),
                                                ),
                                                icon: Image.asset(
                                                  star_color_list[index] ==
                                                          'null'
                                                      ? "./assets/listPage/star_grey.png"
                                                      : "./assets/listPage/star_color.png",
                                                  height: 60 /
                                                      (2667 / ScreenHeight),
                                                ),
                                                onPressed: loginOption ==
                                                        "login"
                                                    ? () {
                                                        Fluttertoast.showToast(
                                                          msg: "  로그인 해주세요!  ",
                                                          toastLength: Toast
                                                              .LENGTH_SHORT,
                                                          gravity: ToastGravity
                                                              .BOTTOM,
                                                          timeInSecForIosWeb: 1,
                                                          backgroundColor:
                                                              Colors.black45,
                                                          textColor:
                                                              Colors.white,
                                                          fontSize: 56 /
                                                               screenWidth,
                                                        );
                                                      }
                                                    : () async {
                                                        setState(() {
                                                          store_name1 = snapshot
                                                              .data[index]
                                                              .store_name;
                                                          address1 = snapshot
                                                              .data[index]
                                                              .address;
                                                          bed1 = snapshot
                                                              .data[index].bed;
                                                          phone1 = snapshot
                                                              .data[index]
                                                              .phone;
                                                          menu1 = snapshot
                                                              .data[index].menu;
                                                          tableware1 = snapshot
                                                              .data[index]
                                                              .tableware;
                                                          meetingroom1 =
                                                              snapshot
                                                                  .data[index]
                                                                  .meetingroom;
                                                          diapers1 = snapshot
                                                              .data[index]
                                                              .diapers;
                                                          playroom1 = snapshot
                                                              .data[index]
                                                              .playroom;
                                                          carriage1 = snapshot
                                                              .data[index]
                                                              .carriage;
                                                          nursingroom1 =
                                                              snapshot
                                                                  .data[index]
                                                                  .nursingroom;
                                                          chair1 = snapshot
                                                              .data[index]
                                                              .chair;

                                                          if (star_color_list[
                                                                  index] ==
                                                              'null') {
                                                            setState(() {
                                                              star_color = true;
                                                              star_color_list[
                                                                      index] =
                                                                  "test";
                                                            });
                                                          } else {
                                                            setState(() {
                                                              star_color =
                                                                  false;
                                                              star_color_list[
                                                                      index] =
                                                                  'null';
                                                            });
                                                          }

                                                          click_star();

                                                          //    _star_color();
                                                        });
                                                      },
                                              ),
                                            ],
                                          ),
                                          Padding(
                                              padding: EdgeInsets.only(
                                            top: 10 / (2667 / ScreenHeight),
                                          )),
                                          Container(
                                            height: 80 / (2667 / ScreenHeight),
                                            width: 800 / (1501 / ScreenWidth),
                                            child: Text(
                                              snapshot.data[index].address,
                                              style: TextStyle(
                                                // fontFamily: 'NatoSans',
                                                color: Colors.grey,
                                                fontSize:
                                                    45 / screenWidth,
                                                fontFamily:
                                                    'NotoSansCJKkr_Medium',
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: 80 / (2667 / ScreenHeight),
                                            width: 800 / (1501 / ScreenWidth),
                                            child: Text(
                                              snapshot.data[index].phone,
                                              style: TextStyle(
                                                // fontFamily: 'NatoSans',
                                                color: Colors.grey,
                                                fontSize:
                                                    45 / 60 / screenWidth,
                                                fontFamily:
                                                    'NotoSansCJKkr_Medium',
                                              ),
                                            ),
                                          ),
                                          SafeArea(
                                            child: Container(
                                              height: 150 / (2667 / ScreenHeight),
                                              width: 800 / (1501 / ScreenWidth),
                                              alignment: Alignment.bottomRight,
                                              child: Row(
                                                children: [
                                                  chair(
                                                      snapshot.data[index].chair),
                                                  carriage(snapshot
                                                      .data[index].carriage),
                                                  menu(snapshot.data[index].menu),
                                                  bed(snapshot.data[index].bed),
                                                  tableware(snapshot
                                                      .data[index].tableware),
                                                  meetingroom(snapshot
                                                      .data[index].meetingroom),
                                                  diapers(snapshot
                                                      .data[index].diapers),
                                                  playroom(snapshot
                                                      .data[index].playroom),
                                                  nursingroom(snapshot
                                                      .data[index].nursingroom),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  )),
                            ),
                          );
                        });
                  }
                },
              )
            : map_list(
                latitude: latitude, longitude: longitude, list: liststringdata),
      ),
    );
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

class Restaurant {
  final int id;
  final String store_name;
  final String address;
  final String phone;
  final String menu;
  final String bed;
  final String tableware;
  final String meetingroom;
  final String diapers;
  final String playroom;
  final String carriage;
  final String nursingroom;
  final String chair;

  Restaurant(
      this.id,
      this.store_name,
      this.address,
      this.phone,
      this.menu,
      this.bed,
      this.tableware,
      this.meetingroom,
      this.diapers,
      this.playroom,
      this.carriage,
      this.nursingroom,
      this.chair);
}
