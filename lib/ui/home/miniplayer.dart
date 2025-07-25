import 'package:flutter/material.dart';
import 'package:music/data/model/song.dart';
import 'package:music/ui/now_playing/audio_player_manager.dart';
import 'package:music/ui/now_playing/playing.dart';

class MiniPlayer extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const MiniPlayer({super.key, required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8), // Để tránh bị sát viền màn hình
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(12), // Bo cong các góc MiniPlayer
        ),
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12), // Bo góc ảnh (nhỏ hơn 1 chút)
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/img.png',
                image: song.image,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                song.title + " " + song.artist,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              child: MediaButtonControl(
                function: null,
                icon: Icons.pause,
                color: null,
                size: 24,
              ),
            )
          ],
        ),
      ),
    );

  }
}
