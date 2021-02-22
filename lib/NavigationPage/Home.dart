import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:uahage/NavigationPage/Keyword.dart';
import 'package:uahage/homepagelist/experience_center.dart';
import 'package:uahage/homepagelist/restaurant.dart';
import 'package:uahage/homepagelist/kids_cafe.dart';
import 'package:uahage/homepagelist/Examination_institution.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:geolocator/geolocator.dart';

class homePage extends StatefulWidget {
  String loginOption;
  String userId;
  // String oldNickname;
  homePage({Key key, this.userId, this.loginOption}) : super(key: key);
  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  //FToast fToast;
  String loginOption = "";
  String userId = "";

  var searchkey = "";

  String latitude = "";
  String longitude = "";
  var i;

  WebViewController controller;
  List<String> store_namelist = List(500);
  List<String> addresslist = List(500);
  @override
  void initState() {
    super.initState();
    setState(() {
      loginOption = widget.loginOption;
      userId = widget.userId ?? "";
      // oldNickname = userId != "" ? getMyNickname().toString() : "";
    });

    getCurrentLocation();
    i = 0;
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  getCurrentLocation() async {
    final geoposition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      latitude = geoposition.latitude.toString();
      longitude = geoposition.longitude.toString();
    });
  }

  int index = 1;

  SpinKitThreeBounce buildSpinKitThreeBounce(double size, double screenWidth) {
    return SpinKitThreeBounce(
      color: Color(0xffFF728E),
      size: size / screenWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);

    bool isIOS = Platform.isIOS;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    var ScreenHeight = MediaQuery.of(context).size.height;
    var ScreenWidth = MediaQuery.of(context).size.width;
    double screenHeight = 2668 / MediaQuery.of(context).size.height;
    double screenWidth = 1500 / MediaQuery.of(context).size.width;
    imageView(fileName) {
      return Image.network(
        // 'http://hohoco.dothome.co.kr/img/$fileName.png',
        "https://uahage.s3.ap-northeast-2.amazonaws.com/homepage/$fileName.png",
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: buildSpinKitThreeBounce(50, screenWidth),
          );
        },
        fit: BoxFit.fill,
      );
    }

    var homeimage = [
      "./assets/homePage/restaurant.png",
      "./assets/homePage/hospital.png",
      "./assets/homePage/careCenter.png",
      "./assets/homePage/kindergarten.png",
      "./assets/homePage/kidsCafe.png",
      "./assets/homePage/experiencecenter.png",
      "./assets/homePage/amusementpark.png",
      "./assets/homePage/toylibrary.png",
      "./assets/homePage/childcareCenter.png"
    ];
    return isIOS
        ? Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                "우아하게",
                style: TextStyle(
                  fontSize: 73 / screenWidth,
                  fontFamily: 'NotoSansCJKkr_Bold',
                  letterSpacing: 0,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Color(0xffff7292),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //image
                    Container(
                      width: ScreenWidth,
                      height: 900 / screenHeight,
                      child: Stack(
                        children: [
                          PageView(
                            controller: PageController(
                              initialPage: 0,
                            ),
                            scrollDirection: Axis.horizontal,
                            children: [
                              imageView("image1"),
                              imageView("image2"),
                              imageView("image3"),
                              imageView("image4"),
                              imageView("image5")
                            ],
                            onPageChanged: (int page) {
                              setState(() {
                                print(page);
                                index = page + 1;
                              });
                            },
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              decoration: new BoxDecoration(
                                  color: Colors.pink[200],
                                  //   image: DecorationImage(
                                  //     image: AssetImage('./assets/path.png'),
                                  //   ),
                                  borderRadius: BorderRadius.circular(20.0)),
                              margin: EdgeInsets.only(
                                  top: 40 / screenHeight,
                                  right: 40 / screenWidth),
                              padding: EdgeInsets.symmetric(
                                  vertical: 1, horizontal: 10),
                              child: Text(
                                '$index/5',
                                style: TextStyle(
                                  fontSize: 62 / screenWidth,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          // Align(
                          //   alignment: Alignment.topLeft,
                          //   child: Container(
                          //     margin: EdgeInsets.only(
                          //       top: 60 / screenHeight,
                          //       left: 70 / screenWidth,
                          //     ),
                          //     child: Text(
                          //       "영·유아 보호자와\n함께하는\n정보제공 서비스",
                          //       style: TextStyle(
                          //           fontSize: 80 / screenWidth,
                          //           color: Color(0xffff7292),
                          //           fontFamily: 'NotoSansCJKkr_Medium'),
                          //     ),
                          //   ),
                          // )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(49 / screenWidth,
                          53 / screenHeight, 49 / screenWidth, 0),
                      height: 182 / screenHeight,
                      child: Theme(
                        data: new ThemeData(
                            primaryColor: Color.fromRGBO(255, 114, 148, 1.0),
                            fontFamily: 'NotoSansCJKkr_Medium'
                            // primaryColorDark: Colors.red,
                            ),
                        child: TextField(
                          onChanged: (txt) {
                            setState(() {
                              searchkey = txt;
                            });
                          },
                          // autofocus: false,
                          // showCursor: false,
                          style: TextStyle(
                              color: Color(0xffcccccc),
                              fontSize: 55 / screenWidth,
                              letterSpacing: -1.0),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(width: 0)),
                            contentPadding:
                                EdgeInsets.fromLTRB(76 / screenWidth, 0, 0, 0),
                            hintText: "장소, 주소, 상호명을 검색해주세요",
                            hintStyle: TextStyle(
                                color: Color(0xffcccccc),
                                fontSize: 55 / screenWidth,
                                fontFamily: 'NotoSansCJKkr_Medium',
                                letterSpacing: -1.0),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  currentFocus.unfocus();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Keyword(
                                              latitude: latitude,
                                              longitude: longitude,
                                              searchkey: searchkey)));
                                },
                                icon: Image.asset(
                                  "./assets/homePage/search.png",
                                  width: 88 / screenWidth,
                                  height: 87 / screenHeight,
                                )),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                      top: 50 / screenHeight,
                    )),
                    Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(
                              left: 78 / screenWidth,
                            )),
                            InkWell(
                              child: Image.asset(
                                homeimage[0],
                                width: 219 / screenWidth,
                                height: 211 / screenHeight,
                              ),
                              onTap: () {
                                currentFocus.unfocus();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => restaurant(
                                              userId: userId,
                                              loginOption: loginOption,
                                              latitude: latitude,
                                              longitude: longitude,
                                            )));
                              },
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                              left: 180 / screenWidth,
                            )),
                            InkWell(
                              child: Image.asset(
                                homeimage[1],
                                width: 169 / screenWidth,
                                height: 255 / screenHeight,
                              ),
                              onTap: () {
                                currentFocus.unfocus();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            examination_institution(
                                              userId: userId,
                                              loginOption: loginOption,
                                              latitude: latitude,
                                              longitude: longitude,
                                            )));
                              },
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                              left: 196 / screenWidth,
                            )),
                            InkWell(
                              child: Image.asset(
                                homeimage[2],
                                width: 190 / screenWidth,
                                height: 264 / screenHeight,
                              ),
                              onTap: () {
                                currentFocus.unfocus();
                                Fluttertoast.showToast(
                                  msg: "  서비스 준비 중이에요!  ",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black45,
                                  textColor: Colors.white,
                                  fontSize: 48 / screenWidth,
                                );
                              },
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                              left: 211 / screenWidth,
                            )),
                            InkWell(
                              child: Image.asset(
                                homeimage[3],
                                width: 163 / screenWidth,
                                height: 248 / screenHeight,
                              ),
                              onTap: () {
                                currentFocus.unfocus();
                                Fluttertoast.showToast(
                                  msg: "  서비스 준비 중이에요!  ",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black45,
                                  textColor: Colors.white,
                                  fontSize: 48 / screenWidth,
                                );
                              },
                            ),
                          ],
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                          top: 100 / screenHeight,
                        )),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(
                              left: 92 / screenWidth,
                            )),
                            InkWell(
                              child: Image.asset(
                                homeimage[4],
                                width: 192 / screenWidth,
                                height: 251 / screenHeight,
                              ),
                              onTap: () {
                                currentFocus.unfocus();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => kids_cafe(
                                              userId: userId,
                                              loginOption: loginOption,
                                              latitude: latitude,
                                              longitude: longitude,
                                            )));
                              },
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                              left: 206 / screenWidth,
                            )),
                            InkWell(
                              child: Image.asset(
                                homeimage[5],
                                width: 151 / screenWidth,
                                height: 230 / screenHeight,
                              ),
                              onTap: () {
                                currentFocus.unfocus();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => experience_center(
                                              userId: userId,
                                              loginOption: loginOption,
                                              latitude: latitude,
                                              longitude: longitude,
                                            )));
                              },
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                              left: 224 / screenWidth,
                            )),
                            InkWell(
                              child: Image.asset(
                                homeimage[6],
                                width: 142 / screenWidth,
                                height: 239 / screenHeight,
                              ),
                              onTap: () {
                                currentFocus.unfocus();
                                Fluttertoast.showToast(
                                  msg: "  서비스 준비 중이에요!  ",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black45,
                                  textColor: Colors.white,
                                  fontSize: 48 / screenWidth,
                                );
                              },
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                              left: 159 / screenWidth,
                            )),
                            InkWell(
                              child: Image.asset(
                                homeimage[7],
                                width: 294 / screenWidth,
                                height: 202 / screenHeight,
                              ),
                              onTap: () {
                                currentFocus.unfocus();
                                Fluttertoast.showToast(
                                  msg: "  서비스 준비 중이에요!  ",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black45,
                                  textColor: Colors.white,
                                  fontSize: 48 / screenWidth,
                                );
                              },
                            ),
                          ],
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                          top: 100 / screenHeight,
                        )),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(
                              left: 91 / screenWidth,
                            )),
                            InkWell(
                              child: Image.asset(
                                homeimage[8],
                                width: 189 / screenWidth,
                                height: 221 / screenHeight,
                              ),
                              onTap: () {
                                Fluttertoast.showToast(
                                  msg: "  서비스 준비 중이에요!  ",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black45,
                                  textColor: Colors.white,
                                  fontSize: 48 / screenWidth,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                      top: 104 / screenHeight,
                    )),
                    Container(
                      padding: EdgeInsets.only(
                        left: 100 / screenWidth,
                        top: 82 / screenHeight,
                        bottom: 20 / screenHeight,
                      ),
                      color: Color.fromRGBO(247, 248, 250, 1.0),
                      // height: 650 / screenHeight,
                      width: ScreenWidth,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              "./assets/homePage/logo_grey.png",
                              width: 256 / screenWidth,
                              height: 63 / screenHeight,
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                              top: 57 / screenHeight,
                            )),
                            Text(
                              "상호명 : (주)호호컴퍼니\n대표이사 : 김화영     사업자등록번호 : 322-86-01766\n유선번호 : 061-331-3116  팩스 : 061-331-3117\nemail : hohoco0701@gmail.com \n주소 : 전남 나주시 빛가람로 740 한빛타워 6층 601호\ncopyrightⓒ 호호컴퍼니 Inc. All Rights Reserved.            \n사업자 정보 확인   |   이용약관   |   개인정보처리방침",
                              style: TextStyle(
                                  fontFamily: "NotoSansCJKkr_Medium",
                                  //  height: 1.0,
                                  //   letterSpacing: -1.0,
                                  fontSize: 40 / screenWidth,
                                  color: Color.fromRGBO(151, 151, 151, 1.0)),
                            ),
                          ]),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //appbar
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 180 / screenHeight,
                        width: double.infinity,
                        color: Color.fromRGBO(255, 114, 148, 1.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "우아하게",
                            style: TextStyle(
                              fontSize: 73 / screenWidth,
                              fontFamily: 'NotoSansCJKkr_Bold',
                              letterSpacing: 0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    //image
                    Container(
                      width: ScreenWidth,
                      height: 900 / screenHeight,
                      child: Stack(
                        children: [
                          PageView(
                            controller: PageController(
                              initialPage: 0,
                            ),
                            scrollDirection: Axis.horizontal,
                            children: [
                              imageView("image1"),
                              imageView("image2"),
                              imageView("image3"),
                              imageView("image4"),
                              imageView("image5")
                            ],
                            onPageChanged: (int page) {
                              setState(() {
                                print(page);
                                index = page + 1;
                              });
                            },
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              decoration: new BoxDecoration(
                                  color: Colors.pink[200],
                                  //   image: DecorationImage(
                                  //     image: AssetImage('./assets/path.png'),
                                  //   ),
                                  borderRadius: BorderRadius.circular(20.0)),
                              margin: EdgeInsets.only(
                                  top: 40 / screenHeight,
                                  right: 40 / screenWidth),
                              padding: EdgeInsets.symmetric(
                                  vertical: 1, horizontal: 10),
                              child: Text(
                                '$index/5',
                                style: TextStyle(
                                  fontSize: 62 / screenWidth,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          // Align(
                          //   alignment: Alignment.topLeft,
                          //   child: Container(
                          //     margin: EdgeInsets.only(
                          //       top: 60 / screenHeight,
                          //       left: 70 / screenWidth,
                          //     ),
                          //     child: Text(
                          //       "영·유아 보호자와\n함께하는\n정보제공 서비스",
                          //       style: TextStyle(
                          //           fontSize: 80 / screenWidth,
                          //           color: Color(0xffff7292),
                          //           fontFamily: 'NotoSansCJKkr_Medium'),
                          //     ),
                          //   ),
                          // )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(49 / screenWidth,
                          53 / screenHeight, 49 / screenWidth, 0),
                      height: 182 / screenHeight,
                      child: Theme(
                        data: new ThemeData(
                            primaryColor: Color.fromRGBO(255, 114, 148, 1.0),
                            fontFamily: 'NotoSansCJKkr_Medium'
                            // primaryColorDark: Colors.red,
                            ),
                        child: TextField(
                          onChanged: (txt) {
                            setState(() {
                              searchkey = txt;
                            });
                          },
                          // autofocus: false,
                          // showCursor: false,
                          style: TextStyle(
                              color: Color(0xffcccccc),
                              fontSize: 55 / screenWidth,
                              letterSpacing: -1.0),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(width: 0)),
                            contentPadding:
                                EdgeInsets.fromLTRB(76 / screenWidth, 0, 0, 0),
                            hintText: "장소, 주소, 상호명을 검색해주세요",
                            hintStyle: TextStyle(
                                color: Color(0xffcccccc),
                                fontSize: 55 / screenWidth,
                                fontFamily: 'NotoSansCJKkr_Medium',
                                letterSpacing: -1.0),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  currentFocus.unfocus();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Keyword(
                                              userId: userId,
                                              loginOption: loginOption,
                                              latitude: latitude,
                                              longitude: longitude,
                                              searchkey: searchkey)));
                                },
                                icon: Image.asset(
                                  "./assets/homePage/search.png",
                                  width: 88 / screenWidth,
                                  height: 87 / screenHeight,
                                )),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                      top: 50 / screenHeight,
                    )),
                    Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(
                              left: 78 / screenWidth,
                            )),
                            InkWell(
                              child: Image.asset(
                                homeimage[0],
                                width: 219 / screenWidth,
                                height: 211 / screenHeight,
                              ),
                              onTap: () {
                                currentFocus.unfocus();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => restaurant(
                                              userId: userId,
                                              loginOption: loginOption,
                                              latitude: latitude,
                                              longitude: longitude,
                                            )));
                              },
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                              left: 180 / screenWidth,
                            )),
                            InkWell(
                              child: Image.asset(
                                homeimage[1],
                                width: 169 / screenWidth,
                                height: 255 / screenHeight,
                              ),
                              onTap: () {
                                currentFocus.unfocus();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            examination_institution(
                                              userId: userId,
                                              loginOption: loginOption,
                                              latitude: latitude,
                                              longitude: longitude,
                                            )));
                              },
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                              left: 196 / screenWidth,
                            )),
                            InkWell(
                              child: Image.asset(
                                homeimage[2],
                                width: 190 / screenWidth,
                                height: 264 / screenHeight,
                              ),
                              onTap: () {
                                currentFocus.unfocus();
                                Fluttertoast.showToast(
                                  msg: "  서비스 준비 중이에요!  ",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black45,
                                  textColor: Colors.white,
                                  fontSize: 48 / screenWidth,
                                );
                              },
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                              left: 211 / screenWidth,
                            )),
                            InkWell(
                              child: Image.asset(
                                homeimage[3],
                                width: 163 / screenWidth,
                                height: 248 / screenHeight,
                              ),
                              onTap: () {
                                currentFocus.unfocus();
                                Fluttertoast.showToast(
                                  msg: "  서비스 준비 중이에요!  ",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black45,
                                  textColor: Colors.white,
                                  fontSize: 48 / screenWidth,
                                );
                              },
                            ),
                          ],
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                          top: 100 / screenHeight,
                        )),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(
                              left: 92 / screenWidth,
                            )),
                            InkWell(
                              child: Image.asset(
                                homeimage[4],
                                width: 192 / screenWidth,
                                height: 251 / screenHeight,
                              ),
                              onTap: () {
                                currentFocus.unfocus();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => kids_cafe(
                                              userId: userId,
                                              loginOption: loginOption,
                                              latitude: latitude,
                                              longitude: longitude,
                                            )));
                              },
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                              left: 206 / screenWidth,
                            )),
                            InkWell(
                              child: Image.asset(
                                homeimage[5],
                                width: 151 / screenWidth,
                                height: 230 / screenHeight,
                              ),
                              onTap: () {
                                currentFocus.unfocus();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => experience_center(
                                              userId: userId,
                                              loginOption: loginOption,
                                              latitude: latitude,
                                              longitude: longitude,
                                            )));
                              },
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                              left: 224 / screenWidth,
                            )),
                            InkWell(
                              child: Image.asset(
                                homeimage[6],
                                width: 142 / screenWidth,
                                height: 239 / screenHeight,
                              ),
                              onTap: () {
                                currentFocus.unfocus();
                                Fluttertoast.showToast(
                                  msg: "  서비스 준비 중이에요!  ",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black45,
                                  textColor: Colors.white,
                                  fontSize: 48 / screenWidth,
                                );
                              },
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                              left: 159 / screenWidth,
                            )),
                            InkWell(
                              child: Image.asset(
                                homeimage[7],
                                width: 294 / screenWidth,
                                height: 202 / screenHeight,
                              ),
                              onTap: () {
                                currentFocus.unfocus();
                                Fluttertoast.showToast(
                                  msg: "  서비스 준비 중이에요!  ",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black45,
                                  textColor: Colors.white,
                                  fontSize: 48 / screenWidth,
                                );
                              },
                            ),
                          ],
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                          top: 100 / screenHeight,
                        )),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(
                              left: 91 / screenWidth,
                            )),
                            InkWell(
                              child: Image.asset(
                                homeimage[8],
                                width: 189 / screenWidth,
                                height: 221 / screenHeight,
                              ),
                              onTap: () {
                                Fluttertoast.showToast(
                                  msg: "  서비스 준비 중이에요!  ",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black45,
                                  textColor: Colors.white,
                                  fontSize: 48 / screenWidth,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                      top: 104 / screenHeight,
                    )),
                    Container(
                      padding: EdgeInsets.only(
                        left: 100 / screenWidth,
                        top: 82 / screenHeight,
                        bottom: 20 / screenHeight,
                      ),
                      color: Color.fromRGBO(247, 248, 250, 1.0),
                      // height: 650 / screenHeight,
                      width: ScreenWidth,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              "./assets/homePage/logo_grey.png",
                              width: 256 / screenWidth,
                              height: 63 / screenHeight,
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                              top: 57 / screenHeight,
                            )),
                            Text(
                              "상호명 : (주)호호컴퍼니\n대표이사 : 김화영     사업자등록번호 : 322-86-01766\n유선번호 : 061-331-3116  팩스 : 061-331-3117\nemail : hohoco0701@gmail.com \n주소 : 전남 나주시 빛가람로 740 한빛타워 6층 601호\ncopyrightⓒ 호호컴퍼니 Inc. All Rights Reserved.            \n사업자 정보 확인   |   이용약관   |   개인정보처리방침",
                              style: TextStyle(
                                  fontFamily: "NotoSansCJKkr_Medium",
                                  //  height: 1.0,
                                  //   letterSpacing: -1.0,
                                  fontSize: 40 / screenWidth,
                                  color: Color.fromRGBO(151, 151, 151, 1.0)),
                            ),
                          ]),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
