import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../common/models/sermon.dart';
import '../../common/services/sermons_service.dart';
import '../../common/widgets/web_iframe.dart';

class SermonDetailScreen extends StatefulWidget {
  const SermonDetailScreen({super.key, required this.churchId, required this.sermonId});

  final String churchId;
  final String sermonId;

  @override
  State<SermonDetailScreen> createState() => _SermonDetailScreenState();
}

class _SermonDetailScreenState extends State<SermonDetailScreen> {
  VideoPlayerController? _videoController;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initVideo(String url) async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoController!.initialize();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tag = (ModalRoute.of(context)?.settings as dynamic).arguments as String?;
    return Scaffold(
      appBar: AppBar(title: const Text('Sermon')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('churches')
            .doc(widget.churchId)
            .collection('sermons')
            .doc(widget.sermonId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.data();
          if (data == null) return const Center(child: Text('Not found'));
          final sermon = Sermon.fromDoc(snapshot.data!.id, data);
          // Increment view count best-effort
          SermonsService().incrementView(widget.churchId, widget.sermonId).catchError((_) {});

          if (sermon.isLive && sermon.liveUrl != null) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Live Stream'),
                  const SizedBox(height: 8),
                  WebIFrame(url: sermon.liveUrl!, height: 360),
                ],
              ),
            );
          }
          if (sermon.mediaType == 'video') {
            if (_videoController == null) {
              _initVideo(sermon.mediaUrl);
            }
            if (_videoController == null || !_videoController!.value.isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }
            return AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: Hero(tag: tag ?? 'sermon_${sermon.id}', child: VideoPlayer(_videoController!)),
            );
          } else {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(tag: tag ?? 'sermon_${sermon.id}', child: const Icon(Icons.play_circle_outline, size: 72)),
                  const SizedBox(height: 12),
                  const Text('Audio sermon'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => launchUrl(Uri.parse(sermon.mediaUrl), mode: LaunchMode.externalApplication),
                    child: const Text('Open Audio'),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: _videoController != null && _videoController!.value.isInitialized
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play();
                });
              },
              child: Icon(_videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow),
            )
          : null,
    );
  }
}