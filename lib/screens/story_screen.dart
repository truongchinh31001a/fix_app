import 'package:app/screens/detail_story_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';

class StoryScreen extends StatefulWidget {
  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Gọi fetchStories sau khi widget được xây dựng xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StoryProvider>(context, listen: false).fetchStories();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = Provider.of<StoryProvider>(context);

    // Lọc playlist theo từ khóa tìm kiếm
    final filteredPlaylists = storyProvider.playlists.entries
        .where((entry) => 'Playlist ${entry.key}'
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Story Playlists',
          style: TextStyle(color: Colors.black), // Màu chữ đen
        ),
        backgroundColor: Colors.white, // Nền trắng
        iconTheme: const IconThemeData(color: Colors.black), // Màu biểu tượng
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black, // Màu gạch chân
          labelColor: Colors.black, // Màu tab được chọn
          unselectedLabelColor: Colors.grey, // Màu tab chưa được chọn
          overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.grey.shade200; // Màu xám nhạt khi nhấn
            }
            return null; // Mặc định với trạng thái khác
          }),
          tabs: const [
            Tab(icon: Icon(Icons.audiotrack), text: 'Audio'),
            Tab(icon: Icon(Icons.videocam), text: 'Video'),
          ],
        ),
      ),
      body: Container(
        color: Colors.white, // Nền trắng cho toàn bộ phần nội dung
        child: Column(
          children: [
            // Ô tìm kiếm
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value; // Cập nhật từ khóa tìm kiếm
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  hintText: 'Tìm kiếm playlist...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: const TextStyle(color: Colors.black), // Màu chữ ô tìm kiếm
              ),
            ),
            // Danh sách playlist trong tab
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab Audio
                  _buildPlaylist(
                    storyProvider,
                    filteredPlaylists,
                    'audio',
                  ),
                  // Tab Video
                  _buildPlaylist(
                    storyProvider,
                    filteredPlaylists,
                    'video',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget xây dựng playlist theo loại (audio/video)
  Widget _buildPlaylist(
    StoryProvider storyProvider,
    List<MapEntry<dynamic, List>> filteredPlaylists,
    String type,
  ) {
    return storyProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : storyProvider.error != null
            ? Center(
                child: Text(
                  'Error: ${storyProvider.error}',
                  style: const TextStyle(color: Colors.black),
                ),
              )
            : Container(
                color: Colors.white, // Nền trắng cho toàn bộ danh sách
                child: ListView.builder(
                  itemCount: filteredPlaylists.length,
                  itemBuilder: (context, index) {
                    final areaId = filteredPlaylists[index].key;
                    final playlistName = 'Playlist $areaId';
                    final playlistStories = filteredPlaylists[index]
                        .value
                        .where((story) => _filterByType(story, type))
                        .toList();

                    return ExpansionTile(
                      title: Text(
                        playlistName,
                        style: const TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(
                        '${playlistStories.length} ${type == 'audio' ? 'audio' : 'video'} stories available',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      children: playlistStories.map((story) {
                        return ListTile(
                          title: Text(
                            story.name,
                            style: const TextStyle(color: Colors.black),
                          ),
                          leading: story.imageUrl.isNotEmpty
                              ? Image.network(
                                  'http://192.168.1.86:3000${story.imageUrl}',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image_not_supported,
                                  color: Colors.black),
                          onTap: () {
                            // Điều hướng tới màn hình chi tiết story
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailsStoryScreen(story: story),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              );
  }

  // Hàm lọc story theo loại (audio/video)
  bool _filterByType(dynamic story, String type) {
    if (type == 'audio') {
      return story.audioUrl['vi'] != null && story.audioUrl['vi'].isNotEmpty;
    } else if (type == 'video') {
      return story.videoUrl['vi'] != null && story.videoUrl['vi'].isNotEmpty;
    }
    return false;
  }
}
