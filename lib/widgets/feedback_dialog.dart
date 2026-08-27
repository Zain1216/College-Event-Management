import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../providers/auth_provider.dart';
import '../providers/feedback_provider.dart';
import '../theme/app_theme.dart';
import 'glass_widgets.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        borderRadius: 26,
        blurSigma: 24,
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
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.rate_review_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Event Feedback & Rating',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          widget.event.title,
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              Divider(color: Colors.white.withOpacity(0.6)),
              const SizedBox(height: 12),

              // Average Score Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Calculated Average Score', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.accentGold, size: 22),
                        const SizedBox(width: 4),
                        Text(
                          '${avg.toStringAsFixed(1)} / 5.0',
                          style: GoogleFonts.outfit(
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

              // Parameter 1
              _buildStarRow('1. Event Organization & Punctuality', _orgRating, (v) => setState(() => _orgRating = v)),
              const SizedBox(height: 10),

              // Parameter 2
              _buildStarRow('2. Content Quality & Topic Relevance', _relRating, (v) => setState(() => _relRating = v)),
              const SizedBox(height: 10),

              // Parameter 3
              _buildStarRow('3. Host & Volunteer Coordination', _coordRating, (v) => setState(() => _coordRating = v)),
              const SizedBox(height: 10),

              // Parameter 4
              _buildStarRow('4. Overall Experience & Value', _overallRating, (v) => setState(() => _overallRating = v)),

              const SizedBox(height: 16),

              // Written feedback
              Text('Your Review / Suggestions', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              GlassTextField(
                controller: _commentController,
                hintText: 'Share your thoughts, recommendations, or shoutouts to organizers...',
                maxLines: 3,
              ),

              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
                      child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GlassButton(
                      label: 'Submit Feedback',
                      icon: Icons.send_rounded,
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _submit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStarRow(String label, int currentVal, Function(int) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight)),
        const SizedBox(height: 4),
        Row(
          children: List.generate(5, (index) {
            final starVal = index + 1;
            final isFilled = starVal <= currentVal;
            return InkWell(
              onTap: () => onSelect(starVal),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isFilled ? AppColors.accentGold : Colors.grey.shade400,
                  size: 26,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
