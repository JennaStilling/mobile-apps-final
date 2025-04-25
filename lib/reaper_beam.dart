// NOTE: THIS FILE IS NO LONGER USED DUE TO ISSUES WITH RENDERING
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'game.dart';
import 'player.dart';
import 'reaper.dart';

// AI Help - logic of drawing on the frames & style of beam
class ReaperBeam extends PositionComponent
    with HasGameReference<SpaceInvaders>, CollisionCallbacks {
  final Enemy parent;
  late Timer _decay;
  final double beamWidth = 20.0;
  final Color beamColor = Colors.red.withOpacity(0.8);
  bool reachedBottom = false;
  double maxLength = 0;

  ReaperBeam({required this.parent})
      : super(
          position:
              Vector2(parent.position.x, parent.position.y + parent.height / 2),
          anchor: Anchor.topCenter,
          priority: 10,
        ) {
    _decay = Timer(2.0, onTick: () {
      removeFromParent();
    });
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    height = 0;
    width = beamWidth;

    maxLength = game.size.y - position.y;

    add(RectangleHitbox(
      size: Vector2(beamWidth * 1.5, maxLength),
      position: Vector2(-(beamWidth * 0.25), 0),
    )..collisionType = CollisionType.active);
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.x = parent.position.x;

    if (!reachedBottom) {
      height += 1500 * dt;

      if (height >= maxLength) {
        height = maxLength;
        reachedBottom = true;
        _decay.start();
        _decay.start();
      }
    } else {
      _decay.update(dt);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final glowPaint = Paint()
      ..color = beamColor.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    canvas.drawRect(
      Rect.fromLTWH(-5, 0, width + 10, height),
      glowPaint,
    );

    final paint = Paint()
      ..color = beamColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      paint,
    );
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Player) {
      game.onPlayerHit();
      removeFromParent();
    }
  }
}
