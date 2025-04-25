import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'game.dart';
import 'overlay_base.dart';

class MainMenu extends OverlayBase {
  const MainMenu({required SpaceInvaders game, Key? key})
      : super(game: game, key: key);

  @override
  Widget build(BuildContext context) {
    return VideoBackground(
      videoAsset: 'assets/videos/main_menu.mp4',
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Space Invaders',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Korataki',
                ),
                textAlign: TextAlign.right,
              ),
              const Text(
                '(Mass Effect Inspired)',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Korataki',
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                onPressed: () {
                  game.startGame();
                },
                child: const Text(
                  'Play',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontFamily: 'Korataki',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// AI Help - understanding and using the video background
class VideoBackground extends StatefulWidget {
  final String videoAsset;
  final Widget child;

  const VideoBackground({
    Key? key,
    required this.videoAsset,
    required this.child,
  }) : super(key: key);

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _controller = VideoPlayerController.asset(widget.videoAsset);
      await _controller.initialize();
      await _controller.setLooping(true);
      _controller.addListener(() {
        if (_controller.value.position >= _controller.value.duration &&
            !_controller.value.isPlaying) {
          _controller.seekTo(Duration.zero);
          _controller.play();
        }
      });
      await _controller.play();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing video player: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _isInitialized
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              )
            : Container(color: Colors.black),
        widget.child,
      ],
    );
  }
}
