import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'dart:async';
import 'dart:math' as math;

import 'game.dart';
import 'player.dart';
import 'laser.dart';

class Enemy extends SpriteComponent
    with HasGameReference<SpaceInvaders>, CollisionCallbacks {
  late Timer _laserTimer;
  late Timer _preFireTimer;
  int _bulletsRemaining = 0;
  static const int _maxBurstCount = 4;
  static const double _bulletDelay = 0.25;
  static const double _preFireDelay = 0.5;

  late Sprite _normalSprite;
  late Sprite _firingSprite;
  bool _isFiring = false;

  Enemy({
    super.position,
  }) : super(
          size: Vector2(200, 250),
          anchor: Anchor.center,
        ) {
    _laserTimer = Timer(
      _bulletDelay,
      onTick: _fireSingleLaser,
      repeat: true,
    );

    _preFireTimer = Timer(
      _preFireDelay,
      onTick: _startFiring,
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _normalSprite = await game.loadSprite('reaper-i-hardly-know-her.png');

    try {
      _firingSprite = await game.loadSprite('reaper-fire.png');
    } catch (e) {
      _firingSprite = _normalSprite;
    }

    sprite = _normalSprite;

    size = Vector2(
      game.size.x * 0.1,
      game.size.y * 0.12,
    );

    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (position.y > game.size.y) {
      removeFromParent();
    }

    if (_preFireTimer.isRunning()) {
      _preFireTimer.update(dt);
    }
    if (_bulletsRemaining > 0) {
      _laserTimer.update(dt);
    }
  }

  void fireRapidBurst() {
    if (_isFiring) return;

    _isFiring = true;

    sprite = _firingSprite;

    _preFireTimer = Timer(
      _preFireDelay,
      onTick: _startFiring,
    );
    _preFireTimer.start();
  }

  void _startFiring() {
    _bulletsRemaining = _maxBurstCount;

    _laserTimer.stop();
    _laserTimer = Timer(
      _bulletDelay,
      onTick: _fireSingleLaser,
      repeat: true,
    );

    _fireSingleLaser();

    if (_bulletsRemaining > 0) {
      _laserTimer.start();
    }
  }

  void _fireSingleLaser() {
    if (_bulletsRemaining <= 0) return;

    final randomOffset =
        (math.Random().nextDouble() - 0.5) * game.size.x * 0.03;

    final laser = Laser(
      position: Vector2(position.x + randomOffset, position.y + height / 2),
      direction: -1,
      isPlayerLaser: false,
    );

    game.add(laser);

    _bulletsRemaining--;

    if (_bulletsRemaining <= 0) {
      _laserTimer.stop();

      sprite = _normalSprite;
      _isFiring = false;
    }
  }

  void fireBeam() {
    fireRapidBurst();
  }

  @override
  void onRemove() {
    super.onRemove();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Laser && other.isPlayerLaser) {
      removeFromParent();
      other.removeFromParent();

      game.onEnemyDefeated();
    } else if (other is Player) {
      game.onPlayerHit();
    }
  }
}
