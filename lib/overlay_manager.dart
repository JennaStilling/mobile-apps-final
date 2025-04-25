import 'game.dart';
import 'main_menu.dart';
import 'player_hud.dart';
import 'game_over.dart';
import 'victory_screen.dart';

// AI Help - concept of overlays to use instead of the Navigator (helped with game flow mindset), similar to flow I use in Unity
class OverlayKeys {
  static const String mainMenu = 'main_menu';
  static const String gameHud = 'game_hud';
  static const String gameOver = 'game_over';
  static const String victory = 'victory';
}

class OverlayManager {
  final SpaceInvaders game;

  OverlayManager(this.game);

  void registerOverlays() {
    game.overlays.addEntry(
      OverlayKeys.mainMenu,
      (context, game) => MainMenu(game: game as SpaceInvaders),
    );

    game.overlays.addEntry(
      OverlayKeys.gameHud,
      (context, game) => PlayerHUD(game: game as SpaceInvaders),
    );

    game.overlays.addEntry(
      OverlayKeys.gameOver,
      (context, game) => GameOver(game: game as SpaceInvaders),
    );

    game.overlays.addEntry(
      OverlayKeys.victory,
      (context, game) => VictoryScreen(game: game as SpaceInvaders),
    );
  }

  void showMainMenu() {
    game.overlays.remove(OverlayKeys.gameHud);
    game.overlays.remove(OverlayKeys.gameOver);
    game.overlays.remove(OverlayKeys.victory);
    game.overlays.add(OverlayKeys.mainMenu);
  }

  void showGamePlay() {
    game.overlays.remove(OverlayKeys.mainMenu);
    game.overlays.remove(OverlayKeys.gameOver);
    game.overlays.remove(OverlayKeys.victory);
    game.overlays.add(OverlayKeys.gameHud);
  }

  void showGameOver() {
    game.overlays.add(OverlayKeys.gameOver);
  }

  void showVictory() {
    game.overlays.add(OverlayKeys.victory);
  }
}
