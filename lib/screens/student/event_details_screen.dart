import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/registration_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/feedback_dialog.dart';
import '../../widgets/glass_widgets.dart';
import '../../widgets/role_upgrade_dialog.dart';
import '../common/campus_map_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isRegistering = false;

  Future<void> _handleRegister(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final regProvider = context.read<RegistrationProvider>();

    if (auth.currentUser == null) return;

    // Check if user is visitor (SRS 1.6 #1 & #4)
    if (auth.currentUser!.role.key == 'visitor') {
      final upgraded = await RoleUpgradeDialog.show(context);
      if (upgraded != true) return;
    }

    // Check if profile is missing enrollment number
    if (auth.currentUser!.enrollmentNo == null || auth.currentUser!.enrollmentNo!.isEmpty) {
      final upgraded = await RoleUpgradeDialog.show(context);
      if (upgraded != true) return;
    }

    setState(() => _isRegistering = true);

    final result = await regProvider.registerStudent(
      event: widget.event,
      user: auth.currentUser!,
    );

    setState(() => _isRegistering = false);

    if (mounted) {
      if (result != null) {
        showDialog(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            child: GlassContainer(
              borderRadius: 24,
              blurSigma: 20,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.statusLive.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_rounded, color: AppColors.statusLive, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Text('Registered!', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'You have successfully secured a slot for "${widget.event.title}".',
                    style: GoogleFonts.inter(fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code_2_rounded, color: AppColors.primary, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Digital Pass #${result.qrPassCode.split('-').take(2).join('-')} is ready in My Passes.',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.deepNavy),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Great!'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(regProvider.errorMessage ?? 'Registration failed.'),
          ),
        );
      }
    }
  }

  void _viewGuidelinesPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('OFFICIAL EVENT GUIDELINES & RULES', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text(widget.event.title, style: pw.TextStyle(fontSize: 14, color: PdfColor.fromInt(0xFF1D4ED8))),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 14),
              pw.Text('1. Eligibility: Open to all registered students with valid College ID proof.'),
              pw.SizedBox(height: 6),
              pw.Text('2. Reporting Time: 15 minutes before event start at ${widget.event.venue}.'),
              pw.SizedBox(height: 6),
              pw.Text('3. Digital Check-in: Attendees must present the FusionFiesta in-app QR code pass.'),
              pw.SizedBox(height: 6),
              pw.Text('4. Certificates: Participation & merit certificates issued based on attendance validation.'),
              pw.SizedBox(height: 14),
              pw.Text('Convener: ${widget.event.organizerName} (${widget.event.department})'),
            ],
          ),
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Guidelines_${widget.event.title.replaceAll(' ', '_')}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final regProvider = context.watch<RegistrationProvider>();
    final eventProvider = context.watch<EventProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = auth.currentUser;
    // Use live event from provider so registeredCount/isFull update instantly
    final event = eventProvider.allEvents.firstWhere(
      (e) => e.id == widget.event.id,
      orElse: () => widget.event,
    );
    final isRegistered = user != null && regProvider.isUserRegistered(event.id, user.uid);
    final hasAttended = user != null && regProvider.hasUserAttended(event.id, user.uid);
    final formattedDate = DateFormat('EEEE, MMMM dd, yyyy').format(event.date);

    return AmbientGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            // Sliver App Bar with Banner
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              backgroundColor: Colors.transparent,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.event.title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    shadows: const [Shadow(color: Colors.black, blurRadius: 6)],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.event.bannerUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.35),
                            Colors.transparent,
                            Colors.black.withOpacity(0.85),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.black.withOpacity(0.4),
                        child: IconButton(
                          icon: Icon(
                            user?.bookmarkedEventIds.contains(widget.event.id) ?? false
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => auth.toggleBookmark(widget.event.id),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content Body
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badges Row
                    Row(
                      children: [
                        StatusBadge(
                          status: widget.event.status.displayName,
                          isLive: widget.event.status == EventStatus.live,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Text(
                            widget.event.category.displayName,
                            style: GoogleFonts.inter(
                              color: AppColors.primaryDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (widget.event.averageRating > 0)
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: AppColors.accentGold, size: 20),
                              const SizedBox(width: 3),
                              Text(
                                '${widget.event.averageRating} (${widget.event.reviewCount})',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13),
                              ),
                            ],
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Event Title & Dept
                    Text(
                      widget.event.title,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Organized by ${widget.event.department}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Quick Info Glass Card (Date, Time, Venue)
                    GlassContainer(
                      borderRadius: 20,
                      blurSigma: 16,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.calendar_month_rounded, 'Date', formattedDate),
                          Divider(height: 20, color: isDark ? Colors.white12 : AppColors.borderLight),
                          _buildInfoRow(Icons.schedule_rounded, 'Time', widget.event.time),
                          Divider(height: 20, color: isDark ? Colors.white12 : AppColors.borderLight),
                          _buildInfoRow(
                            Icons.location_on_rounded,
                            'Venue',
                            widget.event.venue,
                            trailing: TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CampusMapScreen(highlightEventId: widget.event.id),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.map_rounded, size: 15),
                              label: Text('Map View', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Capacity & Registration Bar Glass Card
                    GlassContainer(
                      borderRadius: 20,
                      blurSigma: 14,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Seat Availability',
                                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800),
                              ),
                              Text(
                                '${event.registeredCount} / ${event.maxParticipants} Registered',
                                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: (event.registeredCount / event.maxParticipants).clamp(0.0, 1.0),
                              minHeight: 8,
                              backgroundColor: AppColors.primaryContainer.withOpacity(0.5),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                event.isFull ? AppColors.error : AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // About Description Glass Card
                    GlassContainer(
                      borderRadius: 20,
                      blurSigma: 14,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About the Event',
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.event.description,
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              height: 1.55,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          if (widget.event.tags.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: widget.event.tags
                                  .map((t) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                                        ),
                                        child: Text(
                                          '#$t',
                                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Guidelines PDF Action Button
                    GlassButton(
                      label: 'Download Event Guidelines (Official PDF)',
                      icon: Icons.picture_as_pdf_rounded,
                      isPrimary: false,
                      color: AppColors.primaryDark,
                      onPressed: _viewGuidelinesPdf,
                    ),

                    const SizedBox(height: 16),

                    // Organizer Info Glass Box
                    GlassContainer(
                      borderRadius: 18,
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: AppColors.heroGradient,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.event.organizerName,
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13.5),
                                ),
                                Text(
                                  widget.event.organizerEmail,
                                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Winners Section (if announced)
                    if (widget.event.winners.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      GlassContainer(
                        borderRadius: 20,
                        glowColor: AppColors.accentGold,
                        customColor: AppColors.accentGold.withOpacity(0.12),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.emoji_events_rounded, color: AppColors.accentGold, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  'Official Event Winners',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...widget.event.winners.map((w) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Text(w.rank == 1 ? '🥇' : (w.rank == 2 ? '🥈' : '🥉'), style: const TextStyle(fontSize: 18)),
                                      const SizedBox(width: 8),
                                      Text(w.studentName, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                                      const Spacer(),
                                      Text(w.prizeTitle, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight)),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],

                    // Feedback Submission (SRS 1.6 #9)
                    if (hasAttended || widget.event.status == EventStatus.completed) ...[
                      const SizedBox(height: 18),
                      GlassContainer(
                        borderRadius: 20,
                        customColor: AppColors.secondary.withOpacity(0.12),
                        glowColor: AppColors.secondary,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attended this Event?',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rate parameters (Organization, Relevance, Coordination, Overall) to help organizers improve.',
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.deepNavy),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () => FeedbackDialog.show(context, widget.event),
                              icon: const Icon(Icons.star_rounded, size: 16),
                              label: const Text('Submit 4-Parameter Rating'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A).withOpacity(0.85) : Colors.white.withOpacity(0.85),
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.9),
                    width: 1.2,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : AppColors.primary).withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: isRegistered
                    ? OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('You are already registered. Access pass in My Passes.')),
                          );
                        },
                        icon: const Icon(Icons.check_circle_rounded, color: AppColors.statusLive),
                        label: Text('Registered • View Pass in Tab', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
                      )
                    : GlassButton(
                        label: event.isFull
                            ? 'Event Full'
                            : (user?.role.key == 'visitor'
                                ? 'Upgrade Profile & Register'
                                : '1-Click Register for Event'),
                        icon: Icons.touch_app_rounded,
                        isLoading: _isRegistering,
                        onPressed: (_isRegistering || event.isFull)
                            ? null
                            : () => _handleRegister(context),
                        height: 50,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Widget? trailing}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight)),
            Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing,
        ],
      ],
    );
  }
}
