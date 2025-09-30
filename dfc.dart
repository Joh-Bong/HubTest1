import 'dart:convert';

import 'package:flutter/cupertino.dart';

double kTextScaleFactor = 1.0;

const List<Color> kIndicatorColorPrimary2 = const [
  Color.fromRGBO(255, 0, 17, 1),
  Color.fromRGBO(255, 238, 0, 1),
  Color.fromRGBO(0, 255, 13, 1),
  Color.fromRGBO(0, 238, 255, 1),
  Color.fromRGBO(0, 110, 255, 1),
  Color.fromRGBO(183, 0, 255, 1),
  Color.fromRGBO(255, 0, 119, 1),
  Color.fromRGBO(98, 0, 255, 1),
];

class pad {
  static final double o = 0.0;
  static final double ssss = 2.0 * kTextScaleFactor;
  static final double sss = 4.0 * kTextScaleFactor;
  static final double ss = 8.0 * kTextScaleFactor;
  static final double s = 12.0 * kTextScaleFactor;
  static final double m = 16.0 * kTextScaleFactor;
  static final double l = 24.0 * kTextScaleFactor;
  static final double ll = 30.0 * kTextScaleFactor;
  static final double lll = 36.0 * kTextScaleFactor;
  static final double llll = 48.0 * kTextScaleFactor;
  static final double lllll = 60.0 * kTextScaleFactor;
}

class vsb {
  static final SizedBox ssss = SizedBox(height: 2.0);
  static final SizedBox sss = SizedBox(height: 4.0);
  static final SizedBox ss = SizedBox(height: 8.0);
  static final SizedBox s = SizedBox(height: 12.0);
  static final SizedBox m = SizedBox(height: 16.0);
  static final SizedBox l = SizedBox(height: 24.0);
  static final SizedBox ll = SizedBox(height: 30.0);
  static final SizedBox lll = SizedBox(height: 36.0);
  static final SizedBox llll = SizedBox(height: 48.0);
  static final SizedBox lllll = SizedBox(height: 60.0);
}

class hsb {
  static final SizedBox ssss = SizedBox(width: 2.0);
  static final SizedBox sss = SizedBox(width: 4.0);
  static final SizedBox ss = SizedBox(width: 8.0);
  static final SizedBox s = SizedBox(width: 12.0);
  static final SizedBox m = SizedBox(width: 16.0);
  static final SizedBox l = SizedBox(width: 24.0);
  static final SizedBox ll = SizedBox(width: 30.0);
  static final SizedBox lll = SizedBox(width: 36.0);
  static final SizedBox llll = SizedBox(width: 48.0);
  static final SizedBox lllll = SizedBox(width: 60.0);
}

class Dfc {
  int dfc_id = 0;
  String event_time = '';
  String status = '';
  bool is_base = false;

  Dfc();

  Dfc.fromJson(Map<String, dynamic> json)
    : dfc_id = json['dfc_id'],
      event_time = json['event_time'],
      status = json.containsKey('status') ? json['status'] : '',
      is_base = json.containsKey('is_base') ? json['is_base'] : false;
}

class ProfileData {
  String head = '';
  String headgroup = '';
  String cal_a = '';
  String cal_b = '';

  ProfileData();

  ProfileData.fromJson(Map<String, dynamic> json)
    : head = json['head'].toString(),
      headgroup = json['headgroup'].toString(),
      cal_a = json.containsKey('cal_a') ? json['cal_a'].toString() : '',
      cal_b = json.containsKey('cal_b') ? json['cal_b'].toString() : '';
}

class Profile {
  String image = '';
  ProfileData data = ProfileData();

  Profile();

  Profile.fromJson(Map<String, dynamic> json)
    : image = json['image'],
      data = ProfileData.fromJson(json['data']);
}

class Scan2dData {
  String head = '';
  String headgroup = '';

  Scan2dData();

  Scan2dData.fromJson(Map<String, dynamic> json)
    : head = json['head'].toString(),
      headgroup = json['headgroup'].toString();
}

class Scan2d {
  String scan2d_image = '';
  Scan2dData data = Scan2dData();

  Scan2d();

  Scan2d.fromJson(Map<String, dynamic> json)
    : scan2d_image = json['scan2d_image'],
      data = Scan2dData.fromJson(json['data']);
}

class WipeData {
  String head = '';
  String headgroup = '';

  WipeData();

  WipeData.fromJson(Map<String, dynamic> json)
    : head = json['head'].toString(),
      headgroup = json['headgroup'].toString();
}

class Wipe {
  String wipe_image = '';
  String profile_image = '';
  WipeData data = WipeData();

  Wipe();

  Wipe.fromJson(Map<String, dynamic> json)
    : wipe_image = json['wipe_image'],
      profile_image = json['profile_image'],
      data = WipeData.fromJson(json['data']);
}

class Wipe2Data {
  String headgroup = '';

  Wipe2Data();

  Wipe2Data.fromJson(Map<String, dynamic> json)
    : headgroup = json['headgroup'].toString();
}

