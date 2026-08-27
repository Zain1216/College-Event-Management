import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_widgets.dart';

class EventCreateEditScreen extends StatefulWidget {
  final EventModel? existingEvent;

  const EventCreateEditScreen({super.key, this.existingEvent});

  @override
  State<EventCreateEditScreen> createState() => _EventCreateEditScreenState();
}

class _EventCreateEditScreenState extends State<EventCreateEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _venueController;
  late TextEditingController _timeController;
  late TextEditingController _maxParticipantsController;
  late TextEditingController _bannerUrlController;
  late TextEditingController _tagsController;
  late TextEditingController _feeController;

  EventCategory _category = EventCategory.technical;
  String _department = 'Computer Science & Engineering';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  bool _guidelinesAttached = true;
  bool _isSaving = false;

  final List<String> _departments = [
    'Computer Science & Engineering',
    'Information Technology',
    'Mechanical & Robotics',
    'Fine Arts & Music Society',
    'Physical Education',
    'Research & Development Wing',
    'Business Administration',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existingEvent;
    _titleController = TextEditingController(text: e?.title ?? '');
    _descController = TextEditingController(text: e?.description ?? '');
    _venueController = TextEditingController(text: e?.venue ?? '');
    _timeController = TextEditingController(text: e?.time ?? '');
    _maxParticipantsController = TextEditingController(text: e?.maxParticipants.toString() ?? '100');
    _bannerUrlController = TextEditingController(text: e?.bannerUrl ?? '');
    _tagsController = TextEditingController(text: e?.tags.join(', ') ?? '');
    _feeController = TextEditingController(text: e?.certificateFee.toStringAsFixed(0) ?? '0');

    if (e != null) {
      _category = e.category;
      _department = e.department;
      _selectedDate = e.date;
      _guidelinesAttached = e.guidelinesPdfUrl != null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _venueController.dispose();
    _timeController.dispose();
    _maxParticipantsController.dispose();
    _bannerUrlController.dispose();
    _tagsController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final auth = context.read<AuthProvider>();
    final eventProvider = context.read<EventProvider>();
    final user = auth.currentUser;

    final tagsList = _tagsController.text.split(',').map((s) => s.trim().replaceAll('#', '')).where((s) => s.isNotEmpty).toList();
    final maxLimit = int.tryParse(_maxParticipantsController.text.trim()) ?? 100;
    final fee = double.tryParse(_feeController.text.trim()) ?? 50.0;

    if (widget.existingEvent != null) {
      final updated = widget.existingEvent!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _category,
        department: _department,
        date: _selectedDate,
        time: _timeController.text.trim(),
        venue: _venueController.text.trim(),
        maxParticipants: maxLimit,
        bannerUrl: _bannerUrlController.text.trim(),
        tags: tagsList,
        certificateFee: fee,
      );
      await eventProvider.updateEvent(updated);
    } else {
      final newEvent = EventModel(
        id: 'evt_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _category,
        department: _department,
        date: _selectedDate,
        time: _timeController.text.trim(),
        venue: _venueController.text.trim(),
        status: EventStatus.pending,
        organizerId: user?.uid ?? '',
        organizerName: user?.fullName ?? 'Faculty Organizer',
        organizerEmail: user?.email ?? '',
        organizerPhone: user?.mobile ?? '',
        maxParticipants: maxLimit,
        registeredCount: 0,
        bannerUrl: _bannerUrlController.text.trim().isNotEmpty
            ? _bannerUrlController.text.trim()
            : 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=1200',
        guidelinesPdfUrl: _guidelinesAttached ? 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf' : null,
        coOrganizers: [],
        volunteers: [],
        tags: tagsList,
        certificateFee: fee,
        createdAt: DateTime.now(),
      );
      await eventProvider.createEvent(newEvent);
    }

    setState(() => _isSaving = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.statusLive,
          content: Text(widget.existingEvent != null
              ? '✅ Event details updated.'
              : '📋 Event proposal submitted! Sent to Admin for review.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingEvent != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Event Details' : 'Propose New College Event', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 85),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice banner
              if (!isEdit)
                GlassContainer(
                  borderRadius: 20,
                  blurSigma: 14,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'In accordance with SRS Section 1.6 #5, newly proposed events remain in "Pending Approval" status until reviewed and published by Admin.',
                          style: GoogleFonts.inter(fontSize: 11.5, color: isDark ? Colors.white : AppColors.deepNavy),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              GlassContainer(
                borderRadius: 24,
                blurSigma: 16,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text('Event Title *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    GlassTextField(
                      controller: _titleController,
                      hintText: 'e.g. RoboClash 2026: 15kg Combat Arena',
                      prefixIcon: Icons.title_rounded,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                    ),

                    const SizedBox(height: 14),

                    // Category & Department row
                    Row(
                      children: [
                        // Category Dropdown
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Category *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.72),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.2),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButtonFormField<EventCategory>(
                                    value: _category,
                                    decoration: const InputDecoration(border: InputBorder.none),
                                    items: EventCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.displayName, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600)))).toList(),
                                    onChanged: (v) {
                                      if (v != null) setState(() => _category = v);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Department Dropdown
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Department *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w800)),
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
                                    value: _department,
                                    decoration: const InputDecoration(border: InputBorder.none),
                                    items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis))).toList(),
                                    onChanged: (v) {
                                      if (v != null) setState(() => _department = v);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Description
                    Text('Detailed Description *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    GlassTextField(
                      controller: _descController,
                      maxLines: 4,
                      hintText: 'Comprehensive schedule, eligibility rules, judging criteria, prize details...',
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Description is required' : null,
                    ),

                    const SizedBox(height: 14),

                    // Date & Time
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Scheduled Date *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: _pickDate,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.72),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.2),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Text(DateFormat('MMM dd, yyyy').format(_selectedDate), style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12.5)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Event Time *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              GlassTextField(
                                controller: _timeController,
                                hintText: '10:00 AM - 04:00 PM',
                                prefixIcon: Icons.schedule_rounded,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Venue & Slot limit
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Campus Venue / Hall *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              GlassTextField(
                                controller: _venueController,
                                hintText: 'e.g. Computing Lab 4',
                                prefixIcon: Icons.location_on_outlined,
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Venue is required' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Capacity *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              GlassTextField(
                                controller: _maxParticipantsController,
                                keyboardType: TextInputType.number,
                                hintText: '150',
                                prefixIcon: Icons.group_outlined,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Banner Image URL
                    Text('Banner Image URL *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    GlassTextField(
                      controller: _bannerUrlController,
                      hintText: 'https://images.unsplash.com/...',
                      prefixIcon: Icons.image_outlined,
                    ),

                    const SizedBox(height: 14),

                    // Certificate Fee & Guidelines Attachment
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Certificate Fee (\$) *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              GlassTextField(
                                controller: _feeController,
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.attach_money_rounded,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Guidelines PDF', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.72),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.2),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error, size: 20),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text('PDF', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800))),
                                    Switch(
                                      value: _guidelinesAttached,
                                      activeColor: AppColors.primary,
                                      onChanged: (val) => setState(() => _guidelinesAttached = val),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Tags
                    Text('Search Keywords & Tags', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    GlassTextField(
                      controller: _tagsController,
                      hintText: 'Hackathon, AI, Cloud, Coding',
                      prefixIcon: Icons.tag_rounded,
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    GlassButton(
                      label: isEdit ? 'Save Changes' : 'Submit Event Proposal',
                      icon: isEdit ? Icons.save_rounded : Icons.send_rounded,
                      isLoading: _isSaving,
                      onPressed: _isSaving ? null : _submit,
                      height: 50,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
