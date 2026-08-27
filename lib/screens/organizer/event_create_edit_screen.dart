import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../theme/app_theme.dart';

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
    _venueController = TextEditingController(text: e?.venue ?? 'Main Campus Auditorium');
    _timeController = TextEditingController(text: e?.time ?? '10:00 AM - 04:00 PM');
    _maxParticipantsController = TextEditingController(text: e?.maxParticipants.toString() ?? '100');
    _bannerUrlController = TextEditingController(text: e?.bannerUrl ?? 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=1200');
    _tagsController = TextEditingController(text: e?.tags.join(', ') ?? 'Tech, Coding, Competition');
    _feeController = TextEditingController(text: e?.certificateFee.toStringAsFixed(0) ?? '50');

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
        status: EventStatus.pending, // SRS 1.6 #5: Events remain in Pending Approval until reviewed by Admin
        organizerId: user?.uid ?? 'usr_org_01',
        organizerName: user?.fullName ?? 'Faculty Organizer',
        organizerEmail: user?.email ?? '',
        organizerPhone: user?.mobile ?? '',
        maxParticipants: maxLimit,
        registeredCount: 0,
        bannerUrl: _bannerUrlController.text.trim(),
        guidelinesPdfUrl: _guidelinesAttached ? 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf' : null,
        coOrganizers: ['Prof. Alan Miller', 'Dr. Sophia Lin'],
        volunteers: ['Zain Ahmed', 'Sarah Connor'],
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

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Event Details' : 'Propose New College Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice banner
              if (!isEdit)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'In accordance with SRS Section 1.6 #5, newly proposed events remain in "Pending Approval" status until reviewed and published by the System Administrator.',
                          style: TextStyle(fontSize: 12, color: AppColors.deepNavy),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Title
              const Text('Event Title *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g. RoboClash 2026: 15kg Combat Arena',
                  prefixIcon: Icon(Icons.title, color: AppColors.primary),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),

              const SizedBox(height: 16),

              // Category & Department row
              Row(
                children: [
                  // Category Dropdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Category *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<EventCategory>(
                          value: _category,
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
                          items: EventCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.displayName, style: const TextStyle(fontSize: 13)))).toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _category = v);
                          },
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
                        const Text('Department *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _department,
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
                          items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _department = v);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Description
              const Text('Detailed Description *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Comprehensive schedule, eligibility rules, judging criteria, prize details...',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Description is required' : null,
              ),

              const SizedBox(height: 16),

              // Date & Time
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Scheduled Date *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(DateFormat('MMM dd, yyyy').format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
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
                        const Text('Event Time *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _timeController,
                          decoration: const InputDecoration(
                            hintText: '10:00 AM - 04:00 PM',
                            prefixIcon: Icon(Icons.schedule, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Venue & Slot limit
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Campus Venue / Hall *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _venueController,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Computing Lab 4',
                            prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
                          ),
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
                        const Text('Capacity Limit *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _maxParticipantsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '150',
                            prefixIcon: Icon(Icons.group, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Banner Image URL
              const Text('Banner Image URL *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _bannerUrlController,
                decoration: const InputDecoration(
                  hintText: 'https://images.unsplash.com/...',
                  prefixIcon: Icon(Icons.image, color: AppColors.primary),
                ),
              ),

              const SizedBox(height: 16),

              // Certificate Fee & Guidelines Attachment
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Certificate Fee (\$) *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _feeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.attach_money, color: AppColors.statusLive),
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
                        const Text('Guidelines PDF Attachment', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.picture_as_pdf, color: AppColors.error, size: 20),
                              const SizedBox(width: 6),
                              const Expanded(child: Text('Guidelines.pdf', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
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

              const SizedBox(height: 16),

              // Tags
              const Text('Search Keywords & Tags (Comma separated)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  hintText: 'Hackathon, AI, Cloud, Coding',
                  prefixIcon: Icon(Icons.tag, color: AppColors.primary),
                ),
              ),

              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submit,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Icon(isEdit ? Icons.save : Icons.send_rounded),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : (isEdit ? 'Save Changes' : 'Submit Event Proposal for Admin Approval'),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
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
