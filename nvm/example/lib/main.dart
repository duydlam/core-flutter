import 'package:example/model/index.dart';
import 'package:example/screens/flashScreen/index.dart';
import 'package:example/screens/homeScreen/index.dart';
import 'package:example/screens/loginScreen/index.dart';
import 'package:example/setup.dart';
import 'package:example/utils.dart';
import 'package:flutter/material.dart';
import 'package:nvm/nvm.dart';

import 'constants.dart';

void main() async {
  // init model for application
  Nvm app = Nvm.getInstance();
  app.global = AppModel();
  print(' Init model for application succeed. ');

  // setup all before started application
  await Future.wait(
      setupAll(app).map((fn) async => await Utils.getInstance().futureFn(fn)));

  String title = (app.global as AppModel).env[CONFIG_APP_NAME];
  bool mode = (app.global as AppModel).env[CONFIG_IS_DEBUG];
  Widget ownApp = AppWidget();
  print(' Init AppWidget succeed and START ===> ');

  runApp(MaterialApp(
    title: title,
    debugShowCheckedModeBanner: mode,
    home: ownApp,
  ));
}

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => NvmFutureBuilder(
        future: this._loadResource(context),
        loadingBuilder: (context) => FlashWidget(),
        errorBuilder: (context, error) {},
        successBuilder: (context, data) {
          if (data == true) return LoginWidget();
          return HomeWidget();
        },
      );

  Future<dynamic> _loadResource(context) async {
    return await Future.delayed(Duration(seconds: 10), () async {
      try {
        AppModel appModel = (Nvm.getInstance().global as AppModel);
        appModel.mediaQueryData = MediaQuery.of(context);

        String pathLocale =
            appModel.sharedPreferences.getString(CONFIG_STORE_LOCALE);

        if (pathLocale == null || pathLocale.isEmpty) {
          pathLocale = CONFIG_LOCALES_EN;
        }

        await Utils.getInstance().changeLocale(pathLocale);
        return true;
      } catch (e) {
        throw Exception('Load resource faild. Please try again!');
      }
    });
  }
}