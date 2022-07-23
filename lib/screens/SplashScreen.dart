import 'package:woobox/screens/DashBoardScreen.dart';
import 'package:woobox/utils/constants.dart';
import 'package:woobox/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../app_localizations.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await Future.delayed(Duration(seconds: 2));
    checkFirstSeen();
  }

  Future checkFirstSeen() async {
    int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
    if (themeModeIndex == ThemeModeSystem) {
      appStore.setDarkMode(
          aIsDarkMode:
              MediaQuery.of(context).platformBrightness == Brightness.dark);
    }

    DashBoardScreen().launch(context, isNewTask: true);

    // bool _seen = (getBoolAsync('seen', defaultValue: false));
    // if (_seen) {
    //   DashBoardScreen().launch(context, isNewTask: true);
    // } else {
    //   await setValue('seen', true);
    //   WalkThroughScreen().launch(context, isNewTask: true);
    // }
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(splash, width: 110, height: 110, fit: BoxFit.cover),
            10.height,
            Text(appLocalization.translate('app_name')!,
                style: boldTextStyle(
                    color: Theme.of(context).textTheme.subtitle2!.color,
                    size: 26)),
          ],
        ).center(),
      ),
    );
  }
}
