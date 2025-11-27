import 'dart:async';
import 'package:flutter/material.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final VoidCallback onFinished;
  final Duration step;

  const TypewriterText({
    super.key,
    required this.text,
    required this.onFinished,
    this.step = const Duration(milliseconds: 30),
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  Timer? _timer;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.step, (t) {
      if (!mounted) return;
      setState(() {
        _count = (_count + 1).clamp(0, widget.text.length);
      });
      if (_count >= widget.text.length) {
        _timer?.cancel();
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = widget.text.substring(0, _count);
    return Text(visible, style: Theme.of(context).textTheme.bodyMedium);
  }
}