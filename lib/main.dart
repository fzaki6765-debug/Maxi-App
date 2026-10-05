import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MaxiApp());
}

class MaxiApp extends StatelessWidget {
  const MaxiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MAXI 4K',
      theme: ThemeData.dark(),
      home: const MaxiHomeScreen(),
    );
  }
}

class MaxiHomeScreen extends StatefulWidget {
  const MaxiHomeScreen({Key? key}) : super(key: key);

  @override
  _MaxiHomeScreenState createState() => _MaxiHomeScreenState();
}

class _MaxiHomeScreenState extends State<MaxiHomeScreen> {
  final String url = "https://pastebin.com/raw/jFSrc1VM";

  Future<Map<String, dynamic>?> fetchMaxiData() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _launchStream(String videoUrl) async {
    final Uri uri = Uri.parse(videoUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("MAXI 4K", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[900],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchMaxiData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("خطأ في الاتصال بالسيرفر أو جلب البيانات", style: TextStyle(color: Colors.white)));
          }

          final data = snapshot.data!;
          final movies = data['movies'] as List;
          final liveTv = data['live_tv'] as List;

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const Text("الأفلام المتاحة", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return GestureDetector(
                      onTap: () {
                        _launchStream(movie['video_url'] ?? '');
                      },
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[850],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Icon(Icons.movie, color: Colors.redAccent, size: 40),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              movie['title'] ?? '',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text("البث المباشر", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: liveTv.length,
                itemBuilder: (context, index) {
                  final channel = liveTv[index];
                  return Card(
                    color: Colors.grey[900],
                    child: ListTile(
                      leading: const Icon(Icons.tv, color: Colors.redAccent),
                      title: Text(channel['channel_name'] ?? '', style: const TextStyle(color: Colors.white)),
                      subtitle: Text(channel['category'] ?? '', style: const TextStyle(color: Colors.grey)),
                      trailing: const Icon(Icons.play_arrow, color: Colors.white),
                      onTap: () {
                        _launchStream(channel['stream_url'] ?? '');
                      },
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
