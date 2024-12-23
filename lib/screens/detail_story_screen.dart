import 'package:app/widgets/audio_widget.dart';
import 'package:app/widgets/video_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/story.dart';
import '../providers/details_manager.dart';
import '../providers/security_provider.dart';

class DetailsStoryScreen extends StatelessWidget {
  final Story story;

  const DetailsStoryScreen({Key? key, required this.story}) : super(key: key);

  /// Ánh xạ `language` từ SecurityProvider sang mã ngôn ngữ
  String _mapLanguage(String? language) {
    switch (language) {
      case 'English':
        return 'en';
      case 'Vietnamese':
        return 'vi';
      default:
        return 'vi'; // Mặc định là tiếng Việt
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy ngôn ngữ hiện tại từ SecurityProvider
    final securityProvider = Provider.of<SecurityProvider>(context);
    final detailsManager = Provider.of<DetailsManager>(context, listen: false); // Tích hợp DetailsManager
    final language = _mapLanguage(securityProvider.language);

    // Dữ liệu dựa trên ngôn ngữ
    final String description =
        story.contentText[language] ?? 'No description available';
    final String imageUrl = story.imageUrl;
    final String videoPath = story.videoUrl[language] ?? '';
    final String audioPath = story.audioUrl[language] ?? '';

    // Lưu trạng thái vào DetailsManager
    WidgetsBinding.instance.addPostFrameCallback((_) {
      detailsManager.setDetails('story', {
        'storyId': story.storyId,
        'name': story.name,
        'audioUrl': audioPath,
        'videoUrl': videoPath,
      });
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          story.name,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // TOP: Hình ảnh hoặc Video
              if (videoPath.isNotEmpty)
                VideoWidget(videoUrl: 'http://192.168.1.86:3000$videoPath')
              else if (imageUrl.isNotEmpty)
                _buildTopImage(imageUrl),

              // MID: Mô tả
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ],
          ),

          // BOTTOM: AudioWidget (nằm dưới cùng màn hình)
          if (audioPath.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 30, // Margin bottom
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 180, // Cố định chiều cao của AudioWidget
                child: AudioWidget(
                  audioUrl: 'http://192.168.1.86:3000$audioPath',
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Widget hiển thị hình ảnh
  Widget _buildTopImage(String imageUrl) {
    return Image.network(
      'http://192.168.1.86:3000$imageUrl',
      fit: BoxFit.cover,
      width: double.infinity,
      height: 200,
    );
  }
}
