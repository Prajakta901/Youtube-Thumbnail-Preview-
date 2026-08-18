import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

// ---------------- DARK THEME COLORS ----------------

class AppColors {
  static const background = Color(0xFF0F0F0F);
  static const surface = Color(0xFF212121);
  static const chipUnselected = Color(0xFF272727);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFFAAAAAA);
  static const divider = Color(0xFF303030);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.red,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.background,
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
      home: const YouTubeHomeScreen(),
    );
  }
}

// ---------------- VIDEO MODEL ----------------

class VideoData {
  final String title;
  final String description;
  final String channelName;
  final String views;
  final String uploadTime;
  final String duration;
  final String? thumbnailUrl;
  final Uint8List? imageBytes;

  VideoData({
    required this.title,
    required this.channelName,
    this.description = '',
    this.views = '0',
    this.uploadTime = 'Just now',
    this.duration = '10:00',
    this.thumbnailUrl,
    this.imageBytes,
  });
}

// ---------------- HOME SCREEN ----------------

class YouTubeHomeScreen extends StatefulWidget {
  const YouTubeHomeScreen({super.key});

  @override
  State<YouTubeHomeScreen> createState() => _YouTubeHomeScreenState();
}

class _YouTubeHomeScreenState extends State<YouTubeHomeScreen> {
  final List<VideoData> videos = [
    VideoData(
      thumbnailUrl: 'https://picsum.photos/seed/9/400/225',
      title: 'Exploring the city: A Journey Through Urban Landscapes',
      channelName: 'Travel vlogs',
      views: '9.3K',
      uploadTime: '1 week ago',
      duration: '18:47',
    ),
    
    VideoData(
      thumbnailUrl: 'https://picsum.photos/seed/4/400/225',
      title: 'Strawberry Shortcake Recipe: Easy and Delicious Dessert',
      channelName: 'Natural',
      views: '45K',
      uploadTime: '5 hours ago',
      duration: '22:10',
    ),
    VideoData(
      thumbnailUrl: 'https://picsum.photos/seed/6/400/225',
      title: 'Exploring traditional Japanese culture in Tokyo',
      channelName: 'Tokyo talker',
      views: '61K',
      uploadTime: '3 days ago',
      duration: '11:05',
    ),
    VideoData(
      thumbnailUrl: 'https://picsum.photos/seed/88/400/225',
      title: 'Exploring mountains: A Journey Through Nature\'s Beauty',
      channelName: 'Travel Hub',
      views: '9.3K',
      uploadTime: '1 week ago',
      duration: '18:47',
    ),
    
    VideoData(
      thumbnailUrl: 'https://picsum.photos/seed/77/400/225',
      title: 'Calligraphy Roadmap in 2026',
      channelName: 'Calligraphy Guidance',
      views: '203K',
      uploadTime: '1 month ago',
      duration: '16:33',
    ),
    VideoData(
      thumbnailUrl: 'https://picsum.photos/seed/2/400/225',
      title: 'Python Tutorial: Build a YouTube UI Clone from Scratch',
      channelName: 'Python Coder',
      views: '128K',
      uploadTime: '2 days ago',
      duration: '14:22',
    ),
  ];

