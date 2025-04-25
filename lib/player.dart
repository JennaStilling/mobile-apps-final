import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import 'game.dart';
import 'laser.dart';

class Player extends SpriteComponent
    with HasGameReference<SpaceInvaders>, CollisionCallbacks {
  Player()
      : super(
          size: Vector2(100, 150),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    sprite = await game.loadSprite('player-ship.png');

    size = Vector2(
      game.size.x * 0.05,
      game.size.y * 0.08,
    );

    position = Vector2(game.size.x / 2, game.size.y * .85);

    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  void move(Vector2 delta) {
    position.add(delta);
  }

  void fire() {
    if (game.canFire) {
      final laser = Laser(
        position: Vector2(position.x, position.y - height / 2),
        direction: 1,
        isPlayerLaser: true,
      );
      game.add(laser);
      game.canFire = false;
    }
  }
}
