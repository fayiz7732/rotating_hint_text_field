library rotating_hint_text_field;

import 'package:flutter/material.dart';
import 'package:rotating_hint_text_field/rotating_hint_text_field.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Animated Hint Text Field Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: AnimatedHintTextField(
              controller: TextEditingController(),
              hintTexts: [
                'Enter your name',
                'Enter your email',
                'Enter your password'
              ],
              hintStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              hintTextColor: Colors.blueAccent,
              focusedBorderColor: Colors.green,
              unfocusedBorderColor: Colors.red,
              enableAnimation: true,
              animationDuration: Duration(milliseconds: 500),
              switchDuration: Duration(seconds: 2),
              borderRadius: 12.0,
              maxLines: 1,
              minLines: 1,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onTapOutside: () {
                print('Tapped outside');
              },
            ),
          ),
        ),
      ),
    );
  }
}
