import 'package:flutter/material.dart';
import 'package:music/ui/discovery/finding.dart';

class DiscoveryTab extends StatefulWidget {
  const DiscoveryTab({super.key});

  @override
  State<DiscoveryTab> createState() => _DiscoveryTabState();
}

class _DiscoveryTabState extends State<DiscoveryTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FindingTab(songs: [],)),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: const [
                Padding(
                    padding: EdgeInsets.only(left: 10),
                  child: Icon(Icons.search, color: Colors.grey,),
                ),
                SizedBox(width: 10),
                Text(
                  'Tìm kiếm bài hát, nghệ sĩ...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
      body: const Center(
        child: Text('Discovery Content Here'),
      ),
    );
  }
}
