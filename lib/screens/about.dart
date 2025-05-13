import 'package:flutter/material.dart';
import 'package:tapit/constants/asset_constants.dart';
import 'package:tapit/constants/string_constants.dart';


class About extends StatelessWidget {
  const About({super.key});
  static const String routeName = '/about';

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(StringConstants.about),
        elevation: 0,
      ),
      body: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AssetConstants.builtWithFlutter,
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
}