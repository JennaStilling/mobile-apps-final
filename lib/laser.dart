import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import 'game.dart';
import 'reaper.dart';
import 'player.dart';

class Laser extends SpriteComponent
    with HasGameReference<SpaceInvaders>, CollisionCallbacks {
  static const double speed = 500.0;

  final int direction;
  final bool isPlayerLaser;

  Laser({
    required Vector2 position,
    this.direction = 1,
    this.isPlayerLaser = true,
  }) : super(
          position: position,
          size: Vector2(40, 40),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('laser.png');

    size = Vector2(
      game.size.x * 0.01,
      game.size.y * 0.03,
    );

    add(RectangleHitbox()..collisionType = CollisionType.active);
  }

  @override
  void update(double dt) {
    super.update(dt);

    double scaledSpeed = speed * game.screenHeightFactor;
    position.y -= direction * scaledSpeed * dt;

    if (position.y < 0 || position.y > game.size.y) {
      removeFromParent();
      if (isPlayerLaser) {
        game.canFire = true;
      }
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (isPlayerLaser && other is Enemy) {
      game.onEnemyDefeated();
      other.removeFromParent();
      removeFromParent();
      game.canFire = true;
    } else if (!isPlayerLaser && other is Player) {
      game.onPlayerHit();
      removeFromParent();
    }
  }
}
