import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dfctest/dfc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';

import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

List<Dfc> dfclist = [];
List<Dfc> baselinelist = [];
int selDfcId = 0;
String selDfcName = '';
int selBaselineDfcId = 0;
Dfc baselineregistresult = Dfc();
Dfc baselinegetresult = Dfc();
Dfc baselinelast = Dfc();
DfcDetail dfcdetail = DfcDetail();
bool _showProgress = false;
String apiBaseUrl = 'http://10.1.31.163';
String apiBaseUrl2 = 'http://10.1.31.163';
//String apApiBaseHost = '10.1.31.163';
//String dbApiBaseHost = '10.1.31.225:8000'; //'10.1.31.162';
Map<String, dynamic> responseMap = {};
Map<String, dynamic> resultDfcMap = {};
Map<String, dynamic> resultDfcMap2 = {};
String selSerialNo = '2222222';
String selServer = '225';
String selServer2 = '231';
String selHttp = 'http';
String selPort = '8888';

List<Widget> dataWidgetList = [];
List<Widget> dataWidgetList2 = [];
List<Widget> dataWidgetList3 = [];

bool _useMultiResult = true;
bool _showBaselineList = true;

Uint8List? fullImageBytes;
String fullImageUrl = '';
bool _showFullImage = false;

bool _hasProfileImage = false;
bool _hasScan2dImage = false;
bool _hasWipeImage = false;
bool _hasWipe2Image = false;

String djangohost = '';
String djangoport = '';
String apachehost = '';
String apacheport = '';

bool isUriValid = false;

