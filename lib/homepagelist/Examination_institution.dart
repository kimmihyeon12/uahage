import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:uahage/homepagelist/map_list.dart';
import 'package:uahage/homepagelist/sublist/exaimination_institution_sublist.dart';
import 'package:page_transition/page_transition.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uahage/StarManage.dart';

class examination_institution extends StatefulWidget {
  String loginOption;
  String userId;
  String latitude = "";
  String longitude = "";
  String Area = "";
  String Locality = "";
  // String oldNickname;
  examination_institution(
      {Key key,
      this.userId,
      this.loginOption,
      this.latitude,
      this.longitude,
      this.Area,
      this.Locality})
      : super(key: key);
  @override
  _examination_institutionState createState() =>
      _examination_institutionState();
}

class _examination_institutionState extends State<examination_institution> {
  String latitude = "";
  String longitude = "";
  String Area = "";
  String Locality = "";
  String userId = "";
  String loginOption = "";
  String liststringdata = 'Examination_institution';
  String store_name1, address1, phone1, Examination_item1;
  var star_color = false;
  List<String> star_color_list = [];
  var list = true;
  int _currentMax = 0;
  var indexcount = 0;
  // ScrollController _scrollController = ScrollController();

  var listimage = [
    "https://uahage.s3.ap-northeast-2.amazonaws.com/hospital_image/image1.png",
    "https://uahage.s3.ap-northeast-2.amazonaws.com/hospital_image/image2.png",
  ];

