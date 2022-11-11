import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class About extends StatelessWidget {
  const About({super.key});
  static const String routeName = '/about';

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Tooltip(
              message: 'Flutter',
              child: Image.asset(
                'assets/icon/builtwithflutter.png',
                width: 200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}