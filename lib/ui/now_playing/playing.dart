import 'dart:math';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/data/model/song.dart';
import 'package:music/ui/now_playing/audio_player_manager.dart';

import 'audio_player_manager.dart' show DurationState;

import 'dart:ui';

class NowPlaying extends StatelessWidget {
  final Song playingSong;
  final List<Song> songs;
  final ValueChanged<Song> onSongChanged;

  const NowPlaying({
    super.key,
    required this.playingSong,
    required this.songs,
    required this.onSongChanged,
  });

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(
      songs: songs,
      playingSong: playingSong,
      onSongChanged: onSongChanged, // <--- truyền xuống
    );
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({
    super.key,
    required this.songs,
    required this.playingSong, required this.onSongChanged,
  });

  final Song playingSong;
  final List<Song> songs;
  final ValueChanged<Song> onSongChanged;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimController;
  late AudioPlayerManager _audioPlayerManager;
  late int _selectedItemIndex;
  late Song _song;
  bool _isShuffed = false;
  late LoopMode _loopMode;

  @override
  void initState() {
    super.initState();
    _song = widget.playingSong;
    _imageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );
    _audioPlayerManager = AudioPlayerManager();
    _audioPlayerManager.prepare();  // setup stream
    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);
    _loopMode = LoopMode.off;

    _audioPlayerManager.updateSongUrl(_song.source);


    _audioPlayerManager.player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        if (_loopMode == LoopMode.off) {
          _setNextSong();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ẢNH MỜ NỀN TOÀN MÀN
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/img.png',
                image: _song.image,
                fit: BoxFit.cover,
                imageErrorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/img.png', fit: BoxFit.cover);
                },
              ),
            ),
          ),

          // GIAO DIỆN CHỒNG LÊN ẢNH
          SafeArea(
            child: Column(
              children: [
                // TỰ TẠO THANH NOW PLAYING
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          CupertinoIcons.back,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        '   Now Playing',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_horiz, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _song.album,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        const Text('__ ____ __'),
                        const SizedBox(height: 48),
                        RotationTransition(
                          turns: Tween(
                            begin: 0.0,
                            end: 1.0,
                          ).animate(_imageAnimController),
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/img.png',
                            image: _song.image,
                            width: screenWidth - delta,
                            height: screenWidth - delta,
                            imageErrorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/img.png',
                                width: screenWidth - delta,
                                height: screenWidth - delta,
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.share,
                                  color: Colors.white,
                                ),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              Column(
                                children: [
                                  Text(
                                    _song.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _song.artist,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.favorite_border_outlined,
                                  color: Colors.white,
                                ),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: _progressBar(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 32,
                            left: 24,
                            right: 24,
                            bottom: 32,
                          ),
                          child: _mediaButton(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _mediaButton() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(
            function: _setShuffed,
            icon: Icons.shuffle,
            color: _getShuffedColor(),
            size: 24,
          ),
          MediaButtonControl(
            function: _setPrevSong,
            icon: Icons.skip_previous,
            color: Colors.white,
            size: 36,
          ),
          _playButton(),
          MediaButtonControl(
            function: _setNextSong,
            icon: Icons.skip_next,
            color: Colors.white,
            size: 36,
          ),
          MediaButtonControl(
            function: _setRepeatOption,
            icon: _repeatingIcon(),
            color: _getRepeatingIconColor(),
            size: 24,
          ),
        ],
      ),
    );
  }

  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
      stream: _audioPlayerManager.durationState,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.progress ?? Duration.zero;
        final buffered = durationState?.buffered ?? Duration.zero;
        final total = durationState?.total ?? Duration.zero;
        return ProgressBar(
          progress: progress,
          buffered: buffered,
          total: total,
          baseBarColor: Colors.white.withOpacity(0.3),
          bufferedBarColor: Colors.white54,
          progressBarColor: Colors.white,
          thumbColor: Colors.white,
          timeLabelTextStyle: const TextStyle(color: Colors.white),
          onSeek: _audioPlayerManager.player.seek,
        );
      },
    );
  }

  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder(
      stream: _audioPlayerManager.player.playerStateStream,
      builder: (context, snapshot) {
        final playState = snapshot.data;
        final processingState = playState?.processingState;
        final playing = playState?.playing;

        const double buttonSize = 64;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          );
        } else if (playing != true) {
          return SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: MediaButtonControl(
              function: () {
                _audioPlayerManager.player.play();
              },
              icon: Icons.play_arrow,
              color: Colors.white,
              size: 48,
            ),
          );
        } else if (processingState != ProcessingState.completed) {
          return SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: MediaButtonControl(
              function: () {
                _audioPlayerManager.player.pause();
              },
              icon: Icons.pause,
              color: Colors.white,
              size: 48,
            ),
          );
        } else {
          return SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: MediaButtonControl(
              function: () {
                _audioPlayerManager.player.seek(Duration.zero);
              },
              icon: Icons.replay,
              color: Colors.white,
              size: 48,
            ),
          );
        }
      },
    );
  }

  void _setNextSong() {
    if (_isShuffed) {
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length - 1);
    } else {
      ++_selectedItemIndex;
    }
    if (_selectedItemIndex >= widget.songs.length) {
      _selectedItemIndex = _selectedItemIndex % widget.songs.length;
    }
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);

    widget.onSongChanged(nextSong);

    setState(() {
      _song = nextSong;
    });
  }

  void _setPrevSong() {
    if (_isShuffed) {
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length - 1);
    } else {
      --_selectedItemIndex;
    }
    if (_selectedItemIndex < 0) {
      _selectedItemIndex =
          (_selectedItemIndex + widget.songs.length) % widget.songs.length;
    }
    final prevSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(prevSong.source);

    widget.onSongChanged(prevSong);

    setState(() {
      _song = prevSong;
    });
  }

  void _setShuffed() {
    setState(() {
      _isShuffed = !_isShuffed;
    });
  }

  Color? _getShuffedColor() {
    return _isShuffed ? Colors.white38 : Colors.white;
  }

  IconData _repeatingIcon() {
    return switch (_loopMode) {
      LoopMode.one => Icons.repeat_one,
      _ => Icons.repeat,
    };
  }

  Color? _getRepeatingIconColor() {
    return _loopMode == LoopMode.off ? Colors.white38 : Colors.white;
  }

  void _setRepeatOption() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.one;
    } else {
      _loopMode = LoopMode.off;
    }
    setState(() {
      _audioPlayerManager.player.setLoopMode(_loopMode);
    });
  }
}

class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl({
    super.key,
    required this.function,
    required this.icon,
    required this.color,
    required this.size,
  });

  final void Function()? function;
  final IconData icon;
  final double? size;
  final Color? color;

  @override
  State<StatefulWidget> createState() => _MediaButtonControlState();
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
