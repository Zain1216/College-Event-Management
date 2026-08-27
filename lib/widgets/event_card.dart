import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'app_logo.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBookmarked = auth.currentUser?.bookmarkedEventIds.contains(event.id) ?? false;
    final formattedDate = DateFormat('EEE, MMM dd').format(event.date);

    final slotPercent = event.maxParticipants > 0
        ? (event.registeredCount / event.maxParticipants).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primary).withOpacity(isDark ? 0.35 : 0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A).withOpacity(0.68)
                  : Colors.white.withOpacity(0.78),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.14)
                    : Colors.white.withOpacity(0.85),
                width: 1.3,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Image & Floating Glass Overlay Chips
                    Stack(
                      children: [
                        SizedBox(
                          height: 160,
                          width: double.infinity,
                          child: Image.network(
                            event.bannerUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              decoration: const BoxDecoration(
                                gradient: AppColors.heroGradient,
                              ),
                              child: const Center(
                                child: Icon(Icons.event_rounded, color: Colors.white, size: 48),
                              ),
                            ),
                          ),
                        ),
                        // Dark gradient overlay for text legibility
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.40),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.70),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Floating Status Badge
                        Positioned(
                          top: 12,
                          left: 12,
                          child: StatusBadge(
                            status: event.status.displayName,
                            isLive: event.status == EventStatus.live,
                          ),
                        ),
                        // Frosted Category Chip
                        Positioned(
                          top: 12,
                          right: 12,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.deepNavy.withOpacity(0.75),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.secondary.withOpacity(0.6), width: 1),
                                ),
                                child: Text(
                                  event.category.displayName,
                                  style: GoogleFonts.inter(
                                    color: AppColors.secondaryLight,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Circular Glass Bookmark button
                        Positioned(
                          bottom: 10,
                          right: 12,
                          child: ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: InkWell(
                                onTap: () => auth.toggleBookmark(event.id),
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.85),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1.2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                    color: isBookmarked ? AppColors.primary : AppColors.textSecondaryLight,
                                    size: 19,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Department glass tag
                        Positioned(
                          bottom: 10,
                          left: 12,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.55),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.8),
                                ),
                                child: Text(
                                  event.department,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Card Body Details
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title & Top Rated Badge
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  event.title,
                                  style: GoogleFonts.outfit(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (event.isTopRated || event.averageRating >= 4.5) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.goldGradient,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accentGold.withOpacity(0.35),
                                        blurRadius: 6,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.star_rounded, color: Colors.white, size: 12),
                                      SizedBox(width: 2),
                                      Text(
                                        'TOP RATED',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Date, Time & Venue
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                '$formattedDate • ${event.time}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.secondaryDark),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  event.venue,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (event.averageRating > 0) ...[
                                const Icon(Icons.star_rounded, size: 15, color: AppColors.accentGold),
                                const SizedBox(width: 2),
                                Text(
                                  '${event.averageRating} (${event.reviewCount})',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 12),
                          Divider(height: 1, color: isDark ? Colors.white12 : AppColors.borderLight),
                          const SizedBox(height: 10),

                          // Slot Capacity Progress
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                event.isFull
                                    ? '🚫 Registration Full'
                                    : '${event.availableSlots} slots remaining',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: event.isFull ? AppColors.error : AppColors.primaryDark,
                                ),
                              ),
                              Text(
                                '${event.registeredCount} / ${event.maxParticipants} Registered',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: slotPercent,
                              minHeight: 6,
                              backgroundColor: AppColors.primaryContainer.withOpacity(0.5),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                event.isFull
                                    ? AppColors.error
                                    : (slotPercent > 0.8 ? AppColors.accentOrange : AppColors.secondary),
                              ),
                            ),
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
      ),
    );
  }
}
