import 'dart:async';

import 'package:flutter/material.dart';

/// A custom animated hint text field widget that rotates through a list of hint texts.
///
/// This widget provides an animated text field where the hint text cycles through a list of hints with fade and slide animations.
/// It supports various customization options for text appearance, text field borders, and animation effects.
///
/// **Example Usage:**
/// ```dart
/// AnimatedHintTextField(
///   controller: _controller,
///   hintTexts: ['Hint 1', 'Hint 2', 'Hint 3'],
/// )
/// ```
///
/// **Properties:**
/// - [controller]: A [TextEditingController] to manage the text field input.
/// - [hintTexts]: A list of strings to be used as hint texts. The widget will cycle through them with animation.
/// - [animationDuration]: Duration of the animation for switching hint texts (default is 500 ms).
/// - [switchDuration]: Duration for how long each hint text is displayed before switching (default is 2 seconds).
/// - [style]: The style for the text input (optional).
/// - [hintStyle]: The style for the hint text (optional).
/// - [hintTextColor]: The color of the hint text (optional).
/// - [focusedBorderColor]: The border color when the text field is focused (optional).
/// - [unfocusedBorderColor]: The border color when the text field is not focused (optional).
/// - [borderRadius]: The radius of the text field's border (default is 8.0).
/// - [decoration]: Custom decoration for the text field (optional).
/// - [maxLines]: The maximum number of lines for the text field (default is 1).
/// - [minLines]: The minimum number of lines for the text field (default is 1).
/// - [hintAlignment]: The alignment of the hint text inside the text field (default is [Alignment.centerLeft]).
/// - [contentPadding]: Padding inside the text field (default is [EdgeInsets.all(12.0)]).
/// - [enableAnimation]: Whether to enable hint text animation (default is true).
/// - [animationCurve]: The curve for the animation (default is [Curves.easeInOut]).
class AnimatedHintTextField extends StatefulWidget {
  /// Creates an [AnimatedHintTextField] widget with the provided properties.
  const AnimatedHintTextField({
    required this.controller,
    required this.hintTexts,
    this.animationDuration = const Duration(milliseconds: 500),
    this.switchDuration = const Duration(seconds: 2),
    this.style,
    this.hintStyle,
    this.hintTextColor,
    this.focusedBorderColor,
    this.unfocusedBorderColor,
    this.borderRadius = 8.0,
    this.decoration,
    this.maxLines = 1,
    this.minLines = 1,
    this.hintAlignment = Alignment.centerLeft,
    this.contentPadding = const EdgeInsets.all(12.0),
    this.enableAnimation = true,
    this.animationCurve = Curves.easeInOut,
    this.focusNode,
    this.hintPadding,
    this.onTapOutside,
    super.key,
  });

  /// The curve for the animation.
  final Curve animationCurve;

  /// The duration of the animation for switching between hint texts.
  final Duration animationDuration;

  /// The border radius of the text field.
  final double borderRadius;

  /// The padding for the content inside the text field.
  final EdgeInsetsGeometry contentPadding;

  /// The controller for managing the text field input.
  final TextEditingController controller;

  /// The decoration for the text field.
  final InputDecoration? decoration;

  /// Whether to enable the animation for switching hint texts.
  final bool enableAnimation;

  /// The focus node for the text field.
  final FocusNode? focusNode;

  /// The color of the border when the text field is focused.
  final Color? focusedBorderColor;

  /// The alignment of the hint text within the text field.
  final Alignment hintAlignment;

  /// The padding for the hint text.
  final EdgeInsetsGeometry? hintPadding;

  /// The style for the hint text.
  final TextStyle? hintStyle;

  /// The color of the hint text.
  final Color? hintTextColor;

  /// The list of hint texts to rotate through.
  final List<String> hintTexts;

  /// The maximum number of lines for the text field.
  final int maxLines;

  /// The minimum number of lines for the text field.
  final int minLines;

  /// Callback function to be triggered when tapping outside the text field.
  final VoidCallback? onTapOutside;

  /// The style for the text field's text.
  final TextStyle? style;

  /// The duration for how long each hint text is displayed before switching.
  final Duration switchDuration;

  /// The color of the border when the text field is not focused.
  final Color? unfocusedBorderColor;

  @override
  _AnimatedHintTextFieldState createState() => _AnimatedHintTextFieldState();
}

