import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/contact_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_widgets.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Contact Support & FAQs', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 85),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Support Glass Card (SRS 1.6 #12)
            GlassContainer(
              borderRadius: 24,
              blurSigma: 16,
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppColors.heroGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.mail_outline_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Submit an Inquiry to Admin',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.deepNavy),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Name
                    GlassTextField(
                      controller: _nameController,
                      labelText: 'Your Name *',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 12),

                    // Email
                    GlassTextField(
                      controller: _emailController,
                      labelText: 'Email Address *',
                      prefixIcon: Icons.email_outlined,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Email is required' : null,
                    ),
                    const SizedBox(height: 12),

                    // Category
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.72),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.2),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          value: _category,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Inquiry Category',
                            prefixIcon: Icon(Icons.category_outlined, color: AppColors.primary),
                          ),
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _category = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subject
                    GlassTextField(
                      controller: _subjectController,
                      labelText: 'Subject Headline *',
                      prefixIcon: Icons.title_rounded,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Subject is required' : null,
                    ),
                    const SizedBox(height: 12),

                    // Message
                    GlassTextField(
                      controller: _messageController,
                      maxLines: 4,
                      labelText: 'Message & Details *',
                      hintText: 'Please describe your question or technical issue...',
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Message is required' : null,
                    ),
                    const SizedBox(height: 18),

                    GlassButton(
                      label: 'Send Message to Admin',
                      icon: Icons.send_rounded,
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _submitQuery,
                      height: 48,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // FAQs Accordion Section (SRS 1.6 #12)
            Text(
              'Frequently Asked Questions (FAQs)',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.deepNavy),
            ),
            const SizedBox(height: 12),

            ..._faqs.map((faq) => GlassContainer(
                  borderRadius: 18,
                  blurSigma: 12,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.zero,
                  child: ExpansionTile(
                    shape: const Border(),
                    collapsedShape: const Border(),
                    title: Text(
                      faq.question,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: isDark ? Colors.white : AppColors.textPrimaryLight),
                    ),
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    children: [
                      Text(
                        faq.answer,
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight, height: 1.45),
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
