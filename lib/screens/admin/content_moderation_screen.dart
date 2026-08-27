import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/feedback_provider.dart';
import '../../providers/media_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_widgets.dart';

class ContentModerationScreen extends StatefulWidget {
  const ContentModerationScreen({super.key});

  @override
  State<ContentModerationScreen> createState() => _ContentModerationScreenState();
}

class _ContentModerationScreenState extends State<ContentModerationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedbackProvider = context.watch<FeedbackProvider>();
    final mediaProvider = context.watch<MediaProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allFeedbacks = feedbackProvider.allFeedbacks;
    final allMedia = mediaProvider.allMedia;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Moderation & Content Hub', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: [
            Tab(text: 'Feedback Reviews (${allFeedbacks.length})'),
            Tab(text: 'Media Gallery (${allMedia.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Feedback Moderation
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 85),
            itemCount: allFeedbacks.length,
            itemBuilder: (context, index) {
              final fb = allFeedbacks[index];
              return GlassContainer(
                borderRadius: 20,
                blurSigma: 12,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                glowColor: fb.isFlagged ? AppColors.error : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            fb.eventTitle,
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (fb.isFlagged)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppColors.error.withOpacity(0.18), borderRadius: BorderRadius.circular(6)),
                            child: const Text('FLAGGED ABUSE', style: TextStyle(color: AppColors.error, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('By ${fb.studentName}  •  Rating: ${fb.averageScore.toStringAsFixed(1)}★', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight)),
                    const SizedBox(height: 8),
                    if (fb.comments.isNotEmpty)
                      Text('"${fb.comments}"', style: GoogleFonts.inter(fontSize: 12.5, fontStyle: FontStyle.italic)),
                    Divider(height: 16, color: isDark ? Colors.white12 : AppColors.borderLight),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => feedbackProvider.toggleFeedbackFlag(fb.id, !fb.isFlagged),
                          icon: Icon(fb.isFlagged ? Icons.check_circle_rounded : Icons.flag_outlined, size: 15, color: fb.isFlagged ? AppColors.statusLive : AppColors.error),
                          label: Text(
                            fb.isFlagged ? 'Mark as Approved & Safe' : 'Flag as Inappropriate',
                            style: GoogleFonts.inter(fontSize: 11.5, color: fb.isFlagged ? AppColors.statusLive : AppColors.error, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // Tab 2: Gallery Moderation
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 85),
            itemCount: allMedia.length,
            itemBuilder: (context, index) {
              final media = allMedia[index];
              return GlassContainer(
                borderRadius: 20,
                blurSigma: 12,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        media.mediaUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 72, height: 72, color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(media.caption, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13.5), maxLines: 2, overflow: TextOverflow.ellipsis),
                          Text('${media.eventTitle} • ${media.category}', style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textSecondaryLight)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              InkWell(
                                onTap: () => mediaProvider.toggleFeatured(media.id, !media.isFeatured),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: media.isFeatured ? AppColors.accentGold.withOpacity(0.2) : Colors.grey.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    media.isFeatured ? '★ Featured on Home' : '+ Feature Item',
                                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: media.isFeatured ? AppColors.accentOrange : Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                      onPressed: () => mediaProvider.deleteMedia(media.id),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
