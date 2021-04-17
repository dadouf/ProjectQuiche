import 'package:flutter/material.dart';

class Spinning extends StatefulWidget {
  final Widget child;

  const Spinning({Key? key, required this.child}) : super(key: key);

  @override
  _SpinningState createState() => _SpinningState();
}

class _SpinningState extends State<Spinning> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 1000),
    vsync: this,
  )..repeat();

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: widget.child,
    );
  }
}
