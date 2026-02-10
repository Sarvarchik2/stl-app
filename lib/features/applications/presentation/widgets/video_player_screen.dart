import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:stl_app/core/app_colors.dart';
import 'dart:io';

class VideoPlayerScreen extends StatefulWidget {
  final String url;
  final String filename;
  final Map<String, String>? httpHeaders;

  const VideoPlayerScreen({
    super.key,
    required this.url,
    required this.filename,
    this.httpHeaders,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    if (widget.url.startsWith('http')) {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
        httpHeaders: widget.httpHeaders ?? const {},
      );
    } else {
      _videoPlayerController = VideoPlayerController.file(File(widget.url));
    }
    await _videoPlayerController.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      showControls: true,
      aspectRatio: _videoPlayerController.value.aspectRatio,
    );
    
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.filename),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _chewieController != null && _videoPlayerController.value.isInitialized
            ? Chewie(controller: _chewieController!)
            : const CircularProgressIndicator(),
      ),
    );
  }
}