class _AnimatedHintTextFieldState extends State<AnimatedHintTextField>
    with SingleTickerProviderStateMixin {
  // Animation controller for the hint text animations.
  late AnimationController _animController;

  // Notifier for the current index of the hint text.
  ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);

  // Whether a custom focus node is provided.
  bool _customFocusNode = false;

  // Fade in animation for the hint text.
  late Animation<double> _fadeInAnimation;

  // Fade out animation for the hint text.
  late Animation<double> _fadeOutAnimation;

  // Focus node for the text field.
  late FocusNode _focusNode;

  // Notifier for whether the user is typing in the text field.
  ValueNotifier<bool> _isTypingNotifier = ValueNotifier<bool>(false);

  // Slide in animation for the hint text.
  late Animation<Offset> _slideInAnimation;

  // Slide out animation for the hint text.
  late Animation<Offset> _slideOutAnimation;

  // Timer to periodically switch hint texts.
  late Timer _switchTimer;

  @override
  void dispose() {
    _switchTimer.cancel();
    _animController.dispose();
    _currentIndexNotifier.dispose();
    _isTypingNotifier.dispose();
    if (!_customFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _customFocusNode = widget.focusNode != null;
    _focusNode = widget.focusNode ?? FocusNode();

    _animController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.0, 0.5)),
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.5, 1.0)),
    );
    _slideOutAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.5),
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.5),
    ));
    _slideInAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.5, 1.0),
    ));

    _switchTimer = Timer.periodic(widget.switchDuration, (_) {
      if (!_isTypingNotifier.value && !_focusNode.hasFocus) {
        _animateToNextHint();
      }
    });

    widget.controller.addListener(() {
      _isTypingNotifier.value = widget.controller.text.isNotEmpty;
    });

    _focusNode.addListener(() => setState(() {}));
  }

  /// Animates to the next hint text in the list.
  void _animateToNextHint() {
    int nextIndex = (_currentIndexNotifier.value + 1) % widget.hintTexts.length;
    if (widget.enableAnimation) {
      _animController.forward().then((_) {
        _currentIndexNotifier.value = nextIndex;
        _animController.reset();
      });
    } else {
      _currentIndexNotifier.value = nextIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          style: widget.style,
          onTapOutside: (event) {
            widget.onTapOutside
                ?.call(); // Call the external onTapOutside callback
            _focusNode.unfocus();
          },
          decoration: widget.decoration ??
              InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: widget.unfocusedBorderColor ?? Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: widget.focusedBorderColor ?? Colors.blue,
                  ),
                ),
                contentPadding: widget.contentPadding,
              ),
        ),
        if (!_focusNode.hasFocus)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              child: Align(
                alignment: widget.hintAlignment,
                child: ValueListenableBuilder<int>(
                  valueListenable: _currentIndexNotifier,
                  builder: (context, currentIndex, _) {
                    return ValueListenableBuilder<bool>(
                      valueListenable: _isTypingNotifier,
                      builder: (context, isTyping, _) {
                        if (isTyping) return const SizedBox.shrink();
                        return Stack(
                          children: [
                            SlideTransition(
                              position: _slideOutAnimation,
                              child: FadeTransition(
                                opacity: _fadeOutAnimation,
                                child: Padding(
                                  padding:
                                      widget.hintPadding ?? EdgeInsets.zero,
                                  child: Text(
                                    widget.hintTexts[currentIndex],
                                    style: widget.hintStyle?.copyWith(
                                          color: widget.hintTextColor ??
                                              Colors.grey,
                                        ) ??
                                        TextStyle(
                                          color: widget.hintTextColor ??
                                              Colors.grey,
                                          fontSize: 16,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            SlideTransition(
                              position: _slideInAnimation,
                              child: FadeTransition(
                                opacity: _fadeInAnimation,
                                child: Padding(
                                  padding:
                                      widget.hintPadding ?? EdgeInsets.zero,
                                  child: Text(
                                    widget.hintTexts[(currentIndex + 1) %
                                        widget.hintTexts.length],
                                    style: widget.hintStyle?.copyWith(
                                          color: widget.hintTextColor ??
                                              Colors.grey,
                                        ) ??
                                        TextStyle(
                                          color: widget.hintTextColor ??
                                              Colors.grey,
                                          fontSize: 16,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
