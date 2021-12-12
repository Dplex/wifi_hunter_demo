import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:msp/config.dart';
import 'package:msp/services/particle_service.dart';
import 'package:msp/ui/component/map_painter.dart';
import 'package:tuple/tuple.dart';
import 'dart:developer' as developer;

class MapList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              colorFilter: ColorFilter.mode(mapOpacity, BlendMode.dstATop), image: mapImage.image, fit: BoxFit.fill)),
      child: const MapPaint(),
    );
  }
}

class MapPaint extends StatefulWidget {
  const MapPaint() : super();

  @override
  State<StatefulWidget> createState() => _MapPaintState();
}

class _MapPaintState extends State<MapPaint> with SingleTickerProviderStateMixin {
  final _key = GlobalKey();

  late Animation<double> _animation;
  late AnimationController _controller;
  List<Tuple4<double, double, double, double>> blockList = [];
  Tuple4<double, double, double, double>? currentBlock;
  List<Tuple2<double, double>> currentParticle = [const Tuple2(100, 200)];
  late ParticleService particleService;

  blockAdd(Offset position) {
    setCurrentEndOffset(position);
    if (currentBlock!.item1 > currentBlock!.item3) {
      currentBlock = Tuple4(currentBlock!.item3, currentBlock!.item4, currentBlock!.item1, currentBlock!.item2);
    }
    setState(() {
      blockList.add(currentBlock!);
      currentBlock = null;
    });
  }

  processCurrentParticle(Offset position) {
    particleService.getBlocks();
    final dx = position.dx;
    final dy = position.dy;
    for (Tuple2 particle in currentParticle) {
      if ((particle.item1 - dx).abs() + (particle.item2 - dy).abs() <= 20) {
        setState(() {
          currentParticle.remove(particle);
        });
        return;
      }
    }
    setState(() {
      currentParticle.add(Tuple2(dx, dy));
    });
  }

  setCurrentStartOffset(Offset position) {
    currentBlock = Tuple4(position.dx, position.dy, 0, 0);
  }

  setCurrentEndOffset(Offset position) {
    currentBlock = currentBlock!.withItem3(position.dx).withItem4(position.dy);
  }

  void animationListener() => setState(() {

  });

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animation = Tween<double>(begin: 4, end: 6).animate(_controller)
      ..addListener(animationListener)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.repeat();
        } else if (status == AnimationStatus.dismissed) _controller.forward();
      });
    _controller.forward();
    super.initState();
    BotToast.showLoading(duration: mapLoadDuration);
    Future.delayed((mapLoadDuration), () => particleService = ParticleService(_key, realImageSize, blockList));
  }

  @override
  void deactivate() {
    particleService.shutdown();
    super.deactivate();
  }

  @override
  void dispose() {

    if (_controller.isAnimating) {
      _controller.dispose();
      _animation.removeListener(animationListener);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        key: _key,
        onDoubleTapDown: (position) => processCurrentParticle(position.localPosition),
        onDoubleTap: () {},
        onLongPressStart: (position) => setCurrentStartOffset(position.localPosition),
        onLongPressMoveUpdate: (position) => {setCurrentEndOffset(position.localPosition)},
        onLongPressEnd: (position) => {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Confirm'),
                      actions: [
                        TextButton(
                            onPressed: () {
                              blockAdd(position.localPosition);
                              Navigator.of(context).pop();
                            },
                            child: const Text("Accept")),
                        TextButton(
                          onPressed: () {
                            currentBlock = null;
                            Navigator.of(context).pop();
                          },
                          child: const Text("Cancel"),
                        )
                      ],
                    );
                  })
            },
        child: CustomPaint(
          painter: MspPainter(_animation.value, blockList, currentBlock, currentParticle),
          // painter: MspPainter(5, blockList, currentBlock, currentParticle),
        ));
  }
}
