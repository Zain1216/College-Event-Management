import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../providers/auth_provider.dart';
import '../providers/feedback_provider.dart';
import '../theme/app_theme.dart';

class FeedbackDialog extends StatefulWidget {
  final EventModel event;

  const FeedbackDialog({super.key, required this.event});

  static Future<bool?> show(BuildContext context, EventModel event) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => FeedbackDialog(event: event),
    );
  }

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  int _orgRating = 5;
  int _relRating = 5;
  int _coordRating = 5;
  int _overallRating = 5;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final fbProvider = context.read<FeedbackProvider>();

    if (auth.currentUser == null) return;

    setState(() => _isSubmitting = true);

    final success = await fbProvider.submitFeedback(
      eventId: widget.event.id,
      eventTitle: widget.event.title,
      studentId: auth.currentUser!.uid,
      studentName: auth.currentUser!.fullName,
      organizationRating: _orgRating,
      relevanceRating: _relRating,
      coordinationRating: _coordRating,
      overallRating: _overallRating,
      comments: _commentController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.statusLive,
            content: Text('🌟 Thank you! Your event feedback has been submitted successfully.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(fbProvider.errorMessage ?? 'Submission failed.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final avg = (_orgRating + _relRating + _coordRating + _overallRating) / 4.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.rate_review, color: AppColors.secondaryDark, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Event Feedback & Rating',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          widget.event.title,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(color: AppColors.borderLight),
              const SizedBox(height: 12),

              // Average Score Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Overall Score Calculated', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.accentGold, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${avg.toStringAsFixed(1)} / 5.0',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.deepNavy,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4 Required Criteria (SRS 1.6 #9)
              _buildRatingRow('1. Event Organization', _orgRating, (v) => setState(() => _orgRating = v)),
              _buildRatingRow('2. Content Relevance', _relRating, (v) => setState(() => _relRating = v)),
              _buildRatingRow('3. Staff Coordination', _coordRating, (v) => setState(() => _coordRating = v)),
              _buildRatingRow('4. Overall Experience', _overallRating, (v) => setState(() => _overallRating = v)),

              const SizedBox(height: 14),

              // Comments input
              const Text('Comments & Suggestions (Optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Share what you enjoyed or what could be improved for next time...',
                ),
              ),

              const SizedBox(height: 20),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Submit Feedback'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingRow(String label, int currentVal, ValueChanged<int> onSelect) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return InkWell(
                onTap: () => onSelect(starIndex),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    starIndex <= currentVal ? Icons.star : Icons.star_border,
                    color: starIndex <= currentVal ? AppColors.accentGold : AppColors.borderDark,
                    size: 24,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
