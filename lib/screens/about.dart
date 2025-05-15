import 'package:flutter/material.dart';
import 'package:tapit/constants/asset_constants.dart';
import 'package:tapit/constants/string_constants.dart';
import 'package:tapit/services/native.dart';

class About extends StatefulWidget {
  const About({super.key});
  static const String routeName = '/about';

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  AppInfo appInfo = AppInfo(appName: '', version: '');

  @override
  void initState() {
    super.initState();
    NativeService.getAppInfo().then((value) {
      setState(() {
        appInfo = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(StringConstants.about),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 50,
          children: [
            Image.asset(
              AssetConstants.builtWithFlutter,
              width: 200,
            ),
            Column(
              spacing: 10,
              children: [
                if (appInfo.appName.isNotEmpty)
                  Text(
                    appInfo.appName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                    ),
                  ),
                if (appInfo.version.isNotEmpty)
                  Text(
                    "Version ${appInfo.version}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    showLicensePage(
                      context: context,
                      applicationName: appInfo.appName,
                      applicationVersion: appInfo.version,
                      applicationIcon: Image.asset(
                        AssetConstants.appIcon,
                        height: 50,
                      ),
                    );
                  },
                  child: Text(
                    "Licences",
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
