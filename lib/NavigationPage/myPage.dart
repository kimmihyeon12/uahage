import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uahage/screens/withdrawal.dart';
import './../screens/loginPage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';

class myPage extends StatefulWidget {
  String loginOption;
  String userId;
  // String oldNickname;
  myPage({Key key, this.userId, this.loginOption}) : super(key: key);
  @override
  _myPageState createState() => _myPageState();
}

// class Message {
//   final String message;

//   Message({this.message});

//   factory Message.fromJson(Map<String, dynamic> json) {
//     return Message(
//       message: json['message'],
//     );
//   }
// }

class _myPageState extends State<myPage> {
  TextEditingController yController = TextEditingController();
  String birthday = "";
  String nickName = "";
  String oldNickname = "";
  String userId = "";
  String year, month, yearMonthDay, yearMonthDayTime;
  var changeimage = [false, false, false, false, false, false];
  var genderImage = [false, false];
  bool onEdit = false;
  bool isIdValid = false;
  String loginOption = "";
  String gender = "";
  String userAge = "";
  String _uploadedFileURL = "";
  File _image;
  String imageLink = "";
  @override
  void initState() {
    super.initState();
    setState(() {
      loginOption = widget.loginOption;
      userId = widget.userId ?? "";
      // oldNickname = userId != "" ? getMyNickname().toString() : "";
    });
    // print("loginOption" + loginOption);
    // print("widgetID" + widget.userId);
    if (loginOption != "login") {
      getMyAvatar();
      getMyInfo();
    }
  }

  getMyInfo() async {
    try {
      var response = await http
          .get("http://13.209.41.43/getMyInfo?userId=$userId$loginOption");
      var data = jsonDecode(response.body);
      print("printing info " + data.toString());
      if (data["gender"].toString() != "") {
        setState(() {
          data["gender"].toString() == "boy"
              ? genderImage[0] = true
              : genderImage[1] = true;
          birthday = data["birthday"].toString();
        });
        _change(data["age"].toString());
      }
    } catch (err) {
      print(err);
      // return err["message"];
    }
  }

  getMyAvatar() async {
    try {
      var response = await http
          .get("http://13.209.41.43/getAvatar/?email=$userId$loginOption");
      if (response.statusCode == 200) {
        String _imageLink = jsonDecode(response.body)["image"].toString();
        // print("response" + jsonDecode(response.body)["image"]);
        print("imgaLink " + _imageLink);
        if (_imageLink == null || _imageLink == "")
          setState(() {
            imageLink = "";
          });
        else
          setState(() {
            imageLink = _imageLink.toString();
          });
      } else {}
    } catch (err) {
      // print(err);
      return err["message"];
    }
  }

