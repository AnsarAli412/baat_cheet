import 'package:baat_cheet/enum/meeting_flow.dart';
import 'package:baat_cheet/example_screen.dart';
import 'package:baat_cheet/home_screen/user_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common/util/app_color.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: HMSApp(),
    );
  }
}

class HMSApp extends StatelessWidget {
   HMSApp({Key? key}) : super(key: key);

  final ThemeData _darkTheme = ThemeData(
    bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: themeBottomSheetColor, elevation: 5),
    brightness: Brightness.dark,
    primaryColor: const Color.fromARGB(255, 13, 107, 184),
    scaffoldBackgroundColor: Colors.black,
    //colorScheme: ColorScheme(background: Colors.black),
  );

  final ThemeData _lightTheme = ThemeData(
    bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: themeDefaultColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5),
    primaryTextTheme: TextTheme(bodyLarge: TextStyle(color: themeSurfaceColor)),
    primaryColor: hmsdefaultColor,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    dividerColor: Colors.white54,
    //colorScheme: ColorScheme(background: Colors.white),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UserDetailScreen(
          meetingFlow: MeetingFlow.meeting),
     // home: ExampleScreen(),
      theme: _lightTheme,
      darkTheme: _darkTheme,
    );
  }

}


