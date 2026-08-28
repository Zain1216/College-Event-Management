import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../models/certificate_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/registration_provider.dart';
import '../../providers/certificate_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_widgets.dart';

class ResultsAndCertificatesScreen extends StatefulWidget {
  const ResultsAndCertificatesScreen({super.key});

  @override
  State<ResultsAndCertificatesScreen> createState() => _ResultsAndCertificatesScreenState();
}

class _ResultsAndCertificatesScreenState extends State<ResultsAndCertificatesScreen> {
  String _selectedEventId = '';
  final _firstPlaceController = TextEditingController();
  final _secondPlaceController = TextEditingController();
  final _thirdPlaceController = TextEditingController();
  bool _isIssuing = false;

  @override
  void initState() {
    super.initState();
    final eventProvider = context.read<EventProvider>();
    if (eventProvider.allEvents.isNotEmpty) {
      _selectedEventId = eventProvider.allEvents.first.id;
    }
  }

  @override
  void dispose() {
    _firstPlaceController.dispose();
    _secondPlaceController.dispose();
    _thirdPlaceController.dispose();
    super.dispose();
  }

  Future<void> _publishResultsAndIssueCerts(EventModel event) async {
    setState(() => _isIssuing = true);

    final certProvider = context.read<CertificateProvider>();
    final regProvider = context.read<RegistrationProvider>();
    final notifProvider = context.read<NotificationProvider>();
    final auth = context.read<AuthProvider>();

    final eventRegistrations = regProvider.getRegistrationsForEvent(event.id);

    int certsIssued = 0;
    for (var reg in eventRegistrations) {
      CertificateType type = CertificateType.participation;
      if (reg.studentName.toLowerCase().contains(_firstPlaceController.text.toLowerCase().trim()) && _firstPlaceController.text.isNotEmpty) {
        type = CertificateType.winnerFirst;
      } else if (reg.studentName.toLowerCase().contains(_secondPlaceController.text.toLowerCase().trim()) && _secondPlaceController.text.isNotEmpty) {
        type = CertificateType.winnerSecond;
      } else if (reg.studentName.toLowerCase().contains(_thirdPlaceController.text.toLowerCase().trim()) && _thirdPlaceController.text.isNotEmpty) {
        type = CertificateType.winnerThird;
      }

      await certProvider.issueCertificate(
        event: event,
        studentId: reg.studentId,
        studentName: reg.studentName,
        enrollmentNo: reg.enrollmentNo,
        department: reg.department,
        type: type,
        issuedBy: auth.currentUser?.fullName ?? 'Event Committee',
      );
      certsIssued++;
    }

    await notifProvider.broadcastAnnouncement(
      title: '🏆 Results Published for "${event.title}"',
      message: '1st Place: ${_firstPlaceController.text} | 2nd Place: ${_secondPlaceController.text}. E-Certificates have been attached to participant vaults.',
      eventId: event.id,
      targetRole: 'participant',
    );

    setState(() => _isIssuing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.statusLive,
          content: Text('🎉 Results published and $certsIssued e-certificates issued successfully!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final certProvider = context.watch<CertificateProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final myEvents = eventProvider.allEvents;
    final selectedEvent = myEvents.firstWhere(
      (e) => e.id == _selectedEventId,
      orElse: () => myEvents.isNotEmpty ? myEvents.first : EventModel(
        id: '',
        title: 'Select Event',
        description: '',
        category: EventCategory.technical,
        department: '',
        date: DateTime.now(),
        time: '',
        venue: '',
        status: EventStatus.completed,
        organizerId: '',
        organizerName: '',
        maxParticipants: 0,
        bannerUrl: '',
        createdAt: DateTime.now(),
      ),
    );

    final eventCertificates = certProvider.getCertificatesForEvent(_selectedEventId);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Results & Certificates', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 85),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Selector
            GlassContainer(
              borderRadius: 20,
              blurSigma: 14,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Event to Finalize Results', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondaryLight)),
                  const SizedBox(height: 6),
                  GlassDropdown<String>(
                    value: myEvents.any((e) => e.id == _selectedEventId) ? _selectedEventId : (myEvents.isNotEmpty ? myEvents.first.id : null),
                    prefixIcon: Icons.event_rounded,
                    items: myEvents
                        .map((e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(e.title, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedEventId = val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Winner Designation Section (SRS 1.6 #5)
            GlassContainer(
              borderRadius: 24,
              blurSigma: 16,
              glowColor: AppColors.accentGold,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text('Designate Winners', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.deepNavy)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 1st Place
                  GlassTextField(
                    controller: _firstPlaceController,
                    labelText: '🥇 1st Place Winner (Champion)',
                    prefixIcon: Icons.workspace_premium_rounded,
                  ),
                  const SizedBox(height: 12),

                  // 2nd Place
                  GlassTextField(
                    controller: _secondPlaceController,
                    labelText: '🥈 2nd Place Winner (1st Runner Up)',
                    prefixIcon: Icons.military_tech_rounded,
                  ),
                  const SizedBox(height: 12),

                  // 3rd Place
                  GlassTextField(
                    controller: _thirdPlaceController,
                    labelText: '🥉 3rd Place Winner (2nd Runner Up)',
                    prefixIcon: Icons.star_half_rounded,
                  ),

                  const SizedBox(height: 20),

                  // Trigger Button
                  GlassButton(
                    label: 'Publish Results & Issue All E-Certificates',
                    icon: Icons.verified_rounded,
                    isLoading: _isIssuing,
                    onPressed: _isIssuing ? null : () => _publishResultsAndIssueCerts(selectedEvent),
                    height: 50,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Certificates Issued Roster
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Issued Certificates for this Event',
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.deepNavy),
                ),
                Text(
                  '${eventCertificates.length} Certificates',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (eventCertificates.isEmpty)
              GlassContainer(
                borderRadius: 18,
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No certificates issued yet. Fill winners above and issue verified certificates to all attendees.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: AppColors.textSecondaryLight),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: eventCertificates.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, idx) {
                  final cert = eventCertificates[idx];
                  return GlassContainer(
                    borderRadius: 16,
                    blurSigma: 12,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cert.studentName, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13.5)),
                              Text('${cert.certificateNumber}  •  ${cert.certificateType.displayName}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight)),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Preview / Print PDF',
                          icon: const Icon(Icons.print_rounded, color: AppColors.primary),
                          onPressed: () => certProvider.downloadCertificate(cert),
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
