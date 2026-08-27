import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/feedback_provider.dart';
import '../../providers/media_provider.dart';
import '../../theme/app_theme.dart';

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

    final allFeedbacks = feedbackProvider.allFeedbacks;
    final allMedia = mediaProvider.allMedia;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Quality & Moderation Hub'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
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
            padding: const EdgeInsets.all(16),
            itemCount: allFeedbacks.length,
            itemBuilder: (context, index) {
              final fb = allFeedbacks[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: fb.isFlagged ? AppColors.error : AppColors.borderLight,
                    width: fb.isFlagged ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            fb.eventTitle,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (fb.isFlagged)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.error.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                            child: const Text('FLAGGED SPAM/ABUSE', style: TextStyle(color: AppColors.error, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('By ${fb.studentName}  •  Rating: ${fb.averageScore.toStringAsFixed(1)}★', style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                    const SizedBox(height: 8),
                    if (fb.comments.isNotEmpty)
                      Text('"${fb.comments}"', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                    const Divider(height: 16, color: AppColors.borderLight),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => feedbackProvider.toggleFeedbackFlag(fb.id, !fb.isFlagged),
                          icon: Icon(fb.isFlagged ? Icons.check_circle : Icons.flag_outlined, size: 14, color: fb.isFlagged ? AppColors.statusLive : AppColors.error),
                          label: Text(
                            fb.isFlagged ? 'Mark as Approved & Safe' : 'Flag as Inappropriate',
                            style: TextStyle(fontSize: 11, color: fb.isFlagged ? AppColors.statusLive : AppColors.error, fontWeight: FontWeight.bold),
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
            padding: const EdgeInsets.all(16),
            itemCount: allMedia.length,
            itemBuilder: (context, index) {
              final media = allMedia[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        media.mediaUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 70, height: 70, color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(media.caption, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                          Text('${media.eventTitle} • ${media.category}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              InkWell(
                                onTap: () => mediaProvider.toggleFeatured(media.id, !media.isFeatured),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: media.isFeatured ? AppColors.accentGold.withOpacity(0.2) : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    media.isFeatured ? '★ Featured on Home' : '+ Feature Item',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: media.isFeatured ? AppColors.accentOrange : Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
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
