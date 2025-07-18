import 'package:music/data/source/source.dart';

import '../model/song.dart';

abstract interface class Repository {
  Future<List<Song>?> loadData();
}

class DefaultRepository implements Repository {
  final _localDataSource = LocalDataSource();
  final _remoteDataSource = RemoteDataSource();

  @override
  Future<List<Song>?> loadData() async {
    List<Song> songs = [];

    final remoteSongs = await _remoteDataSource.loadData();

    if (remoteSongs != null) {
      songs.addAll(remoteSongs);
    } else {
      final localSongs = await _localDataSource.loadData();
      if (localSongs != null) {
        songs.addAll(localSongs);
      }
    }

    return songs;
  }
}

