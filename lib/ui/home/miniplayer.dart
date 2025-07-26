import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/data/model/song.dart';
import 'package:music/ui/now_playing/audio_player_manager.dart';
import 'package:marquee/marquee.dart';

class MiniPlayer extends StatefulWidget {
  final Song song;
  final VoidCallback onTap;

  const MiniPlayer({super.key, required this.song, required this.onTap});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  late AudioPlayerManager _audioPlayerManager;

  @override
  void initState() {
    super.initState();
    _audioPlayerManager = AudioPlayerManager(); // Singleton Instance
    _audioPlayerManager.prepare(); // Ensure stream is set up
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(12),
        ),
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/img.png',
                image: widget.song.image,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 20,
                child: Marquee(
                  text: '${widget.song.title} - ${widget.song.artist}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                  scrollAxis: Axis.horizontal,
                  blankSpace: 50.0,
                  velocity: 30.0,
                  pauseAfterRound: Duration(seconds: 1),
                  startPadding: 10.0,
                  accelerationDuration: Duration(seconds: 1),
                  accelerationCurve: Curves.linear,
                  decelerationDuration: Duration(milliseconds: 500),
                  decelerationCurve: Curves.easeOut,
                ),
              ),
            ),
            const SizedBox(width: 12),
            StreamBuilder<PlayerState>(
              stream: _audioPlayerManager.player.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final playing = playerState?.playing ?? false;

                return IconButton(
                  onPressed: () {
                    if (playing) {
                      _audioPlayerManager.player.pause();
                    } else {
                      _audioPlayerManager.player.play();
                    }
                  },
                  icon: Icon(
                    playing ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  iconSize: 28,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

