import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'player.dart';
import 'reaper.dart';
import 'overlay_manager.dart';

enum GameState { mainMenu, playing, gameOver, victory }

class SpaceInvaders extends FlameGame
    with PanDetector, TapDetector, HasCollisionDetection {
  late Player player;
  bool canFire = true;

  GameState _state = GameState.mainMenu;
  GameState get state => _state;

  late final OverlayManager overlayManager;

  // AI Help - scaling factors due to varying screen sizes
  late double screenWidthFactor;
  late double screenHeightFactor;

  // Tested on desktop first
  static const double referenceWidth = 1920.0;
  static const double referenceHeight = 1080.0;

  // AI Help - value notifiers explanation
  final ValueNotifier<int> score = ValueNotifier<int>(0);
  final ValueNotifier<int> playerLives = ValueNotifier<int>(3);

  // AI Help - logic of screen boundaries (setting as late since window isn't initialized yet)
  late double _topBounds;
  late double _bottomBounds;
  late double _leftBounds;
  late double _rightBounds;

  bool _reapersSpawned = false;
  bool _movingRight = true;
  final double _baseReaperSpeed = 100.0;
  final double _minReaperSpeed = 30.0;
  late double _reaperSpeed;
  late double _yReaperAmt;

  // AI Help - timer class (used throughout project)
  Timer? _reaperTimer;
  final double _reaperFireRate = 0.45;

  SpaceInvaders() {
    overlayManager = OverlayManager(this);
  }

  @override
  Future<void> onLoad() async {
    overlayManager.registerOverlays();
    overlayManager.showMainMenu();

    screenWidthFactor = size.x / referenceWidth;
    screenHeightFactor = size.y / referenceHeight;

    _topBounds = size.y * 0.85;
    _bottomBounds = size.y;
    _leftBounds = 0;
    _rightBounds = size.x;
    _yReaperAmt = size.y * 0.025;

    _reaperSpeed =
        math.max(_baseReaperSpeed * screenWidthFactor, _minReaperSpeed);
  }

  void startGame() {
    _state = GameState.playing;
    resetGame();
    overlayManager.showGamePlay();
    resumeEngine();
  }

  void gameOver() {
    _state = GameState.gameOver;
    overlayManager.showGameOver();
    removeGameComponents();
    pauseEngine();
  }

  void victory() {
    _state = GameState.victory;
    overlayManager.showVictory();
    removeGameComponents();
    pauseEngine();
  }

  void returnToMainMenu() {
    _state = GameState.mainMenu;
    overlayManager.showMainMenu();
    removeGameComponents();
    pauseEngine();
  }

  void resetGame() {
    score.value = 0;
    canFire = true;
    playerLives.value = 3;
    _reapersSpawned = false;

    removeGameComponents();

    loadSprite('background.png').then((background) {
      add(SpriteComponent(
        sprite: background,
        size: size,
        priority: -1,
      ));
    });

    player = Player();
    add(player);

    // Based off sketch, hardcoded based off an imaginary 3x11 grid
    final positions = [
      [1, 0],
      [0, 1],
      [1, 2],
      [1, 4],
      [2, 5],
      [1, 6],
      [1, 8],
      [0, 9],
      [1, 10],
    ];

    final columnSpacing = size.x / 12;
    final rowSpacing = size.y * 0.05;
    final startY = size.y * 0.05;

    for (final pos in positions) {
      final row = pos[0];
      final col = pos[1];

      final enemy = Enemy();
      enemy.position = Vector2(
        columnSpacing * (col + 0.5),
        startY + row * rowSpacing,
      );

      add(enemy);
    }
    _reapersSpawned = true;

    _reaperTimer = Timer(
      2.0,
      onTick: _reaperShooting,
      repeat: true,
    );
  }

  void _reaperShooting() {
    if (_state == GameState.playing) {
      final reapers = children.whereType<Enemy>().toList();

      if (reapers.isNotEmpty) {
        for (final reaper in reapers) {
          if (math.Random().nextDouble() < _reaperFireRate) {
            reaper.fireBeam();
          }
        }
      }
    }
  }

  void removeGameComponents() {
    final componentsToRemove = children
        .where((component) =>
            component is! SpriteComponent || component.priority != -1)
        .toList();

    for (final component in componentsToRemove) {
      remove(component);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_state == GameState.playing && _reapersSpawned) {
      final reapers = children.whereType<Enemy>().toList();

      if (reapers.isNotEmpty) {
        bool atEdge = false;
        final moveAmount = _reaperSpeed * dt * (_movingRight ? 1 : -1);

        for (final reaper in reapers) {
          final newX = reaper.position.x + moveAmount;
          final edgeMargin = reaper.width / 2;
          if (newX < edgeMargin || newX > size.x - edgeMargin) {
            atEdge = true;
            break;
          }
        }

        if (!atEdge) {
          for (final reaper in reapers) {
            reaper.position.x += moveAmount;
          }
        } else {
          _movingRight = !_movingRight;

          for (final reaper in reapers) {
            reaper.position.y += _yReaperAmt;
            if (reaper.position.y >= _bottomBounds) {
              gameOver();
              return;
            }
          }
        }
      }
    }

    if (children.whereType<Enemy>().isEmpty &&
        _state == GameState.playing &&
        _reapersSpawned) {
      victory();
    }

    if (_state == GameState.playing && _reaperTimer != null) {
      _reaperTimer!.update(dt);
    }
  }

  void onEnemyDefeated() {
    score.value += 10;

    if (children.whereType<Enemy>().isEmpty) {
      victory();
    }
  }

  void onPlayerHit() {
    playerLives.value--;

    if (playerLives.value <= 0) {
      gameOver();
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    final newPosition = player.position + info.delta.global;

    if (newPosition.y >= _topBounds &&
        newPosition.y <= _bottomBounds &&
        newPosition.x >= _leftBounds + player.width / 2 &&
        newPosition.x <= _rightBounds - player.width / 2) {
      player.move(info.delta.global);
    } else {
      Vector2 validDelta = Vector2.zero();

      if (newPosition.x >= _leftBounds + player.width / 2 &&
          newPosition.x <= _rightBounds - player.width / 2) {
        validDelta.x = info.delta.global.x;
      }

      if (newPosition.y >= _topBounds && newPosition.y <= _bottomBounds) {
        validDelta.y = info.delta.global.y;
      }

      if (validDelta != Vector2.zero()) {
        player.move(validDelta);
      }
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    player.fire();
  }

  @override
  void onPanStart(DragStartInfo info) {}

  @override
  void onPanEnd(DragEndInfo info) {}
}