class Wipe2 {
  String h1_wipe_image = '';
  String h1_profile_image = '';
  String h2_wipe_image = '';
  String h2_profile_image = '';
  Wipe2Data data = Wipe2Data();

  Wipe2();

  Wipe2.fromJson(Map<String, dynamic> json)
    : h1_wipe_image = json['h1_wipe_image'],
      h1_profile_image = json['h1_profile_image'],
      h2_wipe_image = json['h2_wipe_image'],
      h2_profile_image = json['h2_profile_image'],
      data = Wipe2Data.fromJson(json['data']);
}

class DfcDetail {
  List<Profile> profile_list = [];
  List<Scan2d> scan2d_list = [];
  List<Wipe> wipe_list = [];
  Wipe2 wipe2 = Wipe2();

  DfcDetail();

  DfcDetail.fromJson(Map<String, dynamic> json)
    : profile_list = json.containsKey('PROFILE')
          ? (json['PROFILE'] as List)
                .map((json) => Profile.fromJson(json))
                .toList()
          : [],
      scan2d_list = json.containsKey('SCAN2D')
          ? (json['SCAN2D'] as List)
                .map((json) => Scan2d.fromJson(json))
                .toList()
          : [],
      wipe_list = json.containsKey('WIPE')
          ? (json['WIPE'] as List).map((json) => Wipe.fromJson(json)).toList()
          : [],
      wipe2 = json.containsKey('WIPE2')
          ? Wipe2.fromJson(json['WIPE2'])
          : Wipe2();
}

Text txt410(String txt, Color color, [TextAlign? halign, bool? softwrap]) {
  return Text(
    txt,
    textScaleFactor: kTextScaleFactor,
    textAlign: halign == null ? TextAlign.start : halign,
    softWrap: softwrap != null ? softwrap : true,
    style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.w400, color: color),
  );
}

Text txt514(String txt, Color color, [TextAlign? halign, bool? softwrap]) {
  return Text(
    txt,
    textScaleFactor: kTextScaleFactor,
    textAlign: halign == null ? TextAlign.start : halign,
    softWrap: softwrap != null ? softwrap : true,
    style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: color),
  );
}

Text txt614(String txt, Color color, [TextAlign? halign, bool? softwrap]) {
  return Text(
    txt,
    textScaleFactor: kTextScaleFactor,
    textAlign: halign == null ? TextAlign.start : halign,
    softWrap: softwrap != null ? softwrap : true,
    style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: color),
  );
}

Text txt616(String txt, Color color, [TextAlign? halign, bool? softwrap]) {
  return Text(
    txt,
    textScaleFactor: kTextScaleFactor,
    textAlign: halign == null ? TextAlign.start : halign,
    softWrap: softwrap != null ? softwrap : true,
    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: color),
  );
}

Text txt618(String txt, Color color, [TextAlign? halign, bool? softwrap]) {
  return Text(
    txt,
    textScaleFactor: kTextScaleFactor,
    textAlign: halign == null ? TextAlign.start : halign,
    softWrap: softwrap != null ? softwrap : true,
    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: color),
  );
}

Text txt718(String txt, Color color, [TextAlign? halign, bool? softwrap]) {
  return Text(
    txt,
    textScaleFactor: kTextScaleFactor,
    textAlign: halign == null ? TextAlign.start : halign,
    softWrap: softwrap != null ? softwrap : true,
    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700, color: color),
  );
}

Text txt720(String txt, Color color, [TextAlign? halign, bool? softwrap]) {
  return Text(
    txt,
    textScaleFactor: kTextScaleFactor,
    textAlign: halign == null ? TextAlign.start : halign,
    softWrap: softwrap != null ? softwrap : true,
    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, color: color),
  );
}

Text txt722(String txt, Color color, [TextAlign? halign, bool? softwrap]) {
  return Text(
    txt,
    textScaleFactor: kTextScaleFactor,
    textAlign: halign == null ? TextAlign.start : halign,
    softWrap: softwrap != null ? softwrap : true,
    style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700, color: color),
  );
}

Text txt724(String txt, Color color, [TextAlign? halign, bool? softwrap]) {
  return Text(
    txt,
    textScaleFactor: kTextScaleFactor,
    textAlign: halign == null ? TextAlign.start : halign,
    softWrap: softwrap != null ? softwrap : true,
    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700, color: color),
  );
}

Text txt728(String txt, Color color, [TextAlign? halign, bool? softwrap]) {
  return Text(
    txt,
    textScaleFactor: kTextScaleFactor,
    textAlign: halign == null ? TextAlign.start : halign,
    softWrap: softwrap != null ? softwrap : true,
    style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700, color: color),
  );
}

Text txt740(String txt, Color color, [TextAlign? halign, bool? softwrap]) {
  return Text(
    txt,
    textScaleFactor: kTextScaleFactor,
    textAlign: halign == null ? TextAlign.start : halign,
    softWrap: softwrap != null ? softwrap : true,
    style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.w700, color: color),
  );
}