  Future<void> _openCreateScreen() async {
    final newVideo = await Navigator.push<VideoData>(
      context,
      MaterialPageRoute(builder: (_) => const CreateVideoScreen()),
    );

    if (newVideo != null) {
      setState(() => videos.insert(0, newVideo));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video published to your feed!')),
        );
      }
    }
  }

  // Decide grid columns based on screen width, like real YouTube
  int _getColumnCount(double width) {
    if (width >= 1600) return 4;
    if (width >= 1100) return 3;
    if (width >= 800) return 2;
    return 1; // mobile: single column feed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildCategoryChips(),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = _getColumnCount(constraints.maxWidth);
                final isGrid = columns > 1;

                if (!isGrid) {
                  // Mobile: single column list (original feed look)
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: YouTubeThumbnailPreview(video: videos[index]),
                      );
                    },
                  );
                }

                // Desktop/laptop: multi-column grid
                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: videos.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 0,
                    childAspectRatio: 0.82, // fits thumbnail + text block
                  ),
                  itemBuilder: (context, index) {
                    return YouTubeThumbnailPreview(video: videos[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateScreen,
        icon: const Icon(Icons.add),
        label: const Text('Create'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width >= 800
          ? null // hide bottom nav on desktop, like real YouTube
          : _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleSpacing: 12,
      title: Row(
        children: const [
          Icon(Icons.smart_display, color: Colors.red, size: 28),
          SizedBox(width: 6),
          Text(
            'YouTube',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.cast_outlined, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        const Padding(
          padding: EdgeInsets.only(right: 12),
          child: CircleAvatar(
            radius: 14,
            backgroundColor: Colors.deepPurple,
            child: Text('S', style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    final categories = ['All', 'Music', 'Travel', 'Vlogs', 'Dance', 'Gaming', 'Series', 'News', 'Sports', 'Education', 'Comedy'];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == 0;
          return Chip(
            label: Text(categories[index]),
            backgroundColor: selected ? Colors.white : AppColors.chipUnselected,
            labelStyle: TextStyle(
              color: selected ? Colors.black : AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            side: BorderSide.none,
          );
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: AppColors.background,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.white,
      unselectedItemColor: AppColors.textSecondary,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), label: 'Shorts'),
        BottomNavigationBarItem(icon: Icon(Icons.subscriptions_outlined), label: 'Subscriptions'),
        BottomNavigationBarItem(icon: Icon(Icons.video_library_outlined), label: 'Library'),
      ],
    );
  }
}

// ---------------- CREATE VIDEO SCREEN ----------------

class CreateVideoScreen extends StatefulWidget {
  const CreateVideoScreen({super.key});

  @override
  State<CreateVideoScreen> createState() => _CreateVideoScreenState();
}

class _CreateVideoScreenState extends State<CreateVideoScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _channelController = TextEditingController();

  Uint8List? _imageBytes;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  void _publish() {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a thumbnail image')),
      );
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    final video = VideoData(
      imageBytes: _imageBytes,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      channelName: _channelController.text.trim().isEmpty
          ? 'My Channel'
          : _channelController.text.trim(),
      views: '0',
      uploadTime: 'Just now',
      duration: '10:00',
    );

    Navigator.pop(context, video);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Upload Video', style: TextStyle(color: AppColors.textPrimary)),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Center(
        child: ConstrainedBox(
          // keeps the form readable on wide desktop screens
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: _imageBytes == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.textSecondary),
                                SizedBox(height: 8),
                                Text('Tap to select thumbnail image',
                                    style: TextStyle(color: AppColors.textSecondary)),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _titleController,
                  maxLength: 100,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
               
                TextField(
                  controller: _channelController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Channel Name'),
                ),
                const SizedBox(height: 20),

                if (_imageBytes != null) ...[
                  const Text('Live Preview',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  AnimatedBuilder(
                    animation: Listenable.merge([_titleController, _channelController]),
                    builder: (context, _) {
                      return YouTubeThumbnailPreview(
                        video: VideoData(
                          imageBytes: _imageBytes,
                          title: _titleController.text.trim().isEmpty
                              ? 'Your video title...'
                              : _titleController.text.trim(),
                          channelName: _channelController.text.trim().isEmpty
                              ? 'Your channel'
                              : _channelController.text.trim(),
                          views: '0',
                          uploadTime: 'Just now',
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                ElevatedButton.icon(
                  onPressed: _publish,
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text('Publish to Home Feed'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- THUMBNAIL PREVIEW WIDGET (shared) ----------------

class YouTubeThumbnailPreview extends StatelessWidget {
  final VideoData video;

  const YouTubeThumbnailPreview({super.key, required this.video});

  Widget _buildImage() {
    if (video.imageBytes != null) {
      return Image.memory(video.imageBytes!, fit: BoxFit.cover);
    }
    return Image.network(
      video.thumbnailUrl!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.surface,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        color: AppColors.surface,
        child: const Icon(Icons.image_not_supported, size: 40, color: AppColors.textSecondary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                Positioned.fill(child: _buildImage()),
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video.duration,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.red[900],
                child: Text(
                  video.channelName.isNotEmpty ? video.channelName[0].toUpperCase() : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(video.channelName,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text(
                      '${video.views} views • ${video.uploadTime}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }
}