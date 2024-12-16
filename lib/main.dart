import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/story_provider.dart';
import 'providers/artifact_provider.dart';  // Thêm import cho ArtifactProvider
import 'services/story_service.dart';
import 'services/artifact_service.dart';  // Dịch vụ Artifact nếu cần
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(MuseumApp());
}

class MuseumApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider cho Story
        ChangeNotifierProvider(
          create: (_) => StoryProvider(
            storyService: StoryService(), // Khởi tạo StoryService
          ),
        ),
        // Provider cho Artifact
        ChangeNotifierProvider(
          create: (_) => ArtifactProvider(), // Khởi tạo ArtifactProvider
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Museum App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/main': (context) => MainScreen(),
        },
      ),
    );
  }
}
