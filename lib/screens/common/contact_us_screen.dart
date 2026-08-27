import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/contact_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../theme/app_theme.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _category = 'General';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'General',
    'Event Registration',
    'Certificate Issue / Payment',
    'Technical Support',
    'Sponsorship & Volunteering',
  ];

  final List<FaqItem> _faqs = const [
    FaqItem(
      question: 'How do I register for an event as a new student?',
      answer: 'Sign in to your account. If you are a Student Visitor, tap "Upgrade to Participant" to complete your enrollment number and department. Once verified, you can 1-click register for any open event.',
      category: 'Registration',
    ),
    FaqItem(
      question: 'Where can I access my digital entry QR pass?',
      answer: 'After successful 1-click registration, your entry ticket with encrypted QR pass is automatically placed in your "My Passes" tab for gate check-in.',
      category: 'Tickets',
    ),
    FaqItem(
      question: 'How do I unlock and download my participation certificate?',
      answer: 'Certificates are issued by the event convener upon attendance confirmation. Once visible in your Certificate Vault, complete the simulated certificate processing fee (\$50.00) to permanently unlock the high-resolution vector PDF.',
      category: 'Certificates',
    ),
    FaqItem(
      question: 'Can I propose a new college fest or competition?',
      answer: 'Yes! Faculty members and verified student council leads with "Event Organizer" role can fill out the structured Event Creation form. Proposals are submitted to the Principal/Admin for review.',
      category: 'Organizers',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    if (auth.currentUser != null) {
      _nameController.text = auth.currentUser!.fullName;
      _emailController.text = auth.currentUser!.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitQuery() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final adminProvider = context.read<AdminProvider>();

    await adminProvider.submitContactQuery(
      name: _nameController.text,
      email: _emailController.text,
      subject: _subjectController.text,
      category: _category,
      message: _messageController.text,
    );

    _subjectController.clear();
    _messageController.clear();
    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.statusLive,
          content: Text('✅ Your query has been delivered to the Administration team. We will reply shortly!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Support & FAQs'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Support Form Card (SRS 1.6 #12)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.mail_outline, color: AppColors.primary, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Submit an Inquiry to Admin',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.deepNavy),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Your Name *',
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 12),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address *',
                        prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Email is required' : null,
                    ),
                    const SizedBox(height: 12),

                    // Category
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(
                        labelText: 'Inquiry Category',
                        prefixIcon: Icon(Icons.category_outlined, color: AppColors.primary),
                      ),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _category = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Subject
                    TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Subject Headline *',
                        prefixIcon: Icon(Icons.title, color: AppColors.primary),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Subject is required' : null,
                    ),
                    const SizedBox(height: 12),

                    // Message
                    TextFormField(
                      controller: _messageController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Message & Details *',
                        hintText: 'Please describe your question or technical issue...',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Message is required' : null,
                    ),
                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitQuery,
                        icon: _isSubmitting
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.send),
                        label: const Text('Send Message to Admin', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // FAQs Accordion Section (SRS 1.6 #12)
            const Text(
              'Frequently Asked Questions (FAQs)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.deepNavy),
            ),
            const SizedBox(height: 12),

            ..._faqs.map((faq) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      faq.question,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimaryLight),
                    ),
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    children: [
                      Text(
                        faq.answer,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, height: 1.4),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