  Future deleteFile() async {
    try {
      await http
          .put(
        "http://13.209.41.43/updateImage/$userId$loginOption",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"URL": ""}),
      )
          .then((value) => print(value.body))
          .catchError((err) => print(err));
    } catch (error) {}
  }

  Future checkNickname() async {
    var data;
    try {
      var response =
      await http.get("http://13.209.41.43/getNicknames/$nickName");
      if (response.statusCode == 200) {
        data = jsonDecode(response.body)["message"];
        setState(() {
          isIdValid = true;
        });
        return data;
      } else {
        data = jsonDecode(response.body)["message"];
        setState(() {
          isIdValid = false;
        });
        return data;
      }
    } catch (err) {
      // print(err);
      return err["message"];
    }
  }

  Future updateNickname() async {
    Map<String, dynamic> ss = {
      "userId": userId + loginOption,
      // "oldNickname": oldNickname,
      "gender": gender,
      "birthday": birthday,
      "age": userAge,
    };
    // print(ss);
    var response = await http.post(
      "http://13.209.41.43/updateNickname/$nickName",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(ss),
    );
    return jsonDecode(response.body)["message"];
  }

  Future getMyNickname() async {
    var data;
    try {
      var response = await http
          .get("http://13.209.41.43/getMyNickname?userId=$userId$loginOption");
      // print("widgetID" + userId);
      if (response.statusCode == 200) {
        data = json.decode(response.body)["nickname"];

        // setState(() {
        //   userId = data.toString();
        // });
        // print("userID setst " + userId);
        return data.toString();
      }
    } catch (err) {
      print(err);
      //return data["nickname"];
    }
  }

  Future _imgFromCamera() async {
    var image = await ImagePicker()
        .getImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = File(image.path);
    });
    await uploadFile(_image);
  }

  Future _imgFromGallery() async {
    var image = await ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = File(image.path);
    });
    await uploadFile(_image);
  }

  uploadFile(File file) async {
    if (imageLink != "") {
      try {
        // print(ss);
        await http.post(
          "http://13.209.41.43/api/profile/deleteImage",
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({"fileName": imageLink}),
        );
      } catch (err) {
        print(err);
      }
    }

    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "profileImage":
        await MultipartFile.fromFile(file.path, filename: fileName),
      });
      Dio dio = new Dio();
      var response;
      try {
        response = await dio.post(
            'http://13.209.41.43/api/profile/imgUpload/$userId$loginOption',
            data: formData);
        setState(() {
          _uploadedFileURL = response.data["location"];
          imageLink = _uploadedFileURL;
        });
        print("Printing after upload imagelink " + _uploadedFileURL);
        await _saveURL(_uploadedFileURL);
      } catch (err) {
        print(err);
      }
    } catch (err) {
      print(err);
    }
  }

  _saveURL(_uploadedFileURL) async {
    try {
      await http
          .put(
        "http://13.209.41.43/updateImage/$userId$loginOption",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"URL": _uploadedFileURL}),
      )
          .then((value) => print(value.body))
          .catchError((err) => print(err));
    } catch (error) {}
  }

  Future _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(
                        Icons.photo_library,
                        color: Color.fromRGBO(255, 114, 148, 1.0),
                      ),
                      title: new Text('Photo Gallery'),
                      onTap: () async {
                        await _imgFromGallery();
                        // print("Calling upload func");

                        // print(_uploadedFileURL);
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(
                      Icons.photo_camera,
                      color: Color.fromRGBO(255, 114, 148, 1.0),
                    ),
                    title: new Text('Camera'),
                    onTap: () async {
                      await _imgFromCamera();
                      // print("Calling upload func");

                      Navigator.of(context).pop();
                    },
                  ),
                  new ListTile(
                    leading: new Icon(
                      Icons.delete_rounded,
                      color: Color.fromRGBO(255, 114, 148, 1.0),
                    ),
                    title: new Text('Delete Image'),
                    onTap: () async {
                      await deleteFile();
                      setState(() {
                        _image = null;
                        imageLink = "";
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future withdrawalUser() async {
    if (imageLink != "") {
      try {
        // print(ss);
        await http.post(
          "http://13.209.41.43/api/profile/deleteImage",
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({"fileName": imageLink}),
        );
      } catch (err) {
        print(err);
      }
    }
    try {
      var res = await http
          .delete("http://13.209.41.43/deleteStar/$userId$loginOption");
      print(jsonDecode(res.body));
    } catch (e) {}
    try {
      var res = await http
          .delete("http://13.209.41.43/deleteProfile/$userId$loginOption");
      print(jsonDecode(res.body));
      return jsonDecode(res.body)["message"];
    } catch (e) {}
  }

  // SpinKitThreeBounce buildSpinKitThreeBounce(double size, double screenWidth) {
  //   return SpinKitThreeBounce(
  //     color: Color(0xffFF728E),
  //     size: size / screenWidth,
  //   );
  // }

  bool isIOS = Platform.isIOS;
  @override
  Widget build(BuildContext context) {
    double screenHeight = 2667 / MediaQuery.of(context).size.height;
    double screenWidth = 1501 / MediaQuery.of(context).size.width;
    var _fontsize = 52.5 / screenWidth;
    var textStyle52 = TextStyle(
      color: const Color(0xffb1b1b1),
      fontWeight: FontWeight.w500,
      fontFamily: "NotoSansCJKkr_Medium",
      fontStyle: FontStyle.normal,
      fontSize: 52 / screenWidth,
    );

    // print("widgetbuuild imageLink " + imageLink);

    // isIOS
    //     ? SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark
    //         .copyWith(
    //             statusBarBrightness:
    //                 Brightness.dark // Dark == white status bar -- for IOS.
    //             ))
    //     : null;

    return WillPopScope(
      onWillPop: () async {
        // exit(0);
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: isIOS
              ? SingleChildScrollView(
            child: Column(
              children: [
                //back button
                Container(
                  margin: EdgeInsets.fromLTRB(81 / screenWidth,
                      110 / screenHeight, 1100 / screenWidth, 0),
                  child: onEdit
                      ? InkWell(
                    onTap: () {
                      setState(() {
                        onEdit = false;
                      });
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          "./assets/myPage/back.png",
                          width: 43 / screenWidth,
                          height: 76 / screenHeight,
                        ),
                        // 내 정보
                        Container(
                          margin: EdgeInsets.only(
                              left: 33 / screenWidth),
                          child: Text("내 정보",
                              style: TextStyle(
                                color: Color.fromRGBO(
                                    255, 114, 148, 1.0),
                                fontFamily: 'NotoSansCJKkr_Medium',
                                fontSize: 57 / screenWidth,
                              ),
                              textAlign: TextAlign.left),
                        )
                      ],
                    ),
                  )
                      : Container(),
                ),

                //Center avatar
                Center(
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 439 / screenHeight,
                        width: 439 / screenWidth,
                        child: CircleAvatar(
                          backgroundImage:
                          AssetImage("./assets/myPage/avatar.png"),
                          // backgroundImage: (() {
                          //   if (_image != null) {
                          //     print("1");
                          //     return FileImage(_image);
                          //   } else if (imageLink != "" && imageLink != null) {
                          //     print("2");
                          //     // print("here " + imageLink);
                          //     return NetworkImage(imageLink); //imageURL

                          //   } else {
                          //     print("3");
                          //     return AssetImage("./assets/myPage/avatar.png");
                          //   }
                          // }()),
                          // child: Image.network(imageLink),
                          child: (() {
                            // your code here

                            if (_image != null) {
                              print("1");
                              print("here " + imageLink);
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: FileImage(_image), //imageURL
                                      fit: BoxFit.fill),
                                ),
                              );
                            } else if (imageLink != "" &&
                                imageLink != null) {
                              print("2");
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: NetworkImage(imageLink),
                                      fit: BoxFit.fill),
                                ),
                              );
                            } else {
                              print("3");
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: AssetImage(
                                          "./assets/myPage/avatar.png"),
                                      fit: BoxFit.fill),
                                ),
                              );
                            }
                          }()),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            330 / screenWidth, 341 / screenHeight, 0, 0),
                        child: InkWell(
                          onTap: loginOption != "login"
                              ? () {
                            _showPicker(context);
                          }
                              : () {
                            Fluttertoast.showToast(
                              msg: "로그인 해주세요!",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black45,
                              textColor: Colors.white,
                              fontSize: 48 / screenWidth,
                            );
                          },
                          child: Image.asset(
                            "./assets/myPage/camera.png",
                            height: 109 / screenHeight,
                            width: 110 / screenWidth,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Nickname
                onEdit
                    ? Container(
                  margin: EdgeInsets.only(
                    top: 85 / screenHeight,
                  ),
                  child: Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 닉네임
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              157 / screenWidth,
                              45 / screenHeight,
                              88 / screenWidth,
                              0),
                          child: Text("닉네임",
                              style: TextStyle(
                                  color: const Color(0xffff7292),
                                  fontFamily:
                                  "NotoSansCJKkr_Medium",
                                  fontSize: 58 / screenWidth),
                              textAlign: TextAlign.left),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.only(
                              right: 121 / screenWidth,
                            ),
                            child: Stack(
                              children: [
                                TextFormField(
                                  // controller: yController,

                                  onChanged: (txt) {
                                    setState(() {
                                      nickName = txt;
                                    });
                                  },

                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Color(0xff3a3939),
                                      fontFamily:
                                      "NotoSansCJKkr_Bold",
                                      fontSize: 58 / screenWidth),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(
                                        right: 410 / screenWidth),
                                    enabledBorder:
                                    UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                        const Color(0xffff7292),
                                      ),

                                      //Color.fromRGBO(255, 114, 148, 1.0)
                                    ),
                                    focusedBorder:
                                    UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(0xffff7292)),
                                    ),
                                    hintText: '닉네임 수정 칼라',
                                    hintStyle: TextStyle(
                                        color:
                                        const Color(0xffcacaca),
                                        fontFamily:
                                        "NotoSansCJKkr_Medium",
                                        fontSize: 58 / screenWidth),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(
                                            8.0)),
                                    color: nickName == ""
                                        ? Color(0xffcacaca)
                                        : Color(0xffff7292),
                                    onPressed:
                                    loginOption != "login" &&
                                        nickName != ""
                                        ? () {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            FutureBuilder(
                                                future:
                                                checkNickname(),
                                                builder:
                                                    (context,
                                                    snapshot) {
                                                  if (snapshot
                                                      .hasData) {
                                                    // print(snapshot.data);
                                                    return AlertDialog(
                                                      shape:
                                                      RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                                                      title: // 사용 가능한 닉네임입니다.
                                                      Text(snapshot.data, style: TextStyle(color: const Color(0xff4d4d4d), fontWeight: FontWeight.w500, fontFamily: "NotoSansCJKkr_Medium", fontStyle: FontStyle.normal, fontSize: 62.5 / screenWidth), textAlign: TextAlign.left),
                                                      actions: [
                                                        FlatButton(
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                            },
                                                            child: // 확인
                                                            Text("확인", style: TextStyle(color: const Color(0xffff7292), fontWeight: FontWeight.w500, fontFamily: "NotoSansCJKkr_Medium", fontStyle: FontStyle.normal, fontSize: _fontsize), textAlign: TextAlign.center))
                                                      ],
                                                    );
                                                  } else if (snapshot
                                                      .hasError)
                                                    return AlertDialog(
                                                      shape:
                                                      RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                                                      title:
                                                      // id already exists.
                                                      Text(snapshot.error, style: TextStyle(color: Color(0xff4d4d4d), fontWeight: FontWeight.w500, fontFamily: "NotoSansCJKkr_Medium", fontStyle: FontStyle.normal, fontSize: 62.5 / screenWidth), textAlign: TextAlign.left),
                                                      actions: [
                                                        FlatButton(
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                            },
                                                            child: // 확인
                                                            Text("확인", style: TextStyle(color: const Color(0xffff7292), fontWeight: FontWeight.w500, fontFamily: "NotoSansCJKkr_Medium", fontStyle: FontStyle.normal, fontSize: _fontsize), textAlign: TextAlign.center))
                                                      ],
                                                    );

                                                  return Center(
                                                    child: SizedBox(
                                                        height: 200 / screenHeight,
                                                        width: 200 / screenWidth,
                                                        child: buildSpinKitThreeBounce(80, screenWidth)
                                                      // CircularProgressIndicator(
                                                      //   strokeWidth:
                                                      //       5.0,
                                                      //   valueColor:
                                                      //       new AlwaysStoppedAnimation<Color>(
                                                      //     Colors.pinkAccent,
                                                      //   ),
                                                      // )
                                                    ),
                                                  );
                                                }),
                                      );
                                    }
                                        : () {},
                                    child: // 중복확인
                                    Text("중복확인",
                                        style: TextStyle(
                                            color: const Color(
                                                0xffffffff),
                                            fontFamily:
                                            "NotoSansCJKkr_Medium",
                                            fontSize: 50 /
                                                screenWidth),
                                        textAlign:
                                        TextAlign.left),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : Container(
                  margin: EdgeInsets.only(top: 31 / screenHeight),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 320 / screenWidth,
                        child: userId == ""
                            ? nickNameShow("우아하게", screenWidth)
                            : FutureBuilder(
                          future: getMyNickname(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              // print("hasdata " + snapshot.data);
                              return snapshot.data != ""
                                  ? nickNameShow(
                                  snapshot.data,
                                  screenWidth)
                                  : nickNameShow(
                                  "우아하게", screenWidth);
                            } else if (snapshot.hasError) {
                              // print("haserror " + snapshot.error);
                              return nickNameShow(
                                  snapshot.error,
                                  screenWidth);
                            }
                            return Center(
                              child: SizedBox(
                                height: 50 / screenHeight,
                                width: 50 / screenWidth,
                                child:
                                buildSpinKitThreeBounce(
                                    30, screenWidth),
                                // CircularProgressIndicator(
                                //   strokeWidth: 5.0,
                                //   valueColor:
                                //       new AlwaysStoppedAnimation<
                                //           Color>(
                                //     Colors.pinkAccent,
                                //   ),
                                // ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            992 / screenWidth,
                            0,
                            148 / screenWidth,
                            0),
                        child: loginOption ==
                            "login" // Change this on release to ==
                            ? Image.asset(
                          "./assets/myPage/button1_grey.png",
                          width: 361 / screenWidth,
                          height: 147 / screenHeight,
                        )
                            : InkWell(
                          onTap: () {
                            setState(() {
                              onEdit = true;
                            });
                          },
                          child: Image.asset(
                            "./assets/myPage/button1.png",
                            width: 361 / screenWidth,
                            height: 147 / screenHeight,
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                //Gender
                Container(
                  margin: EdgeInsets.fromLTRB(
                      99 / screenWidth, 100 / screenHeight, 0, 0),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 아이성별
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            0, 24 / screenHeight, 56 / screenWidth, 0),
                        child: Text("아이성별",
                            style: TextStyle(
                                color: const Color(0xffff7292),
                                fontFamily: "NotoSansCJKkr_Medium",
                                fontSize: 57 / screenWidth),
                            textAlign: TextAlign.left),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            gender = "boy";
                            genderImage[0] = !genderImage[0];
                            genderImage[1] = false;
                          });
                        },
                        child: Image.asset(
                          genderImage[0]
                              ? "./assets/myPage/boy_pink.png"
                              : "./assets/myPage/boy_grey.png",
                          height: 363 / screenHeight,
                          width: 262 / screenWidth,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 98 / screenWidth),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              gender = "girl";
                              genderImage[1] = !genderImage[1];
                              genderImage[0] = false;
                            });
                          },
                          child: Image.asset(
                            genderImage[1]
                                ? "./assets/myPage/girl_pink.png"
                                : "./assets/myPage/girl_grey.png",
                            height: 363 / screenHeight,
                            width: 262 / screenWidth,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Birthday

                Container(
                  margin: EdgeInsets.fromLTRB(
                      99 / screenWidth, 40 / screenHeight, 0, 0),
                  child: Row(
                    children: [
                      // 아이생일
                      Text("아이생일",
                          style: TextStyle(
                            fontSize: 56 / screenWidth,
                            color: const Color(0xffff7292),
                            fontFamily: "NotoSansCJKkr_Medium",
                          ),
                          textAlign: TextAlign.left),
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.fromLTRB(
                              82 / screenWidth, 0, 121 / screenWidth, 0),
                          child: Stack(
                            children: [
                              TextFormField(
                                readOnly: true,
                                controller: yController,
                                onChanged: (txt) {
                                  setState(() {
                                    birthday = txt;
                                  });
                                },
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Color(0xffff7292),
                                    fontSize: 73 / screenWidth,
                                    fontFamily: 'NotoSansCJKkr_Medium',
                                    fontStyle: FontStyle.normal,
                                    letterSpacing: -1.0),
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: const Color(0xffff7292),
                                    ),
                                    //Color.fromRGBO(255, 114, 148, 1.0)
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(0xffff7292)),
                                  ),
                                  hintText: birthday == ""
                                      ? '생년월일을 선택해주세요'
                                      : birthday,
                                  hintStyle: TextStyle(
                                      color: const Color(0xffff7292),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "NotoSansCJKkr",
                                      fontStyle: FontStyle.normal,
                                      fontSize: 66.0 / screenWidth),
                                ),
                              ),
                              onEdit
                                  ? Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  onPressed: () {
                                    yearPicker();
                                  },
                                  icon: Image.asset(
                                      "./assets/myPage/calendar.png"),
                                ),
                              )
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Ages
                Container(
                  margin: EdgeInsets.fromLTRB(
                      155 / screenWidth, 98 / screenHeight, 0, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 보호자 연령대
                      Text("보호자\n연령대",
                          style: TextStyle(
                            color: const Color(0xffff7292),
                            fontWeight: FontWeight.w500,
                            fontFamily: "NotoSansCJKkr_Medium",
                            fontStyle: FontStyle.normal,
                            fontSize: _fontsize,
                          ),
                          textAlign: TextAlign.right),
                      Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 59 / screenWidth),
                                  child: InkWell(
                                    child: Image.asset(
                                      changeimage[0]
                                          ? './assets/registrationPage/10_pink.png'
                                          : './assets/registrationPage/10_grey.png',
                                      height: 196 / screenHeight,
                                      width: 251 / screenWidth,
                                    ),
                                    onTap: () {
                                      _change('10');
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 55 / screenWidth),
                                  child: InkWell(
                                    child: Image.asset(
                                      changeimage[1]
                                          ? './assets/registrationPage/20_pink.png'
                                          : './assets/registrationPage/20_grey.png',
                                      height: 196 / screenHeight,
                                      width: 251 / screenWidth,
                                    ),
                                    onTap: () {
                                      _change('20');
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 55 / screenWidth),
                                  child: InkWell(
                                    child: Image.asset(
                                      changeimage[2]
                                          ? './assets/registrationPage/30_pink.png'
                                          : './assets/registrationPage/30_grey.png',
                                      height: 196 / screenHeight,
                                      width: 251 / screenWidth,
                                    ),
                                    onTap: () {
                                      _change('30');
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 59 / screenWidth,
                                      top: 45 / screenHeight),
                                  child: InkWell(
                                    child: Image.asset(
                                      changeimage[3]
                                          ? './assets/registrationPage/40_pink.png'
                                          : './assets/registrationPage/40_grey.png',
                                      height: 196 / screenHeight,
                                      width: 251 / screenWidth,
                                    ),
                                    onTap: () {
                                      _change('40');
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 55 / screenWidth,
                                      top: 45 / screenHeight),
                                  child: InkWell(
                                    child: Image.asset(
                                      changeimage[4]
                                          ? './assets/registrationPage/50_pink.png'
                                          : './assets/registrationPage/50_grey.png',
                                      height: 196 / screenHeight,
                                      width: 251 / screenWidth,
                                    ),
                                    onTap: () {
                                      _change('50');
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 55 / screenWidth,
                                      top: 45 / screenHeight),
                                  child: InkWell(
                                    child: Image.asset(
                                      changeimage[5]
                                          ? './assets/registrationPage/others_pink.png'
                                          : './assets/registrationPage/others_grey.png',
                                      height: 196 / screenHeight,
                                      width: 251 / screenWidth,
                                    ),
                                    onTap: () {
                                      _change('60');
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Ok Button
                onEdit
                    ? Container(
                  margin: EdgeInsets.only(top: 87 / screenHeight),
                  child: SizedBox(
                    height: 194 / screenWidth,
                    width: 1193 / screenHeight,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      color: isIdValid
                          ? Color(0xffff7292)
                          : Color(0xffcacaca),
                      onPressed: isIdValid
                          ? () {
                        showDialog(
                          context: context,
                          builder: (context) => FutureBuilder(
                            future: updateNickname(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return AlertDialog(
                                  title: Text(snapshot.data),
                                  actions: [
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context);
                                        setState(() {
                                          onEdit = false;
                                        });
                                      },
                                      child: // 확인
                                      Text("확인",
                                          style: TextStyle(
                                              color: const Color(
                                                  0xffff7292),
                                              fontWeight:
                                              FontWeight
                                                  .w500,
                                              fontFamily:
                                              "NotoSansCJKkr_Medium",
                                              fontStyle:
                                              FontStyle
                                                  .normal,
                                              fontSize:
                                              _fontsize),
                                          textAlign:
                                          TextAlign
                                              .center),
                                    ),
                                  ],
                                );
                              } else if (snapshot.hasError) {
                                return AlertDialog(
                                  title: Text(snapshot.error),
                                  actions: [
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context);
                                      },
                                      child: // 확인
                                      Text("확인",
                                          style: TextStyle(
                                              color: const Color(
                                                  0xffff7292),
                                              fontWeight:
                                              FontWeight
                                                  .w500,
                                              fontFamily:
                                              "NotoSansCJKkr_Medium",
                                              fontStyle:
                                              FontStyle
                                                  .normal,
                                              fontSize:
                                              _fontsize),
                                          textAlign:
                                          TextAlign
                                              .center),
                                    ),
                                  ],
                                );
                              }
                              return Center(
                                child: SizedBox(
                                    height:
                                    200 / screenHeight,
                                    width: 200 / screenWidth,
                                    child:
                                    buildSpinKitThreeBounce(
                                        80, screenWidth)
                                  //     CircularProgressIndicator(
                                  //   strokeWidth: 5.0,
                                  //   valueColor:
                                  //       new AlwaysStoppedAnimation<
                                  //           Color>(
                                  //     Colors.pinkAccent,
                                  //   ),
                                  // ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                          : () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title:
                            Text("Check your ID first"),
                            actions: [
                              FlatButton(
                                child: Text("OK"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      child: // 중복확인
                      Text("OK",
                          style: TextStyle(
                              color: const Color(0xffffffff),
                              fontWeight: FontWeight.w500,
                              fontFamily:
                              "NotoSansCJKkr_Medium",
                              fontStyle: FontStyle.normal,
                              fontSize: 62 / screenWidth),
                          textAlign: TextAlign.left),
                    ),
                  ),
                )
                    : Container(),

                //logout

                Container(
                  margin: EdgeInsets.fromLTRB(
                      931 / screenWidth,
                      onEdit ? 88 / screenHeight : 370 / screenHeight,
                      0,
                      71 / screenHeight),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: // 로그아웃 하시겠습니까?
                              Text("로그아웃 하시겠습니까?",
                                  style: TextStyle(
                                      color: const Color(0xff4d4d4d),
                                      fontWeight: FontWeight.w500,
                                      fontFamily:
                                      "NotoSansCJKkr_Medium",
                                      fontStyle: FontStyle.normal,
                                      fontSize: 62.5 / screenWidth),
                                  textAlign: TextAlign.left),
                              actions: [
                                FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: // 아니요
                                  Text("아니요",
                                      style: TextStyle(
                                          color:
                                          const Color(0xffff7292),
                                          fontWeight: FontWeight.w500,
                                          fontFamily:
                                          "NotoSansCJKkr_Medium",
                                          fontStyle: FontStyle.normal,
                                          fontSize: _fontsize),
                                      textAlign: TextAlign.left),
                                ),
                                FlatButton(
                                  onPressed: () async {
                                    SharedPreferences prefs =
                                    await SharedPreferences
                                        .getInstance();
                                    await prefs.remove("uahageUserId");
                                    await prefs
                                        .remove("uahageLoginOption");
                                    Navigator.pop(context);

                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              loginPage()),
                                          (Route<dynamic> route) => false,
                                    );
                                    // Navigator.of(context)
                                    //     .popUntil((route) => route.isFirst);
                                  },
                                  child: // 네
                                  Text("네",
                                      style: TextStyle(
                                          color:
                                          const Color(0xffff7292),
                                          fontWeight: FontWeight.w500,
                                          fontFamily:
                                          "NotoSansCJKkr_Medium",
                                          fontStyle: FontStyle.normal,
                                          fontSize: _fontsize),
                                      textAlign: TextAlign.left),
                                ),
                              ],
                            ),
                          );
                        },
                        child: // 로그아웃
                        Text("로그아웃",
                            style: textStyle52,
                            textAlign: TextAlign.left),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 15 / screenWidth,
                            right: 15 / screenWidth),
                        child: Text(
                          "|",
                          style: textStyle52,
                        ),
                      ),
                      InkWell(
                        onTap: loginOption == "login"
                            ? () {
                          Fluttertoast.showToast(
                            msg: "  로그인 해주세요!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.black45,
                            textColor: Colors.white,
                            fontSize: 48 / screenWidth,
                          );
                        }
                            : () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                  "탈퇴하시겠습니까? 탈퇴 시 기존 데이터를 복구할 수 없습니다.",
                                  style: TextStyle(
                                      color:
                                      const Color(0xff4d4d4d),
                                      fontWeight: FontWeight.w500,
                                      fontFamily:
                                      "NotoSansCJKkr_Medium",
                                      fontStyle: FontStyle.normal,
                                      fontSize: 70.5 / screenWidth),
                                  textAlign: TextAlign.left),
                              actions: [
                                FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: // 아니요
                                  Text("아니요",
                                      style: TextStyle(
                                          color: const Color(
                                              0xffff7292),
                                          fontWeight:
                                          FontWeight.w500,
                                          fontFamily:
                                          "NotoSansCJKkr_Medium",
                                          fontStyle:
                                          FontStyle.normal,
                                          fontSize: _fontsize),
                                      textAlign:
                                      TextAlign.left),
                                ),
                                FlatButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    SharedPreferences prefs =
                                    await SharedPreferences
                                        .getInstance();
                                    await prefs
                                        .remove("uahageUserId");
                                    await prefs.remove(
                                        "uahageLoginOption");
                                    //delete data in the database
                                    showDialog(
                                      context: context,
                                      builder: (_) => FutureBuilder(
                                        future: withdrawalUser(),
                                        builder:
                                            (context, snapshot) {
                                          if (snapshot.hasData) {
                                            print("hasdata");
                                            WidgetsBinding.instance
                                                .addPostFrameCallback(
                                                    (_) {
                                                  Navigator.of(context).pushReplacement(
                                                      MaterialPageRoute(
                                                          builder: (BuildContext
                                                          context) =>
                                                              withdrawal()));
                                                });
                                          } else if (snapshot
                                              .hasError) {
                                            WidgetsBinding.instance
                                                .addPostFrameCallback(
                                                    (_) {
                                                  Navigator.of(context).pushReplacement(
                                                      MaterialPageRoute(
                                                          builder: (BuildContext
                                                          context) =>
                                                              withdrawal()));
                                                });
                                          }

                                          return Center(
                                            child: SizedBox(
                                                height: 200 /
                                                    screenHeight,
                                                width: 200 /
                                                    screenWidth,
                                                child:
                                                buildSpinKitThreeBounce(
                                                    80,
                                                    screenWidth)
                                              //     CircularProgressIndicator(
                                              //   strokeWidth: 5.0,
                                              //   valueColor:
                                              //       new AlwaysStoppedAnimation<
                                              //           Color>(
                                              //     Colors.pinkAccent,
                                              //   ),
                                              // )
                                            ),
                                          );
                                        },
                                      ),
                                    );

                                    // Navigator.pushReplacement(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => loginPage()));
                                    // Navigator.of(context)
                                    //     .popUntil((route) => route.isFirst);
                                  },
                                  child: // 네
                                  Text("네",
                                      style: TextStyle(
                                          color: const Color(
                                              0xffff7292),
                                          fontWeight:
                                          FontWeight.w500,
                                          fontFamily:
                                          "NotoSansCJKkr_Medium",
                                          fontStyle:
                                          FontStyle.normal,
                                          fontSize: _fontsize),
                                      textAlign:
                                      TextAlign.left),
                                ),
                              ],
                            ),
                          );
                        },
                        child: // 로그아웃   |   회원탈퇴
                        Text("회원탈퇴",
                            style: textStyle52,
                            textAlign: TextAlign.left),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
              : SingleChildScrollView(
            child: Column(
              children: [
                //back button
                Container(
                  margin: EdgeInsets.fromLTRB(81 / screenWidth,
                      110 / screenHeight, 1100 / screenWidth, 0),
                  child: onEdit
                      ? InkWell(
                    onTap: () {
                      setState(() {
                        onEdit = false;
                      });
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          "./assets/myPage/back.png",
                          width: 43 / screenWidth,
                          height: 76 / screenHeight,
                        ),
                        // 내 정보
                        Container(
                          margin: EdgeInsets.only(
                              left: 33 / screenWidth),
                          child: Text("내 정보",
                              style: TextStyle(
                                color: Color.fromRGBO(
                                    255, 114, 148, 1.0),
                                fontFamily: 'NotoSansCJKkr_Medium',
                                fontSize: 57 / screenWidth,
                              ),
                              textAlign: TextAlign.left),
                        )
                      ],
                    ),
                  )
                      : Container(),
                ),

                //Center avatar
                Center(
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 439 / screenHeight,
                        width: 439 / screenWidth,
                        child: CircleAvatar(
                          backgroundImage:
                          AssetImage("./assets/myPage/avatar.png"),
                          // backgroundImage: (() {
                          //   if (_image != null) {
                          //     print("1");
                          //     return FileImage(_image);
                          //   } else if (imageLink != "" && imageLink != null) {
                          //     print("2");
                          //     // print("here " + imageLink);
                          //     return NetworkImage(imageLink); //imageURL

                          //   } else {
                          //     print("3");
                          //     return AssetImage("./assets/myPage/avatar.png");
                          //   }
                          // }()),
                          // child: Image.network(imageLink),
                          child: (() {
                            // your code here

                            if (_image != null) {
                              print("1");
                              print("here " + imageLink);
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: FileImage(_image), //imageURL
                                      fit: BoxFit.fill),
                                ),
                              );
                            } else if (imageLink != "" &&
                                imageLink != null) {
                              print("2");
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: NetworkImage(imageLink),
                                      fit: BoxFit.fill),
                                ),
                              );
                            } else {
                              print("3");
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: AssetImage(
                                          "./assets/myPage/avatar.png"),
                                      fit: BoxFit.fill),
                                ),
                              );
                            }
                          }()),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            330 / screenWidth, 341 / screenHeight, 0, 0),
                        child: InkWell(
                          onTap: loginOption != "login"
                              ? () {
                            _showPicker(context);
                          }
                              : () {
                            Fluttertoast.showToast(
                              msg: "로그인 해주세요!",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black45,
                              textColor: Colors.white,
                              fontSize: 48 / screenWidth,
                            );
                          },
                          child: Image.asset(
                            "./assets/myPage/camera.png",
                            height: 109 / screenHeight,
                            width: 110 / screenWidth,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Nickname
                onEdit
                    ? Container(
                  margin: EdgeInsets.only(
                    top: 85 / screenHeight,
                  ),
                  child: Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 닉네임
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              157 / screenWidth,
                              45 / screenHeight,
                              88 / screenWidth,
                              0),
                          child: Text("닉네임",
                              style: TextStyle(
                                  color: const Color(0xffff7292),
                                  fontFamily:
                                  "NotoSansCJKkr_Medium",
                                  fontSize: 58 / screenWidth),
                              textAlign: TextAlign.left),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.only(
                              right: 121 / screenWidth,
                            ),
                            child: Stack(
                              children: [
                                TextFormField(
                                  // controller: yController,

                                  onChanged: (txt) {
                                    setState(() {
                                      nickName = txt;
                                    });
                                  },

                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Color(0xff3a3939),
                                      fontFamily:
                                      "NotoSansCJKkr_Bold",
                                      fontSize: 58 / screenWidth),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(
                                        right: 410 / screenWidth),
                                    enabledBorder:
                                    UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                        const Color(0xffff7292),
                                      ),

                                      //Color.fromRGBO(255, 114, 148, 1.0)
                                    ),
                                    focusedBorder:
                                    UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(0xffff7292)),
                                    ),
                                    hintText: '닉네임 수정 칼라',
                                    hintStyle: TextStyle(
                                        color:
                                        const Color(0xffcacaca),
                                        fontFamily:
                                        "NotoSansCJKkr_Medium",
                                        fontSize: 58 / screenWidth),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(
                                            8.0)),
                                    color: nickName == ""
                                        ? Color(0xffcacaca)
                                        : Color(0xffff7292),
                                    onPressed:
                                    loginOption != "login" &&
                                        nickName != ""
                                        ? () {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            FutureBuilder(
                                                future:
                                                checkNickname(),
                                                builder:
                                                    (context,
                                                    snapshot) {
                                                  if (snapshot
                                                      .hasData) {
                                                    // print(snapshot.data);
                                                    return AlertDialog(
                                                      shape:
                                                      RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                                                      title: // 사용 가능한 닉네임입니다.
                                                      Text(snapshot.data, style: TextStyle(color: const Color(0xff4d4d4d), fontWeight: FontWeight.w500, fontFamily: "NotoSansCJKkr_Medium", fontStyle: FontStyle.normal, fontSize: 62.5 / screenWidth), textAlign: TextAlign.left),
                                                      actions: [
                                                        FlatButton(
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                            },
                                                            child: // 확인
                                                            Text("확인", style: TextStyle(color: const Color(0xffff7292), fontWeight: FontWeight.w500, fontFamily: "NotoSansCJKkr_Medium", fontStyle: FontStyle.normal, fontSize: _fontsize), textAlign: TextAlign.center))
                                                      ],
                                                    );
                                                  } else if (snapshot
                                                      .hasError)
                                                    return AlertDialog(
                                                      shape:
                                                      RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                                                      title:
                                                      // id already exists.
                                                      Text(snapshot.error, style: TextStyle(color: Color(0xff4d4d4d), fontWeight: FontWeight.w500, fontFamily: "NotoSansCJKkr_Medium", fontStyle: FontStyle.normal, fontSize: 62.5 / screenWidth), textAlign: TextAlign.left),
                                                      actions: [
                                                        FlatButton(
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                            },
                                                            child: // 확인
                                                            Text("확인", style: TextStyle(color: const Color(0xffff7292), fontWeight: FontWeight.w500, fontFamily: "NotoSansCJKkr_Medium", fontStyle: FontStyle.normal, fontSize: _fontsize), textAlign: TextAlign.center))
                                                      ],
                                                    );

                                                  return Center(
                                                    child: SizedBox(
                                                        height: 200 / screenHeight,
                                                        width: 200 / screenWidth,
                                                        child: buildSpinKitThreeBounce(80, screenWidth)
                                                      // CircularProgressIndicator(
                                                      //   strokeWidth:
                                                      //       5.0,
                                                      //   valueColor:
                                                      //       new AlwaysStoppedAnimation<Color>(
                                                      //     Colors.pinkAccent,
                                                      //   ),
                                                      // )
                                                    ),
                                                  );
                                                }),
                                      );
                                    }
                                        : () {},
                                    child: // 중복확인
                                    Text("중복확인",
                                        style: TextStyle(
                                            color: const Color(
                                                0xffffffff),
                                            fontFamily:
                                            "NotoSansCJKkr_Medium",
                                            fontSize: 50 /
                                                screenWidth),
                                        textAlign:
                                        TextAlign.left),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : Container(
                  margin: EdgeInsets.only(top: 31 / screenHeight),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 320 / screenWidth,
                        child: userId == ""
                            ? nickNameShow("우아하게", screenWidth)
                            : FutureBuilder(
                          future: getMyNickname(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              // print("hasdata " + snapshot.data);
                              return snapshot.data != ""
                                  ? nickNameShow(
                                  snapshot.data,
                                  screenWidth)
                                  : nickNameShow(
                                  "우아하게", screenWidth);
                            } else if (snapshot.hasError) {
                              // print("haserror " + snapshot.error);
                              return nickNameShow(
                                  snapshot.error,
                                  screenWidth);
                            }
                            return Center(
                              child: SizedBox(
                                height: 50 / screenHeight,
                                width: 50 / screenWidth,
                                child:
                                buildSpinKitThreeBounce(
                                    30, screenWidth),
                                // CircularProgressIndicator(
                                //   strokeWidth: 5.0,
                                //   valueColor:
                                //       new AlwaysStoppedAnimation<
                                //           Color>(
                                //     Colors.pinkAccent,
                                //   ),
                                // ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            992 / screenWidth,
                            0,
                            148 / screenWidth,
                            0),
                        child: loginOption ==
                            "login" // Change this on release to ==
                            ? Image.asset(
                          "./assets/myPage/button1_grey.png",
                          width: 361 / screenWidth,
                          height: 147 / screenHeight,
                        )
                            : InkWell(
                          onTap: () {
                            setState(() {
                              onEdit = true;
                            });
                          },
                          child: Image.asset(
                            "./assets/myPage/button1.png",
                            width: 361 / screenWidth,
                            height: 147 / screenHeight,
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                //Gender
                Container(
                  margin: EdgeInsets.fromLTRB(
                      99 / screenWidth, 100 / screenHeight, 0, 0),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 아이성별
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            0, 24 / screenHeight, 56 / screenWidth, 0),
                        child: Text("아이성별",
                            style: TextStyle(
                                color: const Color(0xffff7292),
                                fontFamily: "NotoSansCJKkr_Medium",
                                fontSize: 57 / screenWidth),
                            textAlign: TextAlign.left),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            gender = "boy";
                            genderImage[0] = !genderImage[0];
                            genderImage[1] = false;
                          });
                        },
                        child: Image.asset(
                          genderImage[0]
                              ? "./assets/myPage/boy_pink.png"
                              : "./assets/myPage/boy_grey.png",
                          height: 363 / screenHeight,
                          width: 262 / screenWidth,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 98 / screenWidth),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              gender = "girl";
                              genderImage[1] = !genderImage[1];
                              genderImage[0] = false;
                            });
                          },
                          child: Image.asset(
                            genderImage[1]
                                ? "./assets/myPage/girl_pink.png"
                                : "./assets/myPage/girl_grey.png",
                            height: 363 / screenHeight,
                            width: 262 / screenWidth,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Birthday

                Container(
                  margin: EdgeInsets.fromLTRB(
                      99 / screenWidth, 40 / screenHeight, 0, 0),
                  child: Row(
                    children: [
                      // 아이생일
                      Text("아이생일",
                          style: TextStyle(
                            fontSize: 56 / screenWidth,
                            color: const Color(0xffff7292),
                            fontFamily: "NotoSansCJKkr_Medium",
                          ),
                          textAlign: TextAlign.left),
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.fromLTRB(
                              82 / screenWidth, 0, 121 / screenWidth, 0),
                          child: Stack(
                            children: [
                              TextFormField(
                                readOnly: true,
                                controller: yController,
                                onChanged: (txt) {
                                  setState(() {
                                    birthday = txt;
                                  });
                                },
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Color(0xffff7292),
                                    fontSize: 73 / screenWidth,
                                    fontFamily: 'NotoSansCJKkr_Medium',
                                    fontStyle: FontStyle.normal,
                                    letterSpacing: -1.0),
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: const Color(0xffff7292),
                                    ),
                                    //Color.fromRGBO(255, 114, 148, 1.0)
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(0xffff7292)),
                                  ),
                                  hintText: birthday == ""
                                      ? '생년월일을 선택해주세요'
                                      : birthday,
                                  hintStyle: TextStyle(
                                      color: const Color(0xffff7292),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "NotoSansCJKkr",
                                      fontStyle: FontStyle.normal,
                                      fontSize: 66.0 / screenWidth),
                                ),
                              ),
                              onEdit
                                  ? Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  onPressed: () {
                                    yearPicker();
                                  },
                                  icon: Image.asset(
                                      "./assets/myPage/calendar.png"),
                                ),
                              )
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Ages
                Container(
                  margin: EdgeInsets.fromLTRB(
                      155 / screenWidth, 98 / screenHeight, 0, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 보호자 연령대
                      Text("보호자\n연령대",
                          style: TextStyle(
                            color: const Color(0xffff7292),
                            fontWeight: FontWeight.w500,
                            fontFamily: "NotoSansCJKkr_Medium",
                            fontStyle: FontStyle.normal,
                            fontSize: _fontsize,
                          ),
                          textAlign: TextAlign.right),
                      Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 59 / screenWidth),
                                  child: InkWell(
                                    child: Image.asset(
                                      changeimage[0]
                                          ? './assets/registrationPage/10_pink.png'
                                          : './assets/registrationPage/10_grey.png',
                                      height: 196 / screenHeight,
                                      width: 251 / screenWidth,
                                    ),
                                    onTap: () {
                                      _change('10');
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 55 / screenWidth),
                                  child: InkWell(
                                    child: Image.asset(
                                      changeimage[1]
                                          ? './assets/registrationPage/20_pink.png'
                                          : './assets/registrationPage/20_grey.png',
                                      height: 196 / screenHeight,
                                      width: 251 / screenWidth,
                                    ),
                                    onTap: () {
                                      _change('20');
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 55 / screenWidth),
                                  child: InkWell(
                                    child: Image.asset(
                                      changeimage[2]
                                          ? './assets/registrationPage/30_pink.png'
                                          : './assets/registrationPage/30_grey.png',
                                      height: 196 / screenHeight,
                                      width: 251 / screenWidth,
                                    ),
                                    onTap: () {
                                      _change('30');
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 59 / screenWidth,
                                      top: 45 / screenHeight),
                                  child: InkWell(
                                    child: Image.asset(
                                      changeimage[3]
                                          ? './assets/registrationPage/40_pink.png'
                                          : './assets/registrationPage/40_grey.png',
                                      height: 196 / screenHeight,
                                      width: 251 / screenWidth,
                                    ),
                                    onTap: () {
                                      _change('40');
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 55 / screenWidth,
                                      top: 45 / screenHeight),
                                  child: InkWell(
                                    child: Image.asset(
                                      changeimage[4]
                                          ? './assets/registrationPage/50_pink.png'
                                          : './assets/registrationPage/50_grey.png',
                                      height: 196 / screenHeight,
                                      width: 251 / screenWidth,
                                    ),
                                    onTap: () {
                                      _change('50');
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 55 / screenWidth,
                                      top: 45 / screenHeight),
                                  child: InkWell(
                                    child: Image.asset(
                                      changeimage[5]
                                          ? './assets/registrationPage/others_pink.png'
                                          : './assets/registrationPage/others_grey.png',
                                      height: 196 / screenHeight,
                                      width: 251 / screenWidth,
                                    ),
                                    onTap: () {
                                      _change('60');
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Ok Button
                onEdit
                    ? Container(
                  margin: EdgeInsets.only(top: 87 / screenHeight),
                  child: SizedBox(
                    height: 194 / screenWidth,
                    width: 1193 / screenHeight,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      color: isIdValid
                          ? Color(0xffff7292)
                          : Color(0xffcacaca),
                      onPressed: isIdValid
                          ? () {
                        showDialog(
                          context: context,
                          builder: (context) => FutureBuilder(
                            future: updateNickname(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return AlertDialog(
                                  title: Text(snapshot.data),
                                  actions: [
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context);
                                        setState(() {
                                          onEdit = false;
                                        });
                                      },
                                      child: // 확인
                                      Text("확인",
                                          style: TextStyle(
                                              color: const Color(
                                                  0xffff7292),
                                              fontWeight:
                                              FontWeight
                                                  .w500,
                                              fontFamily:
                                              "NotoSansCJKkr_Medium",
                                              fontStyle:
                                              FontStyle
                                                  .normal,
                                              fontSize:
                                              _fontsize),
                                          textAlign:
                                          TextAlign
                                              .center),
                                    ),
                                  ],
                                );
                              } else if (snapshot.hasError) {
                                return AlertDialog(
                                  title: Text(snapshot.error),
                                  actions: [
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context);
                                      },
                                      child: // 확인
                                      Text("확인",
                                          style: TextStyle(
                                              color: const Color(
                                                  0xffff7292),
                                              fontWeight:
                                              FontWeight
                                                  .w500,
                                              fontFamily:
                                              "NotoSansCJKkr_Medium",
                                              fontStyle:
                                              FontStyle
                                                  .normal,
                                              fontSize:
                                              _fontsize),
                                          textAlign:
                                          TextAlign
                                              .center),
                                    ),
                                  ],
                                );
                              }
                              return Center(
                                child: SizedBox(
                                    height:
                                    200 / screenHeight,
                                    width: 200 / screenWidth,
                                    child:
                                    buildSpinKitThreeBounce(
                                        80, screenWidth)
                                  //     CircularProgressIndicator(
                                  //   strokeWidth: 5.0,
                                  //   valueColor:
                                  //       new AlwaysStoppedAnimation<
                                  //           Color>(
                                  //     Colors.pinkAccent,
                                  //   ),
                                  // ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                          : () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title:
                            Text("Check your ID first"),
                            actions: [
                              FlatButton(
                                child: Text("OK"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      child: // 중복확인
                      Text("OK",
                          style: TextStyle(
                              color: const Color(0xffffffff),
                              fontWeight: FontWeight.w500,
                              fontFamily:
                              "NotoSansCJKkr_Medium",
                              fontStyle: FontStyle.normal,
                              fontSize: 62 / screenWidth),
                          textAlign: TextAlign.left),
                    ),
                  ),
                )
                    : Container(),

                //logout
             userId!=""?
                Container(
                  margin: EdgeInsets.fromLTRB(
                      931 / screenWidth,
                      onEdit ? 88 / screenHeight : 370 / screenHeight,
                      0,
                      71 / screenHeight),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: // 로그아웃 하시겠습니까?
                              Text("로그아웃 하시겠습니까?",
                                  style: TextStyle(
                                      color: const Color(0xff4d4d4d),
                                      fontWeight: FontWeight.w500,
                                      fontFamily:
                                      "NotoSansCJKkr_Medium",
                                      fontStyle: FontStyle.normal,
                                      fontSize: 62.5 / screenWidth),
                                  textAlign: TextAlign.left),
                              actions: [
                                FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: // 아니요
                                  Text("아니요",
                                      style: TextStyle(
                                          color:
                                          const Color(0xffff7292),
                                          fontWeight: FontWeight.w500,
                                          fontFamily:
                                          "NotoSansCJKkr_Medium",
                                          fontStyle: FontStyle.normal,
                                          fontSize: _fontsize),
                                      textAlign: TextAlign.left),
                                ),
                                FlatButton(
                                  onPressed: () async {
                                    SharedPreferences prefs =
                                    await SharedPreferences
                                        .getInstance();
                                    await prefs.remove("uahageUserId");
                                    await prefs
                                        .remove("uahageLoginOption");
                                    Navigator.pop(context);

                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              loginPage()),
                                          (Route<dynamic> route) => false,
                                    );
                                    // Navigator.of(context)
                                    //     .popUntil((route) => route.isFirst);
                                  },
                                  child: // 네
                                  Text("네",
                                      style: TextStyle(
                                          color:
                                          const Color(0xffff7292),
                                          fontWeight: FontWeight.w500,
                                          fontFamily:
                                          "NotoSansCJKkr_Medium",
                                          fontStyle: FontStyle.normal,
                                          fontSize: _fontsize),
                                      textAlign: TextAlign.left),
                                ),
                              ],
                            ),
                          );
                        },
                        child: // 로그아웃
                        Text("로그아웃",
                            style: textStyle52,
                            textAlign: TextAlign.left),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 15 / screenWidth,
                            right: 15 / screenWidth),
                        child: Text(
                          "|",
                          style: textStyle52,
                        ),
                      ),
                      InkWell(
                        onTap: loginOption == "login"
                            ? () {
                          Fluttertoast.showToast(
                            msg: "  로그인 해주세요!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.black45,
                            textColor: Colors.white,
                            fontSize: 48 / screenWidth,
                          );
                        }
                            : () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                  "탈퇴하시겠습니까? 탈퇴 시 기존 데이터를 복구할 수 없습니다.",
                                  style: TextStyle(
                                      color:
                                      const Color(0xff4d4d4d),
                                      fontWeight: FontWeight.w500,
                                      fontFamily:
                                      "NotoSansCJKkr_Medium",
                                      fontStyle: FontStyle.normal,
                                      fontSize: 70.5 / screenWidth),
                                  textAlign: TextAlign.left),
                              actions: [
                                FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: // 아니요
                                  Text("아니요",
                                      style: TextStyle(
                                          color: const Color(
                                              0xffff7292),
                                          fontWeight:
                                          FontWeight.w500,
                                          fontFamily:
                                          "NotoSansCJKkr_Medium",
                                          fontStyle:
                                          FontStyle.normal,
                                          fontSize: _fontsize),
                                      textAlign:
                                      TextAlign.left),
                                ),
                                FlatButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    SharedPreferences prefs =
                                    await SharedPreferences
                                        .getInstance();
                                    await prefs
                                        .remove("uahageUserId");
                                    await prefs.remove(
                                        "uahageLoginOption");
                                    //delete data in the database
                                    showDialog(
                                      context: context,
                                      builder: (_) => FutureBuilder(
                                        future: withdrawalUser(),
                                        builder:
                                            (context, snapshot) {
                                          if (snapshot.hasData) {
                                            print("hasdata");
                                            WidgetsBinding.instance
                                                .addPostFrameCallback(
                                                    (_) {
                                                  Navigator.of(context).pushReplacement(
                                                      MaterialPageRoute(
                                                          builder: (BuildContext
                                                          context) =>
                                                              withdrawal()));
                                                });
                                          } else if (snapshot
                                              .hasError) {
                                            WidgetsBinding.instance
                                                .addPostFrameCallback(
                                                    (_) {
                                                  Navigator.of(context).pushReplacement(
                                                      MaterialPageRoute(
                                                          builder: (BuildContext
                                                          context) =>
                                                              withdrawal()));
                                                });
                                          }

                                          return Center(
                                            child: SizedBox(
                                                height: 200 /
                                                    screenHeight,
                                                width: 200 /
                                                    screenWidth,
                                                child:
                                                buildSpinKitThreeBounce(
                                                    80,
                                                    screenWidth)
                                              //     CircularProgressIndicator(
                                              //   strokeWidth: 5.0,
                                              //   valueColor:
                                              //       new AlwaysStoppedAnimation<
                                              //           Color>(
                                              //     Colors.pinkAccent,
                                              //   ),
                                              // )
                                            ),
                                          );
                                        },
                                      ),
                                    );

                                    // Navigator.pushReplacement(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => loginPage()));
                                    // Navigator.of(context)
                                    //     .popUntil((route) => route.isFirst);
                                  },
                                  child: // 네
                                  Text("네",
                                      style: TextStyle(
                                          color: const Color(
                                              0xffff7292),
                                          fontWeight:
                                          FontWeight.w500,
                                          fontFamily:
                                          "NotoSansCJKkr_Medium",
                                          fontStyle:
                                          FontStyle.normal,
                                          fontSize: _fontsize),
                                      textAlign:
                                      TextAlign.left),
                                ),
                              ],
                            ),
                          );
                        },
                        child: // 로그아웃   |   회원탈퇴
                        Text("회원탈퇴",
                            style: textStyle52,
                            textAlign: TextAlign.left),
                      ),
                    ],
                  ),
                ): Container(
               margin: EdgeInsets.fromLTRB(
                   931 / screenWidth,
                   onEdit ? 88 / screenHeight : 370 / screenHeight,
                   0,
                   71 / screenHeight),
               child:InkWell(
                   child: Text("로그인하기",
                       style: textStyle52, textAlign: TextAlign.left),
                   onTap:(){  Navigator.of(context).pop();}
               ),
             )
              ],
            ),
          ),
        ),
      ),
    );
  }

  SpinKitThreeBounce buildSpinKitThreeBounce(double size, double screenWidth) {
    return SpinKitThreeBounce(
      color: Color(0xffFF728E),
      size: size / screenWidth,
    );
  }

  Text nickNameShow(String txt, double screenHeight) {
    return Text(txt,
        maxLines: 3,
        overflow: TextOverflow.clip,
        style: TextStyle(
            color: const Color(0xff3a3939),
            fontFamily: "NotoSansCJKkr_Bold",
            fontSize: 70 / screenHeight),
        textAlign: TextAlign.center);
  }

  //changimagecolor
  void _change(String age) {
    if (age == '10') {
      setState(() {
        userAge = "10";
        changeimage[0] = true;
        changeimage[1] = false;
        changeimage[2] = false;
        changeimage[3] = false;
        changeimage[4] = false;
        changeimage[5] = false;
      });
    } else if (age == '20') {
      setState(() {
        userAge = "20";
        changeimage[0] = false;
        changeimage[1] = true;
        changeimage[2] = false;
        changeimage[3] = false;
        changeimage[4] = false;
        changeimage[5] = false;
      });
    } else if (age == '30') {
      setState(() {
        userAge = "30";
        changeimage[0] = false;
        changeimage[1] = false;
        changeimage[2] = true;
        changeimage[3] = false;
        changeimage[4] = false;
        changeimage[5] = false;
      });
    } else if (age == '40') {
      setState(() {
        userAge = "40";
        changeimage[0] = false;
        changeimage[1] = false;
        changeimage[2] = false;
        changeimage[3] = true;
        changeimage[4] = false;
        changeimage[5] = false;
      });
    } else if (age == '50') {
      setState(() {
        userAge = "50";
        changeimage[0] = false;
        changeimage[1] = false;
        changeimage[2] = false;
        changeimage[3] = false;
        changeimage[4] = true;
        changeimage[5] = false;
      });
    } else {
      setState(() {
        userAge = ">60";
        changeimage[0] = false;
        changeimage[1] = false;
        changeimage[2] = false;
        changeimage[3] = false;
        changeimage[4] = false;
        changeimage[5] = true;
      });
    }
  }

  yearPicker() {
    final year = DateTime.now().year;
    double screenHeight = 2667 / MediaQuery.of(context).size.height;
    double screenWidth = 1501 / MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          title: Text(
            '생년월일을 입력하세요',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 56 / screenWidth,
            ),
            textAlign: TextAlign.center,
          ),
          content: Container(
              height: MediaQuery.of(context).size.height / 5.0,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: CupertinoDatePicker(
                initialDateTime: DateTime.now(),
                onDateTimeChanged: (DateTime newDate) async {
                  yController.text = newDate.toString().substring(0, 10);
                },
                minimumYear: 2000,
                maximumYear: 2025,
                mode: CupertinoDatePickerMode.date,
              )),
          actions: <Widget>[
            FlatButton(
              child: Text(
                '네',
                style: TextStyle(
                  color: Color.fromRGBO(255, 114, 148, 1.0),
                  fontFamily: 'NotoSansCJKkr_Medium',
                  fontSize: 57 / screenWidth,
                ),
              ),
              onPressed: () {
                setState(() {
                  birthday = yController.text;
                  Navigator.of(context).pop();
                });
              },
            ),
            FlatButton(
              child: Text(
                '아니요',
                style: TextStyle(
                  color: Color.fromRGBO(255, 114, 148, 1.0),
                  fontFamily: 'NotoSansCJKkr_Medium',
                  fontSize: 57 / screenWidth,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
