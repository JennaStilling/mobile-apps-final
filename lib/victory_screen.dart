import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async';
import 'game.dart';
import 'overlay_base.dart';

class VictoryScreen extends OverlayBase {
  const VictoryScreen({required SpaceInvaders game, Key? key})
      : super(game: game, key: key);

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 4), () {
      game.returnToMainMenu();
    });

    return Center(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Stack(
          children: [
            SizedBox.expand(
              child: RiveAnimation.asset(
                "assets/animations/win-screen.riv",
                artboard: "Artboard",
                animations: const ["Timeline 1"],
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
