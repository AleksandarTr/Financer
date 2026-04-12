import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FrameTimingWidget extends StatefulWidget {
  final Widget child;

  const FrameTimingWidget({required this.child});

  @override
  State<FrameTimingWidget> createState() => _FrameTimingWidgetState();
}

class _FrameTimingWidgetState extends State<FrameTimingWidget> {
  late int _lastFrameTime;
  late int _tapTime;

  @override
  void initState() {
    super.initState();
    _lastFrameTime = DateTime.now().millisecondsSinceEpoch;
    
    // Track every frame
    SchedulerBinding.instance.addPersistentFrameCallback((timeStamp) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final frameDuration = now - _lastFrameTime;
      
      if (frameDuration > 16) {
        print('[FRAME] Slow frame detected: ${frameDuration}ms');
      }
      
      _lastFrameTime = now;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
