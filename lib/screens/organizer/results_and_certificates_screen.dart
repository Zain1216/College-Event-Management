import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../models/certificate_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/registration_provider.dart';
import '../../providers/certificate_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';

class ResultsAndCertificatesScreen extends StatefulWidget {
  const ResultsAndCertificatesScreen({super.key});

  @override
  State<ResultsAndCertificatesScreen> createState() => _ResultsAndCertificatesScreenState();
}

class _ResultsAndCertificatesScreenState extends State<ResultsAndCertificatesScreen> {
  String _selectedEventId = '';
  final _firstPlaceController = TextEditingController(text: 'Zain Ahmed');
  final _secondPlaceController = TextEditingController(text: 'Sarah Connor');
  final _thirdPlaceController = TextEditingController(text: 'Rohan Verma');
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

    // Issue certificates for all attendees
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

    // Broadcast results announcement
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
      appBar: AppBar(
        title: const Text('Results & Certificate Issuance'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Selector
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Event to Finalize Results', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondaryLight)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: myEvents.any((e) => e.id == _selectedEventId) ? _selectedEventId : null,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                    items: myEvents.map((e) => DropdownMenuItem(value: e.id, child: Text(e.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedEventId = val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Winner Designation Section (SRS 1.6 #5)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accentGold.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.emoji_events, color: AppColors.accentGold, size: 24),
                      SizedBox(width: 10),
                      Text('Designate Competition Winners', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.deepNavy)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 1st Place
                  TextFormField(
                    controller: _firstPlaceController,
                    decoration: const InputDecoration(
                      labelText: '🥇 1st Place Winner (Champion)',
                      prefixIcon: Icon(Icons.workspace_premium, color: AppColors.accentGold),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2nd Place
                  TextFormField(
                    controller: _secondPlaceController,
                    decoration: const InputDecoration(
                      labelText: '🥈 2nd Place Winner (1st Runner Up)',
                      prefixIcon: Icon(Icons.military_tech, color: AppColors.secondaryDark),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3rd Place
                  TextFormField(
                    controller: _thirdPlaceController,
                    decoration: const InputDecoration(
                      labelText: '🥉 3rd Place Winner (2nd Runner Up)',
                      prefixIcon: Icon(Icons.star_half, color: AppColors.accentOrange),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Trigger Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isIssuing ? null : () => _publishResultsAndIssueCerts(selectedEvent),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      icon: _isIssuing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.verified, size: 18),
                      label: const Text('Publish Results & Issue All E-Certificates', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Certificates Issued Roster
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Issued Certificates for this Event', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.deepNavy)),
                Text('${eventCertificates.length} Certificates', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),

            const SizedBox(height: 12),

            if (eventCertificates.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                child: const Text('No certificates issued yet. Click the button above to issue verified certificates to all attendees.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondaryLight)),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: eventCertificates.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, idx) {
                  final cert = eventCertificates[idx];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.school, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cert.studentName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                              Text('${cert.certificateNumber}  •  ${cert.certificateType.displayName}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Preview / Print PDF',
                          icon: const Icon(Icons.print, color: AppColors.primary),
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
