import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music/ui/discovery/discovery.dart';
import 'package:music/ui/home/miniplayer.dart';
import 'package:music/ui/home/viewmodel.dart';
import 'package:music/ui/now_playing/audio_player_manager.dart';
import 'package:music/ui/setting/settings.dart';

import '../../data/model/song.dart';
import '../now_playing/playing.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
      ),
      home: MusicHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _State();
}

class _State extends State<MusicHomePage> {
  int _currentIndex = 0;
  Song? currentPlayingSong; // bài hát đang phát
  List<Song> allSongs = [];

  final List<Widget> _tabs = [
    const HomeTab(),
    const DiscoveryTab(),
    const SettingsTab(),
  ];

  void updateCurrentPlayingSong(Song song) {
    setState(() {
      currentPlayingSong = song;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Music App')),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: CupertinoTabScaffold(
                  tabBar: CupertinoTabBar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.onInverseSurface,
                    activeColor: Colors.black,
                    currentIndex: _currentIndex,
                    onTap: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    items: const [
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Icon(Icons.home),
                        ),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Icon(Icons.album),
                        ),
                        label: 'Discovery',
                      ),
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Icon(Icons.settings),
                        ),
                        label: 'Settings',
                      ),
                    ],
                  ),
                  tabBuilder: (BuildContext context, int index) {
                    return _tabs[index];
                  },
                ),
              ),
            ],
          ),
          if (currentPlayingSong != null)
            Positioned(
              left: 2,
              right: 2,
              bottom: 76,
              // Chiều cao CupertinoTabBar để MiniPlayer nằm phía trên
              child: MiniPlayer(
                song: currentPlayingSong!,
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => NowPlaying(
                        songs: allSongs, // truyền danh sách bài hát
                        playingSong: currentPlayingSong!,
                        onSongChanged: (newSong) {
                          setState(() {
                            currentPlayingSong =
                                newSong; // cập nhật bài hát ở MiniPlayer
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  late MusicAppViewModel _viewModel = MusicAppViewModel();

  @override
  void initState() {
    _viewModel = MusicAppViewModel();
    _viewModel.loadSongs();
    observeData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: getBody());
  }

  @override
  void dispose() {
    _viewModel.songStream.close();
    AudioPlayerManager().dispose();
    super.dispose();
  }

  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if (showLoading) {
      return getProgressBar();
    } else {
      return getListView();
    }
  }

  Widget getProgressBar() {
    return const Center(child: CircularProgressIndicator());
  }

  ListView getListView() {
    return ListView.separated(
      itemBuilder: (context, position) {
        return const Divider(
          color: Colors.grey,
          thickness: 1,
          indent: 24,
          endIndent: 24,
        );
      },
      separatorBuilder: (context, position) {
        return getRow(position);
      },
      itemCount: songs.length,
      shrinkWrap: true,
    );
  }

  Widget getRow(int index) {
    return _SongItemSection(parent: this, song: songs[index]);
  }

  void observeData() {
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });

      (context.findAncestorStateOfType<_State>())?.allSongs = songs;
    });
  }

  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular((16))),
          child: Container(
            height: 600,
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('Model Bottom Sheet'),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close Bottom Sheet'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // void navigate(Song song) {
  //   Navigator.push(
  //     context,
  //     CupertinoPageRoute(
  //       builder: (context) {
  //         return NowPlaying(songs: songs, playingSong: song);
  //       },
  //     ),
  //   );
  // }
  void navigate(Song song) {
    (context.findAncestorStateOfType<_State>())?.updateCurrentPlayingSong(song);

    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => NowPlaying(
          songs: songs,
          playingSong: song,
          onSongChanged: (newSong) {},
        ),
      ),
    );
  }
}

class _SongItemSection extends StatelessWidget {
  const _SongItemSection({required this.parent, required this.song});

  final _HomeTabPageState parent;
  final Song song;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 24, right: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/img.png',
          image: song.image,
          width: 48,
          height: 48,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/img.png', width: 48, height: 48);
          },
        ),
      ),
      title: Text(song.title),
      subtitle: Text(song.artist),
      trailing: IconButton(
        onPressed: () {
          parent.showBottomSheet();
        },
        icon: const Icon(Icons.more_horiz),
      ),
      onTap: () {
        parent.navigate(song);
      },
    );
  }
}
