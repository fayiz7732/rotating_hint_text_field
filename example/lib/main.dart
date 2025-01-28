import 'package:flutter/foundation.dart';
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
            child: RotatingHintTextFieldWrapper(),
          ),
        ),
      ),
    );
  }
}

class RotatingHintTextFieldWrapper extends StatefulWidget {
  @override
  _RotatingHintTextFieldWrapperState createState() =>
      _RotatingHintTextFieldWrapperState();
}

class _RotatingHintTextFieldWrapperState
    extends State<RotatingHintTextFieldWrapper> {
  final _controller = TextEditingController();
  int _currentIndex = 0;
  final List<String> _hintTexts = [
    'Enter a message',
    '/ for quick action',
    'Start typing...'
  ];

  @override
  void initState() {
    super.initState();
    _startHintTextRotation();
  }

  void _startHintTextRotation() {
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _hintTexts.length;
      });
      _startHintTextRotation(); // Recursively rotate hint texts
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedHintTextField(
      controller: _controller,
      hintTexts: [_hintTexts[_currentIndex]],
      hintStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      hintTextColor: Colors.blueAccent,
      focusedBorderColor: Colors.green,
      unfocusedBorderColor: Colors.red,
      enableAnimation: true,
      borderRadius: 12.0,
      maxLines: 1,
      minLines: 1,
      hintPadding: EdgeInsets.only(left: 40),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.add_reaction_rounded),
        border: OutlineInputBorder(),
      ),
      onTapOutside: () {
        print('Tapped outside');
      },
    );
  }
}
