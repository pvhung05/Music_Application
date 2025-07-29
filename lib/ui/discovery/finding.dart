import 'package:flutter/material.dart';
import 'package:music/data/model/song.dart';
import 'package:music/ui/now_playing/playing.dart';

class FindingTab extends StatefulWidget {
  final List<Song> songs;

  const FindingTab({super.key, required this.songs});

  @override
  State<FindingTab> createState() => _FindingTabState();
}

class _FindingTabState extends State<FindingTab>{
  final TextEditingController _searchController = TextEditingController();
  late List<Song> _filteredSongs = [];

  @override
  void initState() {
    super.initState();
    _filteredSongs = widget.songs;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredSongs = widget.songs
          .where((song) => (song.title).toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm bài hát, nghệ sĩ...',
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _filteredSongs.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.music_note, color: Colors.blueAccent),
            title: Text(_filteredSongs[index].title),
            onTap: () {
              Navigator.pop(context, _filteredSongs[index]);
            },
          );
        },
      ),
    );
  }
}
