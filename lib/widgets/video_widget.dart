import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../providers/video_provider.dart';

class VideoWidget extends StatelessWidget {
  final String videoUrl;

  const VideoWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);

    // Khởi tạo video nếu cần
    if (videoProvider.controller == null ||
        videoProvider.controller!.dataSource != videoUrl) {
      Future.microtask(() => videoProvider.initVideo(videoUrl));
    }

    return GestureDetector(
      onTap: videoProvider.toggleControls,
      child: Consumer<VideoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading || provider.controller == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return AspectRatio(
            aspectRatio: provider.controller!.value.isInitialized
                ? provider.controller!.value.aspectRatio
                : 16 / 9,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                VideoPlayer(provider.controller!),
                if (provider.showControls) _buildControls(provider, context),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Xây dựng các điều khiển của video
  Widget _buildControls(VideoProvider videoProvider, BuildContext context) {
    return Container(
      height: 60, // Giới hạn chiều cao thanh điều khiển
      color: Colors.black.withOpacity(0.6),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          // Nút Play/Pause
          IconButton(
            icon: Icon(
              videoProvider.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: videoProvider.togglePlayPause,
          ),

          // Thanh Slider tiến trình video
          Expanded(
            child: Slider(
              value: videoProvider.controller!.value.position.inSeconds
                  .clamp(0, videoProvider.controller!.value.duration.inSeconds)
                  .toDouble(),
              min: 0,
              max:
                  videoProvider.controller!.value.duration.inSeconds.toDouble(),
              activeColor: Colors.white,
              inactiveColor: Colors.grey,
              onChanged: (value) {
                videoProvider.seekTo(Duration(seconds: value.toInt()));
              },
            ),
          ),

          // Nút Fullscreen
          IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.white),
            onPressed: () => _enterFullScreen(context, videoProvider),
          ),
        ],
      ),
    );
  }

  /// Chế độ Fullscreen
  void _enterFullScreen(
      BuildContext context, VideoProvider videoProvider) async {
    await videoProvider.enterFullScreen();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenVideo(videoProvider: videoProvider),
      ),
    ).then((_) async {
      // Reset lại trạng thái màn hình khi thoát fullscreen
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      // Đảm bảo video được làm mới lại khi trở về chế độ portrait
      videoProvider.exitFullScreen();

      Future.microtask(() {
        videoProvider.controller?.setVolume(1.0);
        videoProvider.controller?.pause(); // Đảm bảo dừng video (nếu cần)
        videoProvider.notifyListeners(); // Cập nhật lại giao diện
      });
    });
  }
}

/// Widget hiển thị video ở chế độ Fullscreen
class FullScreenVideo extends StatelessWidget {
  final VideoProvider videoProvider;

  const FullScreenVideo({Key? key, required this.videoProvider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: videoProvider.toggleControls,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: videoProvider.controller!.value.aspectRatio,
                child: VideoPlayer(videoProvider.controller!),
              ),
            ),
            if (videoProvider.showControls)
              _buildFullScreenControls(videoProvider, context),
          ],
        ),
      ),
    );
  }

  /// Thanh điều khiển ở chế độ fullscreen
  Widget _buildFullScreenControls(
      VideoProvider videoProvider, BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: Container(
          height: 60,
          color: Colors.black.withOpacity(0.6),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  videoProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: videoProvider.togglePlayPause,
              ),
              Expanded(
                child: Slider(
                  value: videoProvider.controller!.value.position.inSeconds
                      .clamp(
                          0, videoProvider.controller!.value.duration.inSeconds)
                      .toDouble(),
                  min: 0,
                  max: videoProvider.controller!.value.duration.inSeconds
                      .toDouble(),
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey,
                  onChanged: (value) {
                    videoProvider.seekTo(Duration(seconds: value.toInt()));
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}