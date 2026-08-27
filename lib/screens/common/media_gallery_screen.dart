import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/media_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/media_provider.dart';
import '../../theme/app_theme.dart';

class MediaGalleryScreen extends StatefulWidget {
  const MediaGalleryScreen({super.key});

  @override
  State<MediaGalleryScreen> createState() => _MediaGalleryScreenState();
}

class _MediaGalleryScreenState extends State<MediaGalleryScreen> {
  final List<String> _categories = ['All', 'Technical', 'Cultural', 'Sports', 'Seminar'];

  void _showMediaLightbox(BuildContext context, MediaModel media) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 600),
              decoration: BoxDecoration(
                color: AppColors.deepNavy,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      media.mediaUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(height: 250, color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          media.eventTitle,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          media.caption,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${media.category} • ${DateFormat('MMM dd, yyyy').format(media.uploadedOn)}',
                              style: const TextStyle(color: AppColors.secondaryLight, fontSize: 11),
                            ),
                            Text(
                              'Uploaded by ${media.uploaderName}',
                              style: const TextStyle(color: Colors.white60, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadSheet(BuildContext context) {
    final captionController = TextEditingController();
    final urlController = TextEditingController(text: 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=1000');
    final eventTitleController = TextEditingController(text: 'TechNova 2026 Hackathon');
    String selectedCat = 'Technical';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.add_photo_alternate, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Upload Event Photo / Video Clip', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: eventTitleController,
                decoration: const InputDecoration(labelText: 'Associated Event Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: captionController,
                decoration: const InputDecoration(labelText: 'Media Caption / Description'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(labelText: 'Image / Video Media URL'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (captionController.text.isNotEmpty) {
                    final auth = context.read<AuthProvider>();
                    await context.read<MediaProvider>().uploadMedia(
                          eventId: 'evt_custom',
                          eventTitle: eventTitleController.text.trim(),
                          mediaUrl: urlController.text.trim(),
                          caption: captionController.text.trim(),
                          category: selectedCat,
                          department: auth.currentUser?.department ?? 'Computer Science',
                          uploadedBy: auth.currentUser?.uid ?? 'usr_org_01',
                          uploaderName: auth.currentUser?.fullName ?? 'Organizer',
                        );
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                },
                child: const Text('Publish to Campus Gallery'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaProvider = context.watch<MediaProvider>();
    final auth = context.watch<AuthProvider>();
    final mediaList = mediaProvider.publicMedia;

    final isStaff = auth.currentUser?.role.key == 'organizer' || auth.currentUser?.role.key == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Media Gallery'),
        actions: [
          if (isStaff)
            IconButton(
              tooltip: 'Upload Media',
              icon: const Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
              onPressed: () => _showUploadSheet(context),
            ),
        ],
      ),
      body: Column(
        children: [
          // Category filter pills
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = mediaProvider.selectedCategory.toLowerCase() == cat.toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primaryContainer,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected ? AppColors.primaryDark : AppColors.textPrimaryLight,
                      ),
                      onSelected: (val) => mediaProvider.setCategory(cat),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const Divider(height: 1, color: AppColors.borderLight),

          // Gallery Grid
          Expanded(
            child: mediaList.isEmpty
                ? const Center(child: Text('No media items found for this category.'))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: mediaList.length,
                    itemBuilder: (context, index) {
                      final item = mediaList[index];
                      final isLiked = auth.currentUser != null && item.likedByUserIds.contains(auth.currentUser!.uid);

                      return InkWell(
                        onTap: () => _showMediaLightbox(context, item),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      item.mediaUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200),
                                    ),
                                    if (item.isFeatured)
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            gradient: AppColors.goldGradient,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text('FEATURED', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    Positioned(
                                      bottom: 6,
                                      right: 6,
                                      child: InkWell(
                                        onTap: () {
                                          if (auth.currentUser != null) {
                                            mediaProvider.toggleLike(item.id, auth.currentUser!.uid);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.65),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isLiked ? Icons.favorite : Icons.favorite_border,
                                                color: isLiked ? AppColors.accentOrange : Colors.white,
                                                size: 13,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                '${item.likesCount}',
                                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.caption,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.eventTitle,
                                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