  Future<List<Examination_institution>> myFuture;
  List<Examination_institution> examination_institutions = [];
  ScrollController _scrollController = ScrollController();
  bool _isLoading;
  @override
  void initState() {
    // setState(() {
    _isLoading = false;
    loginOption = widget.loginOption;
    userId = widget.userId ?? "";
    latitude = widget.latitude;
    longitude = widget.longitude;
    Area = widget.Area ?? "";
    Locality = widget.Locality ?? "";
    // oldNickname = userId != "" ? getMyNickname().toString() : "";
    // });
    _star_color();
    myFuture = _getrestaurant();

    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      // double delta =
      //     100.0; // or something else..maxScroll - currentScroll <= delta
      if (currentScroll == maxScroll && !_isLoading) {
        print("scrolling");
        print("isloading: $_isLoading");
        _currentMax += 10;
        _isLoading = true;
        _getrestaurant();
      }
    });
    // getCurrentLocation();
    super.initState();
  }

  StarManage starInsertDelete = new StarManage();
  Future click_star() async {
    await starInsertDelete.click_star(
        userId + loginOption,
        store_name1,
        address1,
        phone1,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        Examination_item1,
        star_color,
        liststringdata);
  }

  Future _star_color() async {
    var data = await http.get(
        'http://13.209.41.43/starcolor?user_id=$userId$loginOption&tablename=$liststringdata');
    var dec = jsonDecode(data.body);
    // print(dec);
    for (int i = 0; i < dec.length; i++) {
      star_color_list.add(dec[i]["store_name"].toString());
    }
    setState(() {});
  }

  Future<List<Examination_institution>> _getrestaurant() async {
    var data = await http.get(
        'http://13.209.41.43/getList/$liststringdata?maxCount=$_currentMax');
    //?maxCount=$_currentMax

    var jsonData = json.decode(data.body);
    for (var r in jsonData) {
      Examination_institution examination_institution = Examination_institution(
        r["id"],
        r["store_name"],
        r["address"],
        r["phone"],
        r["Examination_item"],
      );

      examination_institutions.add(examination_institution);
    }
    setState(() {
      _isLoading = false;
    });

    return examination_institutions;
  }

  SpinKitThreeBounce buildSpinKitThreeBounce(double size, double screenWidth) {
    return SpinKitThreeBounce(
      color: Color(0xffFF728E),
      size: size / screenWidth,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool toggle = false;
  @override
  Widget build(BuildContext context) {
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
                        width: 44 / screenWidth,
                        height: 76 / screenHeight,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 62 / screenWidth,
                        ),
                      ),
                      Container(
                        // width: 310 / screenWidth,
                        // margin: EdgeInsets.only(left: 50 / screenWidth),
                        child: Text(
                          '병원',
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
                              if (indexcount == 1)
                                indexcount = 0;
                              else
                                indexcount = 1;
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
                              if (indexcount == 1)
                                indexcount = 0;
                              else
                                indexcount = 1;
                            });
                          },
                          child: Image.asset(
                            './assets/off.png',
                            width: 284 / screenWidth,
                            height: 133 / screenHeight,
                          ),
                        ),
                ),
              ],
            ),
          ),
          body: IndexedStack(index: indexcount, children: <Widget>[
            examination_institution_view(context, screenWidth, screenHeight),
            map_list(
                userId: userId,
                loginOption: loginOption,
                latitude: latitude,
                longitude: longitude,
                list: liststringdata,
                Area: Area,
                Locality: Locality),
          ])),
    );
  }

  Widget examination_institution_view(context, screenWidth, screenHeight) {
    return FutureBuilder(
      future: myFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("${snapshot.error}"),
          );
        } else if (snapshot.hasData &&
            snapshot.data != null &&
            star_color_list.length != 0) {
          return ListView.builder(
              controller: _scrollController,
              itemCount: examination_institutions?.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 0.3,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: examination_institution_sublist(
                              index: index,
                              storename: snapshot.data[index].store_name,
                              address: snapshot.data[index].address,
                              phone: snapshot.data[index].phone,
                              examinationitem:
                                  snapshot.data[index].Examination_item,
                              userId: userId,
                              loginOption: loginOption,
                            ),
                            duration: Duration(milliseconds: 250),
                            reverseDuration: Duration(milliseconds: 100),
                          ));
                    },
                    child: Container(
                        // height: 500 / screenHeight,
                        padding: EdgeInsets.only(
                          top: 30 / screenHeight,
                          left: 26 / screenWidth,
                          bottom: 40 / screenHeight,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  // border: Border.all(width: 3.0),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                        (() {
                                          if (index % 2 == 0)
                                            return listimage[0];
                                          else
                                            return listimage[1];
                                        }()),
                                      ),
                                      fit: BoxFit.fitHeight),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              height: 414 / screenHeight,
                              width: 414 / screenHeight,
                            ),
                            // (() {
                            //   if (index % 2 == 0) {
                            //     return Image.asset(
                            //       listimage[0],
                            //       height: 414 / screenHeight,
                            //     );
                            //   } else {
                            //     return Image.asset(
                            //       listimage[1],
                            //       height: 414 / screenHeight,
                            //     );
                            //   }
                            // }()),
                            Padding(
                                padding: EdgeInsets.only(
                              left: 53 / screenWidth,
                            )),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(
                                        top: 10 / screenHeight)),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 800 / screenWidth,
                                      height: 90 / screenHeight,
                                      child: Text(
                                        snapshot.data[index].store_name,
                                        style: TextStyle(
                                          fontSize: 56 / screenWidth,
                                          fontFamily: 'NotoSansCJKkr_Medium',
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.all(0),
                                      constraints: BoxConstraints(
                                        maxWidth: 70 / screenWidth,
                                        maxHeight: 70 / screenHeight,
                                      ),
                                      icon: Image.asset(
                                        star_color_list[index] == 'null'
                                            ? "./assets/listPage/star_grey.png"
                                            : "./assets/listPage/star_color.png",
                                        height: 60 / screenHeight,
                                      ),
                                      onPressed: loginOption == "login"
                                          ? () {
                                              Fluttertoast.showToast(
                                                msg: "  로그인 해주세요!  ",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.black45,
                                                textColor: Colors.white,
                                                fontSize: 48 / screenWidth,
                                              );
                                            }
                                          : () async {
                                              setState(() {
                                                store_name1 = snapshot
                                                    .data[index].store_name;
                                                address1 = snapshot
                                                    .data[index].address;
                                                phone1 =
                                                    snapshot.data[index].phone;
                                                Examination_item1 = snapshot
                                                    .data[index]
                                                    .Examination_item;

                                                if (star_color_list[index] ==
                                                    'null') {
                                                  star_color = true;
                                                  star_color_list[index] =
                                                      "test";
                                                  print(
                                                      ' star_color_list[index]');
                                                  print(star_color_list[index]);
                                                } else {
                                                  star_color = false;
                                                  star_color_list[index] =
                                                      'null';
                                                }

                                                click_star();
                                              });
                                            },
                                    ),
                                  ],
                                ),
                                Container(
                                  // height: 350 / screenHeight,
                                  width: 650 / screenWidth,
                                  child: Text(
                                    snapshot.data[index].address,
                                    style: TextStyle(
                                      // fontFamily: 'NatoSans',
                                      color: Colors.grey,
                                      fontSize: 56 / screenWidth,
                                      fontFamily: 'NotoSansCJKkr_Medium',
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )),
                  ),
                );
              });
        } else {
          return Center(
            child: SizedBox(
                width: 60,
                height: 60,
                child: buildSpinKitThreeBounce(80, screenWidth)),
          );
        }
      },
    );
  }
}

class Examination_institution {
  final int id;
  final String store_name;
  final String address;
  final String phone;
  final String Examination_item;

  Examination_institution(this.id, this.store_name, this.address, this.phone,
      this.Examination_item);
}
