import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeUtils {
  String getCurrentTheme() => "light";

  Map themes = {
    "light": {
      "primary": {
        "default": Color(0xff252b62),
        "light": Color(0xff535390),
        "dark": Color(0xff000037)
      },
      "grey": {
        "default": Color(0xff424242),
        "light": Color(0xff6d6d6d),
        "dark": Color(0xff1b1b1b)
      }
    },
    "dark": {
      "primary": {
        "default": Color(0xff4651ba),
        "light": Color(0xff7b7ded),
        "dark": Color(0xff002989)
      },
      "grey": {
        "default": Color(0xffeeeeee),
        "light": Color(0xffffffff),
        "dark": Color(0xffbcbcbc)
      }
    }
  };

  get theme => {themes[getCurrentTheme()]};
}

bool isDarkModeEnabled = false;

//Change notifier to deal with themes
class AppStateNotifier extends ChangeNotifier {
  bool isDarkMode = false;
  getTheme() => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void updateTheme(bool isDarkMode) {
    this.isDarkMode = isDarkMode;
    isDarkModeEnabled = isDarkMode;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor:
            isDarkModeEnabled ? Color(0xff414141) : Color(0xffF3F3F3),
        statusBarColor: Colors.transparent // navigation bar color
        // status bar color
        ));

    notifyListeners();
  }
}

// ThemeData darkTheme = ThemeData(
//     backgroundColor: Color(0xff313131),
//     primaryColor: Color(0xff414141),
//     primaryColorLight: Color(0xff525252),
//     //In reality that is primary ColorLighter
//     primaryColorDark: Color(0xff333333),
//     indicatorColor: Color(0xff525252),
//     tabBarTheme: TabBarTheme(labelColor: Colors.black));

// ThemeData lightTheme = ThemeData(
//     backgroundColor: Colors.white,
//     primaryColor: Color(0xffF3F3F3),
//     primaryColorDark: Color(0xffDCDCDC),
//     primaryColorLight: Colors.white,
//     indicatorColor: Color(0xffDCDCDC),
//     tabBarTheme: TabBarTheme(labelColor: Colors.black));

// // var tmp = c["primaryColor"]["d"];

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toCSSColor({bool leadingHashSign = true}) =>
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
