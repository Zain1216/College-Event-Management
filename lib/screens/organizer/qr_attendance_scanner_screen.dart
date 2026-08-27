import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../models/registration_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/registration_provider.dart';
import '../../theme/app_theme.dart';

class QrAttendanceScannerScreen extends StatefulWidget {
  final String? initialEventId;

  const QrAttendanceScannerScreen({super.key, this.initialEventId});

  @override
  State<QrAttendanceScannerScreen> createState() => _QrAttendanceScannerScreenState();
}

class _QrAttendanceScannerScreenState extends State<QrAttendanceScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String _selectedEventId = '';
  String _manualSearch = '';
  String _scanResult = '';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    final eventProvider = context.read<EventProvider>();
    if (widget.initialEventId != null) {
      _selectedEventId = widget.initialEventId!;
    } else if (eventProvider.allEvents.isNotEmpty) {
      _selectedEventId = eventProvider.allEvents.first.id;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _processScan(String rawQr) async {
    final regProvider = context.read<RegistrationProvider>();
    final auth = context.read<AuthProvider>();
    final organizerId = auth.currentUser?.uid ?? 'usr_org_01';

    final result = await regProvider.checkInViaQr(
      rawQrString: rawQr,
      currentEventId: _selectedEventId,
      organizerId: organizerId,
    );

    setState(() => _scanResult = result);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: result.startsWith('SUCCESS') ? AppColors.statusLive : AppColors.error,
          content: Text(result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final regProvider = context.watch<RegistrationProvider>();
    final auth = context.watch<AuthProvider>();

    final myEvents = eventProvider.allEvents;
    final selectedEvent = myEvents.firstWhere(
      (e) => e.id == _selectedEventId,
      orElse: () => myEvents.isNotEmpty
          ? myEvents.first
          : EventModel(
              id: '',
              title: 'No Events',
              description: '',
              category: EventCategory.technical,
              department: '',
              date: DateTime.now(),
              time: '',
              venue: '',
              status: EventStatus.approved,
              organizerId: '',
              organizerName: '',
              maxParticipants: 0,
              bannerUrl: '',
              createdAt: DateTime.now(),
            ),
    );

    final eventRegistrations = regProvider.getRegistrationsForEvent(_selectedEventId);
    final eventAttendance = regProvider.getAttendanceForEvent(_selectedEventId);
    final attendedStudentIds = eventAttendance.map((a) => a.studentId).toSet();

    final filteredRegistrations = eventRegistrations.where((r) {
      if (_manualSearch.trim().isEmpty) return true;
      final q = _manualSearch.toLowerCase();
      return r.studentName.toLowerCase().contains(q) ||
          r.enrollmentNo.toLowerCase().contains(q) ||
          r.department.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live QR Attendance Scanner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Selector Dropdown
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
                  const Text('Select Active Event for Check-in', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondaryLight)),
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

            const SizedBox(height: 16),

            // Live Attendance Statistics Banner
            Row(
              children: [
                _buildCountTile('Registered', '${eventRegistrations.length}', AppColors.primary),
                const SizedBox(width: 8),
                _buildCountTile('Attended', '${eventAttendance.length}', AppColors.statusLive),
                const SizedBox(width: 8),
                _buildCountTile(
                  'Turnout Rate',
                  eventRegistrations.isEmpty ? '0%' : '${((eventAttendance.length / eventRegistrations.length) * 100).toStringAsFixed(0)}%',
                  AppColors.secondaryDark,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Interactive QR Camera Scanner Viewfinder Simulation
            Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.deepNavy,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Camera grid background
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.15,
                      child: GridPaper(
                        color: AppColors.secondary,
                        divisions: 2,
                        subdivisions: 2,
                      ),
                    ),
                  ),

                  // Scanning Frame
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.secondary, width: 2.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  // Animated Laser Bar
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return Positioned(
                        top: 40 + (_animController.value * 160),
                        child: Container(
                          width: 180,
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.transparent, AppColors.secondaryLight, Colors.transparent],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondaryLight.withOpacity(0.8),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Top instruction
                  Positioned(
                    top: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt, color: AppColors.secondaryLight, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'Point Camera at Student Digital Pass QR',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Quick test trigger buttons
                  Positioned(
                    bottom: 12,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // Simulate scanning first registered student's QR
                            if (eventRegistrations.isNotEmpty) {
                              _processScan(eventRegistrations.first.qrPassCode);
                            } else {
                              _processScan('FF-PASS|$_selectedEventId|usr_student_01|CS-2023-089|Zain Ahmed|PASS-DEMO');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          icon: const Icon(Icons.flash_on, size: 14),
                          label: const Text('Simulate Instant Scan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (_scanResult.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _scanResult.startsWith('SUCCESS') ? AppColors.statusLive.withOpacity(0.15) : AppColors.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _scanResult.startsWith('SUCCESS') ? AppColors.statusLive : AppColors.error),
                ),
                child: Row(
                  children: [
                    Icon(
                      _scanResult.startsWith('SUCCESS') ? Icons.check_circle : Icons.error_outline,
                      color: _scanResult.startsWith('SUCCESS') ? AppColors.statusLive : AppColors.error,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _scanResult,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Manual Roster Search Header (SRS 1.6 #5)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Registered Attendee Roster', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.deepNavy)),
                Text('${eventAttendance.length} / ${eventRegistrations.length} Checked In', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),

            const SizedBox(height: 10),

            // Search Bar
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search by student name or enrollment number...',
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
              ),
              onChanged: (val) => setState(() => _manualSearch = val),
            ),

            const SizedBox(height: 12),

            // Attendees List
            if (filteredRegistrations.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No registered participants found for this event.')),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredRegistrations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, idx) {
                  final reg = filteredRegistrations[idx];
                  final isAttended = attendedStudentIds.contains(reg.studentId);

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isAttended ? AppColors.statusLive.withOpacity(0.5) : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isAttended ? AppColors.statusLive.withOpacity(0.15) : AppColors.primaryContainer,
                          child: Icon(
                            isAttended ? Icons.check : Icons.person_outline,
                            color: isAttended ? AppColors.statusLive : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(reg.studentName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                              Text('ID: ${reg.enrollmentNo}  •  ${reg.department}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: isAttended
                              ? null
                              : () => regProvider.checkInManual(
                                    eventId: _selectedEventId,
                                    studentId: reg.studentId,
                                    studentName: reg.studentName,
                                    enrollmentNo: reg.enrollmentNo,
                                    department: reg.department,
                                    organizerId: auth.currentUser?.uid ?? 'usr_org_01',
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAttended ? Colors.grey.shade200 : AppColors.statusLive,
                            foregroundColor: isAttended ? AppColors.statusLive : Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: Text(
                            isAttended ? '✓ Checked In' : 'Check In',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                          ),
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

  Widget _buildCountTile(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
