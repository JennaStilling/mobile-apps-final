import 'package:flutter/material.dart';
import 'game.dart';

abstract class OverlayBase extends StatelessWidget {
  final SpaceInvaders game;

  const OverlayBase({
    required this.game,
    Key? key,
  }) : super(key: key);
}
