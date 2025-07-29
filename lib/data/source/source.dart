import 'dart:convert';

import 'package:flutter/services.dart';

import '../model/song.dart';
import 'package:http/http.dart' as http;

abstract interface class DataSource {
  Future<List<Song>?> loadData();
}

class RemoteDataSource implements DataSource {
  @override
  Future<List<Song>?> loadData() async {
    final url = 'https://thantrieu.com/resources/braniumapis/songss.jsons';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final bodyContent = utf8.decode(response.bodyBytes);
      final jsonResult = jsonDecode(bodyContent);

      //print('📦 JSON thực tế: $jsonResult');

      if (jsonResult is Map && jsonResult['songs'] is List) {
        final List<dynamic> songsJson = jsonResult['songs'];
        return songsJson.map((e) => Song.fromJSon(e)).toList();
      } else {
        //print(' JSON không chứa danh sách "songs" hợp lệ');
        return null;
      }
    } else {
      //print(' Lỗi HTTP: ${response.statusCode}');
      return null;
    }
  }
}

class LocalDataSource implements DataSource {
  @override
  Future<List<Song>?> loadData() async {
    try {
      final String response = await rootBundle.loadString('assets/songs.json');
      final jsonBody = jsonDecode(response);

      if (jsonBody is Map<String, dynamic> && jsonBody['songs'] is List) {
        final List<dynamic> songList = jsonBody['songs'];
        List<Song> songs = songList
            .map((song) => Song.fromJSon(song as Map<String, dynamic>))
            .toList();
        return songs;
      } else {
        //print('File JSON không hợp lệ hoặc không chứa "songs"');
        return null;
      }
    } catch (e) {
      //print('Lỗi khi đọc file local JSON: $e');
      return null;
    }
  }
}
