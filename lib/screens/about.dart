import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';


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
            Text('Made with', style: GoogleFonts.lato(
              fontSize: 22
            ),),
            const SizedBox(width: 10,),
            Tooltip(
              message: 'Flutter',
              child: Image.asset('assets/icon/icon_flutter.png', width: 30,
              ),
            )
          ],
        ),
      ),
    );
  }
}