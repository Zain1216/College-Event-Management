import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/registration_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_widgets.dart';

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
    final organizerId = auth.currentUser?.uid ?? '';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final myEvents = eventProvider.allEvents;

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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Live Attendance Scanner', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 85),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Selector Dropdown
            GlassContainer(
              borderRadius: 20,
              blurSigma: 14,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Active Event for Check-in', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondaryLight)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.72),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.2),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        value: myEvents.any((e) => e.id == _selectedEventId) ? _selectedEventId : null,
                        decoration: const InputDecoration(border: InputBorder.none),
                        items: myEvents.map((e) => DropdownMenuItem(value: e.id, child: Text(e.title, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedEventId = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

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

            const SizedBox(height: 18),

            // Interactive QR Camera Scanner Viewfinder Simulation
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0B1329),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.28),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
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
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.secondary, width: 2.5),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 16),
                      ],
                    ),
                  ),

                  // Animated Laser Bar
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return Positioned(
                        top: 45 + (_animController.value * 150),
                        child: Container(
                          width: 170,
                          height: 3.5,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.transparent, AppColors.secondaryLight, Colors.transparent],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondaryLight.withOpacity(0.9),
                                blurRadius: 10,
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          color: Colors.black.withOpacity(0.55),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.camera_alt_rounded, color: AppColors.secondaryLight, size: 15),
                              const SizedBox(width: 6),
                              Text(
                                'Scan Student Digital Pass QR',
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Quick pass verification input
                  Positioned(
                    bottom: 12,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final passController = TextEditingController();
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Enter QR Pass / Ticket Code'),
                            content: TextField(
                              controller: passController,
                              autofocus: true,
                              decoration: const InputDecoration(
                                hintText: 'Paste or type QR Pass code',
                                prefixIcon: Icon(Icons.qr_code),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final code = passController.text.trim();
                                  Navigator.pop(ctx);
                                  if (code.isNotEmpty) {
                                    _processScan(code);
                                  }
                                },
                                child: const Text('Verify & Check In'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 15),
                      label: Text('Enter Pass Code', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),

            if (_scanResult.isNotEmpty) ...[
              const SizedBox(height: 12),
              GlassContainer(
                borderRadius: 16,
                padding: const EdgeInsets.all(12),
                glowColor: _scanResult.startsWith('SUCCESS') ? AppColors.statusLive : AppColors.error,
                child: Row(
                  children: [
                    Icon(
                      _scanResult.startsWith('SUCCESS') ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                      color: _scanResult.startsWith('SUCCESS') ? AppColors.statusLive : AppColors.error,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _scanResult,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 22),

            // Manual Roster Search Header (SRS 1.6 #5)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Registered Attendee Roster',
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.deepNavy),
                ),
                Text(
                  '${eventAttendance.length} / ${eventRegistrations.length} Checked In',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Search Bar
            GlassTextField(
              hintText: 'Search by student name or enrollment number...',
              prefixIcon: Icons.search_rounded,
              onChanged: (val) => setState(() => _manualSearch = val),
            ),

            const SizedBox(height: 12),

            // Attendees List
            if (filteredRegistrations.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text('No registered participants found for this event.', style: GoogleFonts.inter(color: AppColors.textSecondaryLight))),
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

                  return GlassContainer(
                    borderRadius: 18,
                    blurSigma: 12,
                    padding: const EdgeInsets.all(12),
                    glowColor: isAttended ? AppColors.statusLive : null,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isAttended ? AppColors.statusLive.withOpacity(0.18) : AppColors.primaryContainer,
                          child: Icon(
                            isAttended ? Icons.check_rounded : Icons.person_outline_rounded,
                            color: isAttended ? AppColors.statusLive : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(reg.studentName, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13.5)),
                              Text('ID: ${reg.enrollmentNo}  •  ${reg.department}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight)),
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
                                    organizerId: auth.currentUser?.uid ?? '',
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAttended ? Colors.grey.shade200 : AppColors.statusLive,
                            foregroundColor: isAttended ? AppColors.statusLive : Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: Text(
                            isAttended ? '✓ Checked In' : 'Check In',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800),
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
      child: GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        glowColor: color,
        child: Column(
          children: [
            Text(count, style: GoogleFonts.outfit(fontSize: 19, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
