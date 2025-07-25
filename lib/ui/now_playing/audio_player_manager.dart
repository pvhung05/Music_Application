import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerManager {
  AudioPlayerManager._internal();
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  factory AudioPlayerManager() => _instance;
  String? currentPlayingUrl;

  final player = AudioPlayer();
  Stream<DurationState>? durationState;
  String songUrl = "";

  void prepare() {
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
      player.positionStream,
      player.playbackEventStream,
      (position, playbackEvent) => DurationState(
        progress: position,
        buffered: playbackEvent.bufferedPosition,
        total: playbackEvent.duration,
      ),
    );
  }

  Future<void> updateSongUrl(String url) async {
    if (url != songUrl) {
      songUrl = url;
      await player.setUrl(songUrl);
      await player.play();
      currentPlayingUrl = url;
    } else {
      if (!player.playing) {
        await player.play();
      }
    }
  }


  void dispose() {
    player.dispose();
  }

}

class DurationState {
  const DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });

  final Duration progress;
  final Duration buffered;
  final Duration? total;
}
