import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedHintTextField extends StatefulWidget {
  final TextEditingController controller;
  final List<String> hintTexts;
  final Duration animationDuration;
  final Duration switchDuration;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final Color? hintTextColor;
  final Color? focusedBorderColor;
  final Color? unfocusedBorderColor;
  final double borderRadius;
  final InputDecoration? decoration;
  final int maxLines;
  final int minLines;
  final Alignment hintAlignment;
  final EdgeInsetsGeometry contentPadding;
  final bool enableAnimation;
  final Curve animationCurve;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry?
      hintPadding; // Add hintPadding for hint text padding
  final VoidCallback? onTapOutside; // Add onTapOutside callback

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
    this.hintPadding, // Initialize hintPadding
    this.onTapOutside, // Initialize onTapOutside
    super.key,
  });

  @override
  _AnimatedHintTextFieldState createState() => _AnimatedHintTextFieldState();
}

class _AnimatedHintTextFieldState extends State<AnimatedHintTextField>
    with SingleTickerProviderStateMixin {
  late Timer _switchTimer;
  late AnimationController _animController;
  late Animation<double> _fadeOutAnimation;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideOutAnimation;
  late Animation<Offset> _slideInAnimation;

  ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
  ValueNotifier<bool> _isTypingNotifier = ValueNotifier<bool>(false);
  late FocusNode _focusNode;
  bool _customFocusNode = false;

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
  void dispose() {
    _switchTimer.cancel();
    _animController.dispose();
    _currentIndexNotifier.dispose();
    _isTypingNotifier.dispose();
    if (!_customFocusNode) _focusNode.dispose();
    super.dispose();
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
