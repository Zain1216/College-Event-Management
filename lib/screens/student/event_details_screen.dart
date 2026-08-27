import 'package:flutter/material.dart';
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
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.statusLive, size: 28),
                SizedBox(width: 10),
                Text('Registered!', style: TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You have successfully secured a slot for "${widget.event.title}".',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code_2, color: AppColors.primary, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Digital Pass #${result.qrPassCode.split('-').take(2).join('-')} is ready in My Passes.',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.deepNavy),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Great!'),
              ),
            ],
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
    // Generate a clean guidelines preview document
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

    final user = auth.currentUser;
    final isRegistered = user != null && regProvider.isUserRegistered(widget.event.id, user.uid);
    final hasAttended = user != null && regProvider.hasUserAttended(widget.event.id, user.uid);
    final formattedDate = DateFormat('EEEE, MMMM dd, yyyy').format(widget.event.date);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Banner Image
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.event.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
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
                    errorBuilder: (_, __, ___) => Container(color: AppColors.primaryDark),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  user?.bookmarkedEventIds.contains(widget.event.id) ?? false
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: Colors.white,
                ),
                onPressed: () => auth.toggleBookmark(widget.event.id),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          widget.event.category.displayName,
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (widget.event.averageRating > 0)
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.accentGold, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.event.averageRating} (${widget.event.reviewCount})',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                          ],
                        ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Event Title
                  Text(
                    widget.event.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),

                  const SizedBox(height: 6),
                  Text(
                    'Organized by ${widget.event.department}',
                    style: const TextStyle(fontSize: 13, color: AppColors.secondaryDark, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 20),

                  // Quick Info Cards (Date, Time, Venue)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.calendar_month, 'Date', formattedDate),
                        const Divider(height: 20, color: AppColors.borderLight),
                        _buildInfoRow(Icons.schedule, 'Time', widget.event.time),
                        const Divider(height: 20, color: AppColors.borderLight),
                        _buildInfoRow(
                          Icons.location_on,
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
                            icon: const Icon(Icons.map, size: 14),
                            label: const Text('View on Map', style: TextStyle(fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Capacity & Registration Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Seat Availability',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              '${widget.event.registeredCount} / ${widget.event.maxParticipants} Registered',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (widget.event.registeredCount / widget.event.maxParticipants).clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: AppColors.borderLight,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.event.isFull ? AppColors.error : AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description
                  const Text('About the Event', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    widget.event.description,
                    style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondaryLight),
                  ),

                  const SizedBox(height: 20),

                  // Tags
                  if (widget.event.tags.isNotEmpty) ...[
                    const Text('Tags', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: widget.event.tags
                          .map((t) => Chip(
                                label: Text('#$t', style: const TextStyle(fontSize: 11)),
                                backgroundColor: AppColors.backgroundLight,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Guidelines PDF & Organizer Contacts
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _viewGuidelinesPdf,
                          icon: const Icon(Icons.picture_as_pdf, color: AppColors.error),
                          label: const Text('Event Guidelines (PDF)'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Organizer Info Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.primaryContainer,
                          child: Icon(Icons.person, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.event.organizerName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                              Text(widget.event.organizerEmail, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                            ],
                          ),
                        ),
                        if (widget.event.organizerPhone.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.phone, size: 16, color: AppColors.secondaryDark),
                          ),
                      ],
                    ),
                  ),

                  // Winners Section (if completed / announced)
                  if (widget.event.winners.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient.scale(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.accentGold),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.emoji_events, color: AppColors.accentGold),
                              SizedBox(width: 8),
                              Text('Official Event Winners', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...widget.event.winners.map((w) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    Text(w.rank == 1 ? '🥇' : (w.rank == 2 ? '🥈' : '🥉'), style: const TextStyle(fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Text(w.studentName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                    const Spacer(),
                                    Text(w.prizeTitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],

                  // Feedback Submission (SRS 1.6 #9)
                  if (hasAttended || widget.event.status == EventStatus.completed) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Attended this Event?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          const SizedBox(height: 4),
                          const Text('Rate parameters (Organization, Relevance, Coordination, Overall) to help organizers improve.', style: TextStyle(fontSize: 12, color: AppColors.deepNavy)),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () => FeedbackDialog.show(context, widget.event),
                            icon: const Icon(Icons.star, size: 16),
                            label: const Text('Submit 4-Parameter Rating'),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 80), // bottom bar spacing
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: isRegistered
                    ? OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('You are already registered. Access pass in My Passes.')),
                          );
                        },
                        icon: const Icon(Icons.check_circle, color: AppColors.statusLive),
                        label: const Text('Registered • View Pass in Tab'),
                      )
                    : ElevatedButton.icon(
                        onPressed: (_isRegistering || widget.event.isFull)
                            ? null
                            : () => _handleRegister(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: _isRegistering
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.touch_app),
                        label: Text(
                          widget.event.isFull
                              ? 'Event Full'
                              : (user?.role.key == 'visitor'
                                  ? 'Upgrade Profile & Register (1-Click)'
                                  : '1-Click Register for Event'),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Widget? trailing}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
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
