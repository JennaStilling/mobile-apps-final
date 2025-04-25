import 'package:flutter/material.dart';
import 'game.dart';
import 'overlay_base.dart';

class PlayerHUD extends OverlayBase {
  const PlayerHUD({required SpaceInvaders game, Key? key})
      : super(game: game, key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ValueListenableBuilder<int>(
                  valueListenable: game.score,
                  builder: (context, value, child) {
                    return Text(
                      'SCORE: $value',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Korataki',
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ValueListenableBuilder<int>(
                  valueListenable: game.playerLives,
                  builder: (context, lives, child) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'LIVES: $lives',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Korataki',
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