Map<String, dynamic> server_images = {};

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DFC TEST',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 3, 83, 88),
        ),
      ),
      //home: HomePage(),
      home: MyHomePage(
        title: 'DFC : Dispenser accumulation check( EST_000040_DFC )',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  TextEditingController _editResult = TextEditingController();
  TextEditingController _editResult2 = TextEditingController();
  TextEditingController _editDjangoHost = TextEditingController();
  TextEditingController _editDjangoPort = TextEditingController();
  TextEditingController _editApacheHost = TextEditingController();
  TextEditingController _editApachePort = TextEditingController();
  TextEditingController _editSerialNo = TextEditingController();

  double _width = 0;

  Future<void> _saveHostInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    djangohost = _editDjangoHost.text.toString();
    djangoport = _editDjangoPort.text.toString();
    apachehost = _editApacheHost.text.toString();
    apacheport = _editApachePort.text.toString();

    setState(() {
      selSerialNo = _editSerialNo.text.toString();
    });

    prefs.setString('django_host', djangohost);
    prefs.setString('django_port', djangoport);
    prefs.setString('apache_host', apachehost);
    prefs.setString('apache_port', apacheport);
    prefs.setString('serialno', selSerialNo);

    updateApiUrl();
  }

  void _loadHostInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _editDjangoHost.text = prefs.getString('django_host') ?? '';
    _editDjangoPort.text = prefs.getString('django_port') ?? '';
    _editApacheHost.text = prefs.getString('apache_host') ?? '';
    _editApachePort.text = prefs.getString('apache_port') ?? '';
    _editSerialNo.text = prefs.getString('serialno') ?? '';

    setState(() {
      selSerialNo = _editSerialNo.text.toString();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadHostInfo();
    updateApiUrl();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    _width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey.shade400,
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Colors.black,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: txt720(widget.title, Colors.white),
      ),
      body: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: SingleChildScrollView(
                  child: Column(
                    // Column is also a layout widget. It takes a list of children and
                    // arranges them vertically. By default, it sizes itself to fit its
                    // children horizontally, and tries to be as tall as its parent.
                    //
                    // Column has various properties to control how it sizes itself and
                    // how it positions its children. Here we use mainAxisAlignment to
                    // center the children vertically; the main axis here is the vertical
                    // axis because Columns are vertical (the cross axis would be
                    // horizontal).
                    //
                    // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
                    // action in the IDE, or press "p" in the console), to see the
                    // wireframe for each widget.
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      txt514('Django HTTP HOST/PORT', Colors.black),
                      Row(
                        children: [
                          Container(
                            width: 110,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                  top: pad.sss,
                                  bottom: pad.sss,
                                ),
                                border: InputBorder.none,
                                labelText: null,
                                hintText: '10.1.31.225',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.grey.shade300,
                                ),
                                filled: true,
                                fillColor: Colors.white,

                                counterText: '',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black54,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                                enabledBorder: InputBorder.none,
                              ),
                              controller: _editDjangoHost,
                              autofocus: false,
                              maxLines: 1,
                              maxLength: 15,
                              autocorrect: false,
                              obscureText: false,
                              obscuringCharacter: '●',
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]'),
                                ),
                              ],
                              onChanged: (value) {},
                              onTap: () {},
                            ),
                          ),
                          hsb.s,
                          Container(
                            width: 60,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                  top: pad.sss,
                                  bottom: pad.sss,
                                ),
                                border: InputBorder.none,
                                labelText: null,
                                hintText: '8888',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.grey.shade300,
                                ),
                                filled: true,
                                fillColor: Colors.white,

                                counterText: '',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black54,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                                enabledBorder: InputBorder.none,
                              ),
                              controller: _editDjangoPort,
                              autofocus: false,
                              maxLines: 1,
                              maxLength: 5,
                              autocorrect: false,
                              obscureText: false,
                              obscuringCharacter: '●',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {},
                              onTap: () {},
                            ),
                          ),
                          hsb.sss,
                        ],
                      ),
                      vsb.s,
                      txt514('Apache HTTPS HOST/PORT', Colors.black),
                      Row(
                        children: [
                          Container(
                            width: 110,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                  top: pad.sss,
                                  bottom: pad.sss,
                                ),
                                border: InputBorder.none,
                                labelText: null,
                                hintText: '10.1.31.231',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.grey.shade300,
                                ),
                                filled: true,
                                fillColor: Colors.white,

                                counterText: '',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black54,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                                enabledBorder: InputBorder.none,
                              ),
                              controller: _editApacheHost,
                              autofocus: false,
                              maxLines: 1,
                              maxLength: 15,
                              autocorrect: false,
                              obscureText: false,
                              obscuringCharacter: '●',
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]'),
                                ),
                              ],
                              onChanged: (value) {},
                              onTap: () {},
                            ),
                          ),
                          hsb.s,
                          Container(
                            width: 60,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                  top: pad.sss,
                                  bottom: pad.sss,
                                ),
                                border: InputBorder.none,
                                labelText: null,
                                hintText: '80',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.grey.shade300,
                                ),
                                filled: true,
                                fillColor: Colors.white,

                                counterText: '',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black54,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                                enabledBorder: InputBorder.none,
                              ),
                              controller: _editApachePort,
                              autofocus: false,
                              maxLines: 1,
                              maxLength: 5,
                              autocorrect: false,
                              obscureText: false,
                              obscuringCharacter: '●',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {},
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                      vsb.s,

                      Row(
                        children: [
                          txt514('Serial No ', Colors.black),
                          hsb.s,
                          Container(
                            width: 107,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                  top: pad.sss,
                                  bottom: pad.sss,
                                ),
                                border: InputBorder.none,
                                labelText: null,
                                hintText: '2222222',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.grey.shade300,
                                ),
                                filled: true,
                                fillColor: Colors.white,

                                counterText: '',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black54,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                                enabledBorder: InputBorder.none,
                              ),
                              controller: _editSerialNo,
                              autofocus: false,
                              maxLines: 1,
                              maxLength: 15,
                              autocorrect: false,
                              obscureText: false,
                              obscuringCharacter: '●',
                              keyboardType: TextInputType.text,
                              inputFormatters: [],
                              onChanged: (value) {},
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                      vsb.s,

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  TxtBtn(
                                    text: 'DFC LIST ›',
                                    bgcolor: Colors.blue,
                                    onPressed: () {
                                      _doDfcList('false');
                                      _getBaseline();
                                    },
                                  ),
                                  Checkbox(
                                    value: _useMultiResult,
                                    fillColor:
                                        MaterialStateProperty.resolveWith<
                                          Color
                                        >((Set<MaterialState> states) {
                                          if (states.contains(
                                            MaterialState.selected,
                                          )) {
                                            return Colors.green; // 선택되었을 때의 색상
                                          } else if (states.contains(
                                            MaterialState.disabled,
                                          )) {
                                            return Colors.grey; // 비활성화되었을 때의 색상
                                          }
                                          return Colors
                                              .transparent; // 기본 색상 (체크되지 않은 상태)
                                        }),
                                    onChanged: (value) {
                                      setState(() {
                                        _useMultiResult = value!;
                                      });
                                    },
                                  ),
                                  txt410('multi\nshow', Colors.black87),
                                ],
                              ),

                              Visibility(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 0,
                                    top: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: getDfcListWidget(),
                                  ),
                                ),
                              ),

                              Visibility(
                                visible: dfclist.isNotEmpty,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: TxtBtn(
                                    text: 'BASELINE GET ›',
                                    bgcolor: Colors.orange.shade300,
                                    onPressed: () async {
                                      _getBaseline();
                                    },
                                  ),
                                ),
                              ),

                              Visibility(
                                visible: baselinegetresult.dfc_id > 0,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    left: 0,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade300,
                                      borderRadius: BorderRadius.circular(32),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: Offset(0, 5),
                                          blurRadius: 40,
                                          color: Color(
                                            0xFFD3D3D3,
                                          ).withOpacity(.84),
                                        ),
                                      ],
                                    ),
                                    child: txt514(
                                      '${baselinegetresult.dfc_id}, ${baselinegetresult.event_time}',
                                      Colors.black,
                                    ),
                                  ),
                                ),
                              ),

                              Visibility(
                                visible: dfclist.isNotEmpty,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      TxtBtn(
                                        text: 'BASELINE LIST ›',
                                        bgcolor: Colors.indigo,
                                        onPressed: () async {
                                          _doDfcList('true');
                                          setState(() {
                                            _showBaselineList = true;
                                          });
                                          _getBaseline();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Visibility(
                                visible: _showBaselineList,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 0,
                                    top: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: getBaselineListWidget(),
                                  ),
                                ),
                              ),

                              Visibility(
                                visible:
                                    selBaselineDfcId > 0 &&
                                    baselineregistresult.dfc_id > 0,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    left: 0,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade300,
                                      borderRadius: BorderRadius.circular(32),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: Offset(0, 5),
                                          blurRadius: 33,
                                          color: Color(
                                            0xFFD3D3D3,
                                          ).withOpacity(.84),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        txt514(
                                          '${baselineregistresult.dfc_id},${baselineregistresult.event_time}',
                                          Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    color: Colors.grey.shade200,
                    constraints: BoxConstraints(minHeight: 1200),
                    padding: EdgeInsets.all(10.0),
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: (_width - 360) / (_useMultiResult ? 2 : 1),
                            //width: (_width - 360) / (2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children:
                                  dataWidgetList +
                                  [
                                    txt614(
                                      '${_editDjangoHost.text}',
                                      Colors.black,
                                    ),

                                    SizedBox(
                                      width: 700,
                                      height: 500,
                                      child: TextFormField(
                                        controller: _editResult,
                                        maxLines: 1000,
                                      ),
                                    ),
                                  ],
                            ),
                          ),

                          Visibility(
                            visible: _useMultiResult,
                            child: SizedBox(
                              width: (_width - 360) / (_useMultiResult ? 2 : 1),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      dataWidgetList2 +
                                      [
                                        if (_useMultiResult)
                                          txt614(
                                            '${_editApacheHost.text}',
                                            Colors.black,
                                          ),
                                        if (_useMultiResult)
                                          SizedBox(
                                            width: 700,
                                            height: 500,
                                            child: TextFormField(
                                              controller: _editResult2,
                                              maxLines: 1000,
                                            ),
                                          ),
                                      ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          GestureDetector(
            onTap: () {
              setState(() {
                _showFullImage = false;
              });
            },
            child: AnimatedSize(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeOutExpo,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: _showFullImage ? 1.0 : 0.0,
                child: _showFullImage
                    ? Container(
                        color: Colors.black,
                        child: Center(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height,
                            child: fullImageBytes != null
                                ? Image.memory(fullImageBytes!)
                                : (fullImageUrl.isNotEmpty
                                      ? Image.network(fullImageUrl)
                                      : Container()),
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ),
            ),
          ),

          Visibility(
            visible: _showProgress,
            child: Center(
              child: SizedBox(
                width: 160,
                height: 160,
                child: LoadingIndicator(
                  indicatorType: Indicator.lineSpinFadeLoader,

                  /// Required, The loading type of the widget
                  colors: kIndicatorColorPrimary2,

                  /// Optional, The color collections
                  strokeWidth: 8,

                  /// Optional, The stroke of the line, only applicable to widget which contains line
                  backgroundColor: Colors.transparent,

                  /// Optional, Background of the widget
                  pathBackgroundColor: null,

                  /// Optional, the stroke backgroundColor
                ),
                // child: LoadingIndicator(
                //   indicatorType: Indicator.lineSpinFadeLoader,
                //   colors: kIndicatorColorPrimary,
                //   strokeWidth: 8.0,
                //   pathBackgroundColor: null,
                // ),
              ),
            ),
          ),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Map<String, dynamic> truncateImageData(Map<String, dynamic> input) {
    Map<String, dynamic> result = {};

    input.forEach((key, value) {
      if (value is String && value.startsWith('data:image')) {
        // UTF-8 바이트 기준으로 50바이트 자르기
        final bytes = utf8.encode(value);
        final shortenedBytes = bytes.length > 50 ? bytes.sublist(0, 50) : bytes;
        final shortenedString = utf8.decode(
          shortenedBytes,
          allowMalformed: true,
        );
        result[key] = '$shortenedString...';
      } else if (value is Map<String, dynamic>) {
        // 재귀적으로 처리
        result[key] = truncateImageData(value);
      } else if (value is List) {
        // 리스트 내부도 처리
        result[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return truncateImageData(item);
          } else if (item is String && item.startsWith('data:image')) {
            final bytes = utf8.encode(item);
            final shortenedBytes = bytes.length > 50
                ? bytes.sublist(0, 50)
                : bytes;
            final shortenedString = utf8.decode(
              shortenedBytes,
              allowMalformed: true,
            );
            return '$shortenedString...';
          } else {
            return item;
          }
        }).toList();
      } else {
        result[key] = value;
      }
    });

    return result;
  }

  void processResponseData(
    Map<String, dynamic> responseMap, {
    bool isResult2 = false,
  }) {
    final modifiedMap = truncateImageData(responseMap);

    // Beautify 처리: JSON pretty print
    final beautified = const JsonEncoder.withIndent('  ').convert(modifiedMap);

    setState(() {
      // 결과를 editResult에 넣기
      if (!isResult2) {
        _editResult.text = beautified;
      } else {
        _editResult2.text = beautified;
      }
    });
  }

  void updateApiUrl() {
    setState(() {
      if (selHttp == 'https') {
        apiBaseUrl =
            'http://localhost:30003/api/${_editApacheHost.text}:${_editApachePort.text}';
      } else {
        apiBaseUrl =
            '${selHttp}://${_editDjangoHost.text}:${_editDjangoPort.text}';
      }

      if (_useMultiResult) {
        apiBaseUrl2 =
            'http://localhost:30003/api/${_editApacheHost.text}:${_editApachePort.text}';
      }
    });

    setState(() {
      isUriValid =
          djangohost.isNotEmpty &&
          djangoport.isNotEmpty &&
          apachehost.isNotEmpty &&
          apacheport.isNotEmpty &&
          selSerialNo.isNotEmpty;
    });
  }

  List<Widget> _getDataWidgetList() {
    List<Widget> list = [];

    if (resultDfcMap.containsKey('PROFILE')) {
      list.add(
        Row(
          children: [
            Text('PROFILE', style: Theme.of(context).textTheme.headlineLarge),
            if (resultDfcMap['PROFILE']['headgroup1']['h1_profile_image'] ==
                null)
              txt618('   No Data', Colors.black),
          ],
        ),
      );
    }

    if (resultDfcMap.containsKey('PROFILE') &&
        resultDfcMap['PROFILE']['headgroup1']['h1_profile_image'] != null) {
      list.add(
        getImageWidget(
          resultDfcMap['PROFILE']['headgroup1']['h1_profile_image'],
        ),
      );
    }
    if (resultDfcMap.containsKey('PROFILE') &&
        resultDfcMap['PROFILE']['headgroup1']['h2_profile_image'] != null) {
      list.add(
        getImageWidget(
          resultDfcMap['PROFILE']['headgroup1']['h2_profile_image'],
        ),
      );
    }
    if (resultDfcMap.containsKey('PROFILE') &&
        resultDfcMap['PROFILE']['headgroup2']['h1_profile_image'] != null) {
      list.add(
        getImageWidget(
          resultDfcMap['PROFILE']['headgroup2']['h1_profile_image'],
        ),
      );
    }
    if (resultDfcMap.containsKey('PROFILE') &&
        resultDfcMap['PROFILE']['headgroup1']['h2_profile_image'] != null) {
      list.add(
        getImageWidget(
          resultDfcMap['PROFILE']['headgroup2']['h2_profile_image'],
        ),
      );
    }
    if (resultDfcMap.containsKey('SCAN2D')) {
      list.add(
        Row(
          children: [
            Text('SCAN2D', style: Theme.of(context).textTheme.headlineLarge),
            if (resultDfcMap['SCAN2D']['headgroup1']['h1_scan2d_image'] == null)
              txt618('   No Data', Colors.black),
          ],
        ),
      );
    }
    if (resultDfcMap.containsKey('SCAN2D') &&
        resultDfcMap['SCAN2D']['headgroup1']['h1_scan2d_image'] != null) {
      list.add(
        getImageWidget(resultDfcMap['SCAN2D']['headgroup1']['h1_scan2d_image']),
      );
    }
    if (resultDfcMap.containsKey('SCAN2D') &&
        resultDfcMap['SCAN2D']['headgroup1']['h2_scan2d_image'] != null) {
      list.add(
        getImageWidget(resultDfcMap['SCAN2D']['headgroup1']['h2_scan2d_image']),
      );
    }
    if (resultDfcMap.containsKey('SCAN2D') &&
        resultDfcMap['SCAN2D']['headgroup2']['h1_scan2d_image'] != null) {
      list.add(
        getImageWidget(resultDfcMap['SCAN2D']['headgroup2']['h1_scan2d_image']),
      );
    }
    if (resultDfcMap.containsKey('SCAN2D') &&
        resultDfcMap['SCAN2D']['headgroup2']['h2_scan2d_image'] != null) {
      list.add(
        getImageWidget(resultDfcMap['SCAN2D']['headgroup2']['h2_scan2d_image']),
      );
    }
    if (resultDfcMap.containsKey('WIPE')) {
      list.add(
        Row(
          children: [
            Text('WIPE', style: Theme.of(context).textTheme.headlineLarge),
            if (resultDfcMap['WIPE']['headgroup1']['h1_wipe_image'] == null)
              txt618('   No Data', Colors.black),
          ],
        ),
      );
    }
    if (resultDfcMap.containsKey('WIPE')) {
      list.add(
        getImageWidget(resultDfcMap['WIPE']['headgroup1']['h1_wipe_image']),
      );
    }
    if (resultDfcMap.containsKey('WIPE')) {
      list.add(
        getImageWidget(resultDfcMap['WIPE']['headgroup1']['h1_profile_image']),
      );
    }
    if (resultDfcMap.containsKey('WIPE')) {
      list.add(
        getImageWidget(resultDfcMap['WIPE']['headgroup1']['h2_wipe_image']),
      );
    }
    if (resultDfcMap.containsKey('WIPE')) {
      list.add(
        getImageWidget(resultDfcMap['WIPE']['headgroup1']['h2_profile_image']),
      );
    }
    if (resultDfcMap.containsKey('WIPE')) {
      list.add(
        getImageWidget(resultDfcMap['WIPE']['headgroup2']['h1_wipe_image']),
      );
    }
    if (resultDfcMap.containsKey('WIPE')) {
      list.add(
        getImageWidget(resultDfcMap['WIPE']['headgroup2']['h1_profile_image']),
      );
    }
    if (resultDfcMap.containsKey('WIPE')) {
      list.add(
        getImageWidget(resultDfcMap['WIPE']['headgroup2']['h2_wipe_image']),
      );
    }
    if (resultDfcMap.containsKey('WIPE')) {
      list.add(
        getImageWidget(resultDfcMap['WIPE']['headgroup2']['h2_profile_image']),
      );
    }
    if (resultDfcMap.containsKey('WIPE2')) {
      list.add(
        Row(
          children: [
            Text('WIPE2', style: Theme.of(context).textTheme.headlineLarge),
            if (resultDfcMap['WIPE2']['headgroup1']['h1_wipe_image'] == null)
              txt618('   No Data', Colors.black),
          ],
        ),
      );
    }

    if (resultDfcMap.containsKey('WIPE2')) {
      list.add(
        getImageWidget(resultDfcMap['WIPE2']['headgroup1']['h1_wipe_image']),
      );
    }
    if (resultDfcMap.containsKey('WIPE2')) {
      list.add(
        getImageWidget(resultDfcMap['WIPE2']['headgroup1']['h1_profile_image']),
      );
    }
    if (resultDfcMap.containsKey('WIPE2')) {
      list.add(
        getImageWidget(resultDfcMap['WIPE2']['headgroup1']['h2_wipe_image']),
      );
    }
    if (resultDfcMap.containsKey('WIPE2')) {
      list.add(
        getImageWidget(resultDfcMap['WIPE2']['headgroup1']['h2_profile_image']),
      );
    }
    if (resultDfcMap.containsKey('WIPE2')) {
      list.add(
        getImageWidget(resultDfcMap['WIPE2']['headgroup2']['h1_wipe_image']),
      );
    }
    if (resultDfcMap.containsKey('WIPE2')) {
      list.add(
        getImageWidget(resultDfcMap['WIPE2']['headgroup2']['h1_profile_image']),
      );
    }
    if (resultDfcMap.containsKey('WIPE2')) {
      list.add(
        getImageWidget(resultDfcMap['WIPE2']['headgroup2']['h2_wipe_image']),
      );
    }
    if (resultDfcMap.containsKey('WIPE2')) {
      list.add(
        getImageWidget(resultDfcMap['WIPE2']['headgroup2']['h2_profile_image']),
      );
    }

    return list;
  }

  List<Widget> _getDataWidgetList3() {
    List<Widget> list = [];

    if (resultDfcMap.containsKey('PROFILE')) {
      list.add(
        Text('PROFILE', style: Theme.of(context).textTheme.headlineLarge),
      );
    }

    if (resultDfcMap.containsKey('PROFILE') &&
        resultDfcMap['PROFILE']['headgroup1']['h1_profile_image'] != null) {
      list.add(
        // getImageWidget(
        //   resultDfcMap['PROFILE']['headgroup1']['h1_profile_image'],
        // ),
        getLocalImage(resultDfcMap['PROFILE']['headgroup1']['h1_profile_url']),
      );
    }
    if (resultDfcMap.containsKey('PROFILE') &&
        resultDfcMap['PROFILE']['headgroup1']['h2_profile_image'] != null) {
      list.add(
        // getImageWidget(
        //   resultDfcMap['PROFILE']['headgroup1']['h2_profile_image'],
        // ),
        getLocalImage(resultDfcMap['PROFILE']['headgroup1']['h2_profile_url']),
      );
    }
    if (resultDfcMap.containsKey('PROFILE') &&
        resultDfcMap['PROFILE']['headgroup2']['h1_profile_image'] != null) {
      list.add(
        getLocalImage(resultDfcMap['PROFILE']['headgroup2']['h1_profile_url']),
      );
    }
    if (resultDfcMap.containsKey('PROFILE') &&
        resultDfcMap['PROFILE']['headgroup2']['h2_profile_image'] != null) {
      list.add(
        getLocalImage(resultDfcMap['PROFILE']['headgroup2']['h2_profile_url']),
      );
    }
    if (resultDfcMap.containsKey('SCAN2D')) {
      list.add(
        Text('SCAN2D', style: Theme.of(context).textTheme.headlineLarge),
      );
    }
    if (resultDfcMap.containsKey('SCAN2D') &&
        resultDfcMap['SCAN2D']['headgroup1']['h1_scan2d_image'] != null) {
      list.add(
        getScan2dLocalImage(
          resultDfcMap['SCAN2D']['headgroup1']['h1_scan2d_url'],
          resultDfcMap['SCAN2D']['headgroup1']['h1_diff_url'],
        ),
      );
    }
    if (resultDfcMap.containsKey('SCAN2D') &&
        resultDfcMap['SCAN2D']['headgroup1']['h2_scan2d_image'] != null) {
      list.add(
        getScan2dLocalImage(
          resultDfcMap['SCAN2D']['headgroup1']['h2_scan2d_url'],
          resultDfcMap['SCAN2D']['headgroup1']['h2_diff_url'],
        ),
      );
    }
    if (resultDfcMap.containsKey('SCAN2D') &&
        resultDfcMap['SCAN2D']['headgroup2']['h1_scan2d_image'] != null) {
      list.add(
        getScan2dLocalImage(
          resultDfcMap['SCAN2D']['headgroup2']['h1_scan2d_url'],
          resultDfcMap['SCAN2D']['headgroup2']['h1_diff_url'],
        ),
      );
    }
    if (resultDfcMap.containsKey('SCAN2D') &&
        resultDfcMap['SCAN2D']['headgroup2']['h2_scan2d_image'] != null) {
      list.add(
        getScan2dLocalImage(
          resultDfcMap['SCAN2D']['headgroup2']['h2_scan2d_url'],
          resultDfcMap['SCAN2D']['headgroup2']['h2_diff_url'],
        ),
      );
    }
    if (resultDfcMap.containsKey('WIPE')) {
      list.add(Text('WIPE', style: Theme.of(context).textTheme.headlineLarge));
    }
    if (resultDfcMap.containsKey('WIPE') &&
        resultDfcMap['WIPE']['headgroup1']['h1_wipe_image'] != null) {
      list.add(
        getLocalImage(resultDfcMap['WIPE']['headgroup1']['h1_wipe_url']),
      );
    }
    if (resultDfcMap.containsKey('WIPE') &&
        resultDfcMap['WIPE']['headgroup1']['h1_profile_image'] != null) {
      list.add(
        getLocalImage(resultDfcMap['WIPE']['headgroup1']['h1_profile_url']),
      );
    }
    if (resultDfcMap.containsKey('WIPE') &&
        resultDfcMap['WIPE']['headgroup1']['h2_wipe_image'] != null) {
      list.add(
        getLocalImage(resultDfcMap['WIPE']['headgroup1']['h2_wipe_url']),
      );
    }
    if (resultDfcMap.containsKey('WIPE') &&
        resultDfcMap['WIPE']['headgroup1']['h2_profile_image'] != null) {
      list.add(
        getLocalImage(resultDfcMap['WIPE']['headgroup1']['h2_profile_url']),
      );
    }
    if (resultDfcMap.containsKey('WIPE') &&
        resultDfcMap['WIPE']['headgroup2']['h1_wipe_image'] != null) {
      list.add(
        getLocalImage(resultDfcMap['WIPE']['headgroup2']['h1_wipe_url']),
      );
    }
    if (resultDfcMap.containsKey('WIPE') &&
        resultDfcMap['WIPE']['headgroup2']['h1_profile_image'] != null) {
      list.add(
        getLocalImage(resultDfcMap['WIPE']['headgroup2']['h1_profile_url']),
      );
    }
    if (resultDfcMap.containsKey('WIPE') &&
        resultDfcMap['WIPE']['headgroup2']['h2_wipe_image'] != null) {
      list.add(
        getLocalImage(resultDfcMap['WIPE']['headgroup2']['h2_wipe_url']),
      );
    }
    if (resultDfcMap.containsKey('WIPE') &&
        resultDfcMap['WIPE']['headgroup2']['h2_profile_image'] != null) {
      list.add(
        getLocalImage(resultDfcMap['WIPE']['headgroup2']['h2_profile_url']),
      );
    }
    if (resultDfcMap.containsKey('WIPE2')) {
      list.add(Text('WIPE2', style: Theme.of(context).textTheme.headlineLarge));
    }

    if (resultDfcMap.containsKey('WIPE2') &&
        resultDfcMap['WIPE2']['headgroup1']['h1_wipe_image'] != null) {
      list.add(
        getLocalImage(resultDfcMap['WIPE2']['headgroup1']['h1_wipe_url']),
      );
    }
    if (resultDfcMap.containsKey('WIPE2') &&
        resultDfcMap['WIPE2']['headgroup1']['h1_profile_image'] != null) {
      list.add(
        getLocalImage(resultDfcMap['WIPE2']['headgroup1']['h1_profile_url']),
      );
    }
    if (resultDfcMap.containsKey('WIPE2') &&
        resultDfcMap['WIPE2']['headgroup1']['h2_wipe_image'] != null) {
      list.add(
        getLocalImage(resultDfcMap['WIPE2']['headgroup1']['h2_wipe_url']),
      );
    }
    if (resultDfcMap.containsKey('WIPE2') &&
        resultDfcMap['WIPE2']['headgroup1']['h2_profile_image'] != null) {
      list.add(
        getLocalImage(resultDfcMap['WIPE2']['headgroup1']['h2_profile_url']),
      );
    }
    if (resultDfcMap.containsKey('WIPE2') &&
        resultDfcMap['WIPE2']['headgroup2']['h1_wipe_image'] != null) {
      list.add(
        getLocalImage(resultDfcMap['WIPE2']['headgroup2']['h1_wipe_url']),
      );
    }
    if (resultDfcMap.containsKey('WIPE2') &&
        resultDfcMap['WIPE2']['headgroup2']['h1_profile_image'] != null) {
      list.add(
        getLocalImage(resultDfcMap['WIPE2']['headgroup2']['h1_profile_url']),
      );
    }
    if (resultDfcMap.containsKey('WIPE2') &&
        resultDfcMap['WIPE2']['headgroup2']['h2_wipe_image'] != null) {
      list.add(
        getLocalImage(resultDfcMap['WIPE2']['headgroup2']['h2_wipe_url']),
      );
    }
    if (resultDfcMap.containsKey('WIPE2') &&
        resultDfcMap['WIPE2']['headgroup2']['h2_profile_image'] != null) {
      list.add(
        getLocalImage(resultDfcMap['WIPE2']['headgroup2']['h2_profile_url']),
      );
    }

    return list;
  }

  List<Widget> _getDataWidgetList2() {
    List<Widget> list = [];

    if (resultDfcMap2.containsKey('PROFILE')) {
      list.add(
        Text('PROFILE', style: Theme.of(context).textTheme.headlineLarge),
      );
    }

    if (resultDfcMap2.containsKey('PROFILE') &&
        resultDfcMap2['PROFILE']['headgroup1']['h1_profile_image'] != null) {
      list.add(
        getImageWidget(
          resultDfcMap2['PROFILE']['headgroup1']['h1_profile_image'],
        ),
      );
    }
    if (resultDfcMap2.containsKey('PROFILE') &&
        resultDfcMap2['PROFILE']['headgroup1']['h2_profile_image'] != null) {
      list.add(
        getImageWidget(
          resultDfcMap2['PROFILE']['headgroup1']['h2_profile_image'],
        ),
      );
    }
    if (resultDfcMap2.containsKey('PROFILE') &&
        resultDfcMap2['PROFILE']['headgroup2']['h1_profile_image'] != null) {
      list.add(
        getImageWidget(
          resultDfcMap2['PROFILE']['headgroup2']['h1_profile_image'],
        ),
      );
    }
    if (resultDfcMap2.containsKey('PROFILE') &&
        resultDfcMap2['PROFILE']['headgroup1']['h2_profile_image'] != null) {
      list.add(
        getImageWidget(
          resultDfcMap2['PROFILE']['headgroup2']['h2_profile_image'],
        ),
      );
    }
    if (resultDfcMap2.containsKey('SCAN2D')) {
      list.add(
        Text('SCAN2D', style: Theme.of(context).textTheme.headlineLarge),
      );
    }
    if (resultDfcMap2.containsKey('SCAN2D') &&
        resultDfcMap2['SCAN2D']['headgroup1']['h1_scan2d_image'] != null) {
      list.add(
        getImageWidget(
          resultDfcMap2['SCAN2D']['headgroup1']['h1_scan2d_image'],
        ),
      );
    }
    if (resultDfcMap2.containsKey('SCAN2D') &&
        resultDfcMap2['SCAN2D']['headgroup1']['h2_scan2d_image'] != null) {
      list.add(
        getImageWidget(
          resultDfcMap2['SCAN2D']['headgroup1']['h2_scan2d_image'],
        ),
      );
    }
    if (resultDfcMap2.containsKey('SCAN2D') &&
        resultDfcMap2['SCAN2D']['headgroup2']['h1_scan2d_image'] != null) {
      list.add(
        getImageWidget(
          resultDfcMap2['SCAN2D']['headgroup2']['h1_scan2d_image'],
        ),
      );
    }
    if (resultDfcMap2.containsKey('SCAN2D') &&
        resultDfcMap2['SCAN2D']['headgroup2']['h2_scan2d_image'] != null) {
      list.add(
        getImageWidget(
          resultDfcMap2['SCAN2D']['headgroup2']['h2_scan2d_image'],
        ),
      );
    }
    if (resultDfcMap2.containsKey('WIPE')) {
      list.add(Text('WIPE', style: Theme.of(context).textTheme.headlineLarge));
    }
    if (resultDfcMap2.containsKey('WIPE')) {
      list.add(
        getImageWidget(resultDfcMap2['WIPE']['headgroup1']['h1_wipe_image']),
      );
    }
    if (resultDfcMap2.containsKey('WIPE')) {
      list.add(
        getImageWidget(resultDfcMap2['WIPE']['headgroup1']['h1_profile_image']),
      );
    }
    if (resultDfcMap2.containsKey('WIPE')) {
      list.add(
        getImageWidget(resultDfcMap2['WIPE']['headgroup1']['h2_wipe_image']),
      );
    }
    if (resultDfcMap2.containsKey('WIPE')) {
      list.add(
        getImageWidget(resultDfcMap2['WIPE']['headgroup1']['h2_profile_image']),
      );
    }
    if (resultDfcMap2.containsKey('WIPE')) {
      list.add(
        getImageWidget(resultDfcMap2['WIPE']['headgroup2']['h1_wipe_image']),
      );
    }
    if (resultDfcMap2.containsKey('WIPE')) {
      list.add(
        getImageWidget(resultDfcMap2['WIPE']['headgroup2']['h1_profile_image']),
      );
    }
    if (resultDfcMap2.containsKey('WIPE')) {
      list.add(
        getImageWidget(resultDfcMap2['WIPE']['headgroup2']['h2_wipe_image']),
      );
    }
    if (resultDfcMap2.containsKey('WIPE')) {
      list.add(
        getImageWidget(resultDfcMap2['WIPE']['headgroup2']['h2_profile_image']),
      );
    }
    if (resultDfcMap2.containsKey('WIPE2')) {
      list.add(Text('WIPE2', style: Theme.of(context).textTheme.headlineLarge));
    }

    if (resultDfcMap2.containsKey('WIPE2')) {
      list.add(
        getImageWidget(resultDfcMap2['WIPE2']['headgroup1']['h1_wipe_image']),
      );
    }
    if (resultDfcMap2.containsKey('WIPE2')) {
      list.add(
        getImageWidget(
          resultDfcMap2['WIPE2']['headgroup1']['h1_profile_image'],
        ),
      );
    }
    if (resultDfcMap2.containsKey('WIPE2')) {
      list.add(
        getImageWidget(resultDfcMap2['WIPE2']['headgroup1']['h2_wipe_image']),
      );
    }
    if (resultDfcMap2.containsKey('WIPE2')) {
      list.add(
        getImageWidget(
          resultDfcMap2['WIPE2']['headgroup1']['h2_profile_image'],
        ),
      );
    }
    if (resultDfcMap2.containsKey('WIPE2')) {
      list.add(
        getImageWidget(resultDfcMap2['WIPE2']['headgroup2']['h1_wipe_image']),
      );
    }
    if (resultDfcMap2.containsKey('WIPE2')) {
      list.add(
        getImageWidget(
          resultDfcMap2['WIPE2']['headgroup2']['h1_profile_image'],
        ),
      );
    }
    if (resultDfcMap2.containsKey('WIPE2')) {
      list.add(
        getImageWidget(resultDfcMap2['WIPE2']['headgroup2']['h2_wipe_image']),
      );
    }
    if (resultDfcMap2.containsKey('WIPE2')) {
      list.add(
        getImageWidget(
          resultDfcMap2['WIPE2']['headgroup2']['h2_profile_image'],
        ),
      );
    }

    return list;
  }

  Future<void> _doDfcList(String is_baseline) async {
    _saveHostInfo();

    if (_editDjangoHost.text.isEmpty || _editApacheHost.text.isEmpty) {
      await Future.delayed(Duration(milliseconds: 1500));
    }

    if (!isUriValid) return;

    setState(() {
      _showProgress = true;

      _hasProfileImage = false;
      _hasScan2dImage = false;
      _hasWipeImage = false;
      _hasWipe2Image = false;

      dataWidgetList = [];
      dataWidgetList2 = [];
      dataWidgetList3 = [];

      baselinegetresult = Dfc();

      _editResult.text = '';
      _editResult2.text = '';
    });

    try {
      final dio = Dio()..options.baseUrl = apiBaseUrl;
      print(apiBaseUrl);

      var response = await dio.post(
        selHttp == 'https' ? '/server/dbapps/' : '/dfc/list/',
        data: {
          'model_id': 'TX-101',
          'tool': selSerialNo,
          'series_id': 'IAP',
          'start_time': '2024-01-01 01:01:01',
          'end_time': '2027-08-01 01:01:01',
          'user_id': 'cannon',
          'is_baseline': '$is_baseline',
          'db_api_name': 'dfc/list',
        },
      );

      var responseMap = response.data;
      setState(() {
        processResponseData(responseMap);

        resultDfcMap = {};

        if (is_baseline == 'false') {
          dfclist = [];
          var dfcList = selHttp == 'https'
              ? responseMap['dfc_list'] as List
              : responseMap['content']['dfc_list'] as List;
          dfclist = dfcList.map((json) => Dfc.fromJson(json)).toList();

          selDfcId = 0;
          selBaselineDfcId = 0;
          baselinelist = [];
          dfcdetail = DfcDetail();
        } else {
          baselinelist = [];
          var baselinList = selHttp == 'https'
              ? responseMap['dfc_list'] as List
              : responseMap['content']['dfc_list'] as List;
          baselinelist = baselinList.map((json) => Dfc.fromJson(json)).toList();

          selBaselineDfcId = 0;
        }

        dataWidgetList = _getDataWidgetList();
      });
      setState(() {
        _showProgress = false;
      });
    } catch (e) {
      print('예외 발생: $e');

      Fluttertoast.showToast(
        msg: '예외 발생: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      setState(() {
        _showProgress = false;
      });
    }
  }

  Future<void> _getBaseline() async {
    _saveHostInfo();

    if (_editDjangoHost.text.isEmpty || _editApacheHost.text.isEmpty) {
      await Future.delayed(Duration(milliseconds: 1500));
    }

    if (!isUriValid) return;

    setState(() {
      _showProgress = true;
    });
    try {
      final dio = Dio()..options.baseUrl = apiBaseUrl;

      var response = await dio.post(
        selHttp == 'https' ? '/server/dbapps/' : '/dfc/baselinedata/',
        data: {
          'model_id': 'TX-101',
          'tool': '${selSerialNo}',
          'series_id': 'IAP',
          'user_id': 'cannon',
          'db_api_name': 'dfc/baselinedata',
        },
      );

      var responseMap = response.data;

      setState(() {
        processResponseData(responseMap);
        baselinegetresult = Dfc();
        var result = selHttp == 'https'
            ? responseMap['data']
            : responseMap['content']['data'];
        setState(() {
          baselinegetresult = Dfc.fromJson(result);
        });
      });
      setState(() {
        _showProgress = false;
      });
    } catch (ex) {
      print(ex);
      setState(() {
        _showProgress = false;
      });
    }
  }

  Future<void> _showDetails() async {
    _saveHostInfo();

    if (_editDjangoHost.text.isEmpty || _editApacheHost.text.isEmpty) {
      await Future.delayed(Duration(milliseconds: 1500));
    }

    if (!isUriValid) return;

    setState(() {
      resultDfcMap = {};
      dataWidgetList = [];
      dataWidgetList2 = [];
      dataWidgetList3 = [];
      _showProgress = true;
    });
    try {
      final dio = Dio()..options.baseUrl = apiBaseUrl;

      var response = await dio.post(
        selHttp == 'https' ? '/server/dbapps/' : '/dfc/data/',
        data: {
          'model_id': 'TX-101',
          'tool': '${selSerialNo}',
          'series_id': 'IAP',
          'start_time': '2025-01-01 01:01:01',
          'end_time': '2025-08-01 01:01:01',
          'user_id': 'cannon',
          'dfc_id': selDfcId,
          'db_api_name': 'dfc/data',
        },
      );

      var responseMap = response.data;

      setState(() {
        processResponseData(responseMap);

        resultDfcMap = {};
        dfcdetail = DfcDetail();

        resultDfcMap = selHttp == 'https'
            ? responseMap['data']
            : responseMap['content']['data'];

        dataWidgetList = _getDataWidgetList();

        // dataWidgetList3 =
        //     _getDataWidgetList3();
      });

      setState(() {
        _showProgress = false;
      });

      Future.delayed(const Duration(milliseconds: 200), () async {
        _saveHostInfo();

        if (_editDjangoHost.text.isEmpty || _editApacheHost.text.isEmpty) {
          await Future.delayed(Duration(milliseconds: 1500));
        }

        if (!isUriValid) return;

        if (_useMultiResult) {
          setState(() {
            _showProgress = true;
          });

          final dio = Dio()..options.baseUrl = apiBaseUrl2;

          var response = await dio.post(
            '/server/dbapps/',
            data: {
              'model_id': 'TX-101',
              'tool': '${selSerialNo}',
              'series_id': 'IAP',
              'start_time': '2025-01-01 01:01:01',
              'end_time': '2025-08-01 01:01:01',
              'user_id': 'cannon',
              'dfc_id': selDfcId,
              'db_api_name': 'dfc/data',
            },
          );

          var responseMap = response.data;

          setState(() {
            processResponseData(responseMap, isResult2: true);

            resultDfcMap2 = {};
            dfcdetail = DfcDetail();

            resultDfcMap2 = responseMap['data'];

            dataWidgetList2 = _getDataWidgetList2();
          });

          setState(() {
            _showProgress = false;
          });
        }
      });
    } catch (ex) {
      print(ex);
      setState(() {
        _showProgress = false;
      });
    }

    _saveHostInfo();
  }

  Future<bool> compareUint8listImages(
    Uint8List bytes1,
    Uint8List bytes2,
  ) async {
    //final response1 = await http.get(Uri.parse('https://example.com/image1.png'));
    //final response2 = await http.get(Uri.parse('https://example.com/image2.png'));

    // Uint8List를 이미지로 디코딩
    final image1 = img.decodeImage(bytes1);
    final image2 = img.decodeImage(bytes2);

    if (image1 == null || image2 == null) {
      print('이미지를 디코딩할 수 없습니다.');
      return false;
    }

    // 크기 비교
    if (image1.width != image2.width || image1.height != image2.height) {
      print('이미지 크기가 다릅니다.');
      return false;
    }

    // 픽셀 비교
    for (int y = 0; y < image1.height; y++) {
      for (int x = 0; x < image1.width; x++) {
        if (image1.getPixel(x, y) != image2.getPixel(x, y)) {
          print('이미지에 픽셀 단위 차이가 있습니다.');
          return false;
        }
      }
    }

    // 동일한 이미지
    return true;
  }

  Widget getImageWidget([dynamic base64String, String imageName = '']) {
    if (base64String != null) {
      if (base64String.isNotEmpty) {
        try {
          final firstPass = base64String.contains(',')
              ? base64String.split(',').last.trim()
              : base64String.trim();
          Uint8List imageBytes = base64Decode(firstPass);
          //final cleaned = utf8.decode(base64Decode(firstPass));
          if (imageName.isNotEmpty) server_images[imageName] = imageBytes;

          return GestureDetector(
            onTap: () {
              setState(() {
                fullImageBytes = imageBytes;
                _showFullImage = true;
              });
            },
            child: _useMultiResult
                ? SizedBox(height: 480, child: Image.memory(imageBytes))
                : Image.memory(imageBytes),
          );
        } catch (e) {
          return Container();
        }
      } else {
        return Container();
      }
    } else {
      return Container();
    }
  }

  Future<Uint8List?> uriToUint8List(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      return null;
    }
  }

  Future<bool> compareImages(Uint8List bytes1, Uint8List bytes2) async {
    // 이미지 디코딩
    final image1 = img.decodeImage(bytes1);
    final image2 = img.decodeImage(bytes2);

    if (image1 == null || image2 == null) {
      print('이미지를 디코딩할 수 없습니다.');
      return false;
    }

    // 크기 비교
    if (image1.width != image2.width || image1.height != image2.height) {
      print('이미지 크기가 다릅니다.');
      return false;
    }

    // 픽셀 비교
    for (int y = 0; y < image1.height; y++) {
      for (int x = 0; x < image1.width; x++) {
        if (image1.getPixel(x, y) != image2.getPixel(x, y)) {
          print('이미지에 픽셀 단위 차이가 있습니다.');
          return false;
        }
      }
    }

    // 동일한 이미지
    return true;
  }

  Widget getLocalImage(String imageName) {
    if (imageName.isNotEmpty) {
      try {
        // var local_bytes = await uriToUint8List(
        //   'http://localhost:39999/$selDfcName/${imageName}',
        // );

        // var issame = false;
        // if (local_bytes != null && server_images[imageName] != null) {
        //   issame = await compareImages(server_images[imageName], local_bytes);
        // }

        return SizedBox(
          height: 480,
          child: GestureDetector(
            onTap: () {
              setState(() {
                fullImageBytes = null;
                fullImageUrl =
                    'http://localhost:39999/${selDfcName}/${imageName}';
                _showFullImage = true;
              });
            },
            child: Image.network(
              'http://localhost:39999/${selDfcName}/${imageName}',
              errorBuilder: (context, error, stackTrace) {
                return Text('이미지 로딩 실패');
              },
            ),
          ),
        );
      } catch (e) {
        return Container();
      }
    } else {
      return Container();
    }
  }

  Widget getScan2dLocalImage(String imageName, String diffIMageName) {
    if (imageName.isNotEmpty) {
      try {
        return Row(
          children: [
            SizedBox(
              height: 480,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    fullImageBytes = null;
                    fullImageUrl =
                        'http://localhost:39999/${selDfcName}/${imageName}';
                    _showFullImage = true;
                  });
                },
                child: Image.network(
                  'http://localhost:39999/${selDfcName}/${imageName}',
                  errorBuilder: (context, error, stackTrace) {
                    return Text('이미지 로딩 실패');
                  },
                ),
              ),
            ),
            SizedBox(
              height: 480,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    fullImageBytes = null;
                    fullImageUrl =
                        'http://localhost:39999/${selDfcName}/${diffIMageName}';
                    _showFullImage = true;
                  });
                },
                child: Image.network(
                  'http://localhost:39999/${selDfcName}/${diffIMageName}',
                  errorBuilder: (context, error, stackTrace) {
                    return Text('이미지 로딩 실패');
                  },
                ),
              ),
            ),
          ],
        );
      } catch (e) {
        return Container();
      }
    } else {
      return Container();
    }
  }

  Widget getProfileWidget() {
    List<Widget> list = [];

    var num = 0;
    dfcdetail.profile_list.toList().forEach((profile) {
      num++;
      list.add(
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'PROFILE   ${num}',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                SizedBox(width: 36),
                Text(
                  'head : ${profile.data.head}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(width: 36),
                Text(
                  'headgroup : ${profile.data.headgroup}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(width: 36),
                Text(
                  'cal_a : ${profile.data.cal_a}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(width: 36),
                Text(
                  'cal_b : ${profile.data.cal_b}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            if (profile.image.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('image', style: Theme.of(context).textTheme.bodyLarge),
                  getImageWidget(profile.image),
                ],
              ),
          ],
        ),
      );
    });

    return Column(children: list);
  }

  Widget getScan2dWidget() {
    List<Widget> list = [];

    var num = 0;
    dfcdetail.scan2d_list.toList().forEach((scan2d) {
      num++;
      list.add(
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'SCAN2D   ${num}',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                SizedBox(width: 36),
                Text(
                  'head : ${dfcdetail.scan2d_list.isNotEmpty ? dfcdetail.scan2d_list[num - 1].data.head : ""}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(width: 36),
                Text(
                  'headgroup : ${dfcdetail.scan2d_list.isNotEmpty ? dfcdetail.scan2d_list[num - 1].data.headgroup : ""}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            if (dfcdetail.scan2d_list[num - 1].scan2d_image.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'scan2d_image',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  getImageWidget(dfcdetail.scan2d_list[num - 1].scan2d_image),
                ],
              ),
          ],
        ),
      );
    });

    return Column(children: list);
  }

  Widget getWipeWidget() {
    List<Widget> list = [];

    var num = 0;
    dfcdetail.wipe_list.toList().forEach((wipe) {
      num++;
      list.add(
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'WIPE   ${num}',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                SizedBox(width: 36),
                Text(
                  'head : ${wipe.data.head}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(width: 36),
                Text(
                  'headgroup : ${wipe.data.headgroup}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            if (wipe.wipe_image.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'wipe_image',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  getImageWidget(wipe.wipe_image),
                ],
              ),
            if (wipe.profile_image.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'profile_image',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  getImageWidget(wipe.profile_image),
                ],
              ),
          ],
        ),
      );
    });

    return Column(children: list);
  }

  Widget getWipe2Widget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('WIPE2', style: Theme.of(context).textTheme.headlineLarge),
            SizedBox(width: 36),
            Text(
              'headgroup : ${dfcdetail.scan2d_list.length > 0 ? dfcdetail.scan2d_list[0].data.headgroup : ""}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),

        if (dfcdetail.wipe2.h1_wipe_image.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'h1_wipe_image',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              getImageWidget(dfcdetail.wipe2.h1_wipe_image),
            ],
          ),
        if (dfcdetail.wipe2.h1_profile_image.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'h1_profile_image',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              getImageWidget(dfcdetail.wipe2.h1_profile_image),
            ],
          ),
        if (dfcdetail.wipe2.h2_wipe_image.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'h2_wipe_image',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              getImageWidget(dfcdetail.wipe2.h2_wipe_image),
            ],
          ),
        if (dfcdetail.wipe2.h2_profile_image.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'h2_profile_image',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              getImageWidget(dfcdetail.wipe2.h2_profile_image),
            ],
          ),
      ],
    );
  }

  List<Widget> getDfcListWidget() {
    List<Widget> list = [];

    dfclist.asMap().forEach((index, dfc) {
      list.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TxtBtn(
                  text: '${dfc.dfc_id}, ${dfc.event_time}',
                  bgcolor: selDfcId == dfc.dfc_id
                      ? Colors.green
                      : Colors.green.shade200,
                  onPressed: () {
                    setState(() {
                      selDfcId = dfc.dfc_id;
                      selDfcName = "dfc_${dfc.event_time.replaceAll('-', '')}";
                      selBaselineDfcId = 0;
                      dfcdetail = DfcDetail();
                    });
                  },
                ),
                if (selDfcId == dfc.dfc_id)
                  Row(
                    children: [
                      hsb.sss,
                      TxtBtn(
                        width: 56,
                        text: 'show ›',
                        bgcolor: Colors.green,
                        onPressed: () {
                          _showDetails();
                        },
                      ),
                    ],
                  ),
              ],
            ),

            vsb.sss,
          ],
        ),
      );
    });

    return list;
  }

  List<Widget> getBaselineListWidget() {
    List<Widget> list = [];
    baselinelast = Dfc();

    baselinelist.asMap().forEach((index, baseline) {
      if (baseline.is_base) {
        baselinelast = baseline;
      }
      list.add(
        Column(
          children: [
            Row(
              children: [
                TxtBtn(
                  text: '${baseline.dfc_id}, ${baseline.event_time}',
                  bgcolor: selBaselineDfcId == baseline.dfc_id
                      ? Colors.red
                      : Colors.indigo.shade100,
                  onPressed: () async {
                    setState(() {
                      selBaselineDfcId = baseline.dfc_id;
                      _getBaseline();
                    });
                  },
                ),
                if (selBaselineDfcId == baseline.dfc_id)
                  Row(
                    children: [
                      hsb.sss,
                      TxtBtn(
                        width: 56,
                        text: 'set ›',
                        bgcolor: Colors.red,
                        onPressed: () async {
                          _saveHostInfo();

                          if (_editDjangoHost.text.isEmpty ||
                              _editApacheHost.text.isEmpty) {
                            await Future.delayed(Duration(milliseconds: 1500));
                          }

                          if (!isUriValid) return;

                          setState(() {
                            _showProgress = true;
                          });
                          try {
                            final dio = Dio()..options.baseUrl = apiBaseUrl;

                            var response = await dio.post(
                              selHttp == 'https'
                                  ? '/server/dbapps/'
                                  : '/dfc/baselineregist/',
                              data: {
                                'model_id': 'TX-101',
                                'tool': '${selSerialNo}',
                                'series_id': 'IAP',
                                'start_time': '2025-01-01 01:01:01',
                                'end_time': '2025-08-01 01:01:01',
                                'user_id': 'cannon',
                                'dfc_id': selBaselineDfcId,
                                'db_api_name': 'dfc/baselineregist',
                              },
                            );

                            var responseMap = response.data;

                            setState(() {
                              processResponseData(responseMap);
                              baselineregistresult = Dfc();
                              var result = selHttp == 'https'
                                  ? responseMap['data']
                                  : responseMap['content']['data'];
                              setState(() {
                                baselineregistresult = Dfc.fromJson(result);
                              });
                            });
                            setState(() {
                              _showProgress = false;
                            });
                          } catch (ex) {
                            print(ex);
                            setState(() {
                              _showProgress = false;
                            });
                          }

                          _getBaseline();
                        },
                      ),
                      Icon(Icons.arrow_right, size: 10),
                    ],
                  ),
              ],
            ),
            vsb.sss,
          ],
        ),
      );
    });

    return list;
  }

  Dio diohttp() {
    var dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: Duration(microseconds: 4000),
        receiveTimeout: Duration(microseconds: 15000),
        headers: <String, String>{
          //'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
    );
    // //check bad certificate
    // (dio!.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //     (HttpClient client) {
    //       client.badCertificateCallback =
    //           (X509Certificate cert, String host, int port) => true;
    //       return client;
    //     };

    // dio.interceptors.addAll({
    //   AppInterceptors(dio),
    // });
    return dio;
  }
}

class TxtBtn extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Color bgcolor;
  final String text;
  final VoidCallback onPressed;

  const TxtBtn({
    Key? key,
    this.width = 130,
    this.height = 30,
    this.color = Colors.white,
    this.bgcolor = Colors.blue,
    this.text = 'TEXT',

    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: bgcolor,
          padding: EdgeInsets.all(2),
        ),
        onPressed: onPressed,
        child: Text(text, style: TextStyle(color: color)),
      ),
    );
  }
}
