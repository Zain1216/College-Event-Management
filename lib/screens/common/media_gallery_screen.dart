import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/media_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/media_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_widgets.dart';

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
        insetPadding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.88),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        child: Image.network(
                          media.mediaUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(height: 250, color: Colors.black),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              color: Colors.black.withOpacity(0.4),
                              child: IconButton(
                                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                                onPressed: () => Navigator.pop(ctx),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          media.eventTitle,
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          media.caption,
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${media.category} • ${DateFormat('MMM dd, yyyy').format(media.uploadedOn)}',
                              style: GoogleFonts.inter(color: AppColors.secondaryLight, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Uploaded by ${media.uploaderName}',
                              style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showUploadSheet(BuildContext context) {
    final captionController = TextEditingController();
    final urlController = TextEditingController();
    final eventTitleController = TextEditingController();
    String selectedCat = 'Technical';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: Colors.white.withOpacity(0.8)),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppColors.heroGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Text('Upload Event Media', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GlassTextField(
                    controller: eventTitleController,
                    labelText: 'Associated Event Title',
                    prefixIcon: Icons.event_rounded,
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: captionController,
                    labelText: 'Media Caption / Description',
                    prefixIcon: Icons.description_outlined,
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: urlController,
                    labelText: 'Image / Video Media URL',
                    prefixIcon: Icons.link_rounded,
                  ),
                  const SizedBox(height: 20),
                  GlassButton(
                    label: 'Publish to Campus Gallery',
                    icon: Icons.cloud_upload_rounded,
                    onPressed: () async {
                      if (captionController.text.isNotEmpty && urlController.text.isNotEmpty) {
                        final auth = context.read<AuthProvider>();
                        await context.read<MediaProvider>().uploadMedia(
                              eventId: 'evt_custom',
                              eventTitle: eventTitleController.text.trim().isNotEmpty
                                  ? eventTitleController.text.trim()
                                  : 'Campus Event',
                              mediaUrl: urlController.text.trim(),
                              caption: captionController.text.trim(),
                              category: selectedCat,
                              department: auth.currentUser?.department ?? 'General',
                              uploadedBy: auth.currentUser?.uid ?? '',
                              uploaderName: auth.currentUser?.fullName ?? 'Organizer',
                            );
                        if (ctx.mounted) Navigator.pop(ctx);
                      }
                    },
                  ),
                ],
              ),
            ),
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Campus Media Gallery', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        actions: [
          if (isStaff)
            IconButton(
              tooltip: 'Upload Media',
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.8)),
                ),
                child: const Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: 18),
              ),
              onPressed: () => _showUploadSheet(context),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Category filter pills
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = mediaProvider.selectedCategory.toLowerCase() == cat.toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => mediaProvider.setCategory(cat),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppColors.heroGradient : null,
                          color: isSelected ? null : Colors.white.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.white.withOpacity(0.6) : Colors.white.withOpacity(0.8),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                    ),
                  );
                  }).toList(),
              ),
            ),
          ),

          // Gallery Grid
          Expanded(
            child: mediaList.isEmpty
                ? Center(
                    child: Text('No media items found for this category.', style: GoogleFonts.inter(color: AppColors.textSecondaryLight)),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 85),
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

                      return GlassContainer(
                        borderRadius: 20,
                        blurSigma: 12,
                        padding: EdgeInsets.zero,
                        onTap: () => _showMediaLightbox(context, item),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                    child: Image.network(
                                      item.mediaUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200),
                                    ),
                                  ),
                                  if (item.isFeatured)
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          gradient: AppColors.goldGradient,
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(color: AppColors.accentGold.withOpacity(0.4), blurRadius: 6),
                                          ],
                                        ),
                                        child: Text(
                                          'FEATURED',
                                          style: GoogleFonts.inter(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w900),
                                        ),
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
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.5),
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                                  color: isLiked ? AppColors.accentOrange : Colors.white,
                                                  size: 13,
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  '${item.likesCount}',
                                                  style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                                                ),
                                              ],
                                            ),
                                          ),
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
                                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.eventTitle,
                                    style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondaryLight),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
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
