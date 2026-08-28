import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/event_card.dart';
import '../../widgets/glass_widgets.dart';
import '../student/event_details_screen.dart';

class EventCatalogScreen extends StatefulWidget {
  const EventCatalogScreen({super.key});

  @override
  State<EventCatalogScreen> createState() => _EventCatalogScreenState();
}

class _EventCatalogScreenState extends State<EventCatalogScreen> {
  final _searchController = TextEditingController();
  final List<String> _categories = ['All', 'Technical', 'Cultural', 'Sports', 'Seminar', 'Workshop'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final events = eventProvider.publicEvents;
    final suggestions = eventProvider.getSearchSuggestions(_searchController.text);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Event Catalog & Discovery', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          // Frosted Glass Search & Filter Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                // Global Search Bar with Auto-Suggestions (SRS 1.6 #3 & #10)
                GlassTextField(
                  controller: _searchController,
                  hintText: 'Search by event name, department, or #tags...',
                  prefixIcon: Icons.search_rounded,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            eventProvider.setSearchQuery('');
                          },
                        )
                      : null,
                  onChanged: (val) => eventProvider.setSearchQuery(val),
                ),

                // Auto Suggestions Dropdown Preview
                if (suggestions.isNotEmpty && _searchController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  GlassContainer(
                    borderRadius: 14,
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      children: suggestions.map((s) => InkWell(
                            onTap: () {
                              _searchController.text = s.replaceAll('#', '');
                              eventProvider.setSearchQuery(s.replaceAll('#', ''));
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.history_rounded, size: 15, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(s, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          )).toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Horizontal Glass Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = eventProvider.selectedCategory.toLowerCase() == cat.toLowerCase();
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => eventProvider.setCategory(cat),
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: isSelected ? AppColors.heroGradient : null,
                              color: isSelected ? null : Colors.white.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? Colors.white.withOpacity(0.6) : Colors.white.withOpacity(0.8),
                                width: 1.2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              cat,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 10),

                // Sort Dropdown & Count Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${events.length} Events',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondaryLight),
                    ),
                    Row(
                      children: [
                        Text('Sort: ', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.8)),
                          ),
                          child: DropdownButton<EventSortBy>(
                            value: eventProvider.sortBy,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                            items: const [
                              DropdownMenuItem(value: EventSortBy.dateUpcoming, child: Text('Upcoming Date')),
                              DropdownMenuItem(value: EventSortBy.newest, child: Text('Newest Added')),
                              DropdownMenuItem(value: EventSortBy.mostPopular, child: Text('Most Popular')),
                              DropdownMenuItem(value: EventSortBy.topRated, child: Text('Top Rated ★')),
                            ],
                            onChanged: (val) {
                              if (val != null) eventProvider.setSortBy(val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Events List
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: GlassContainer(
                        borderRadius: 24,
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.event_busy_rounded, size: 54, color: AppColors.textMutedLight),
                            const SizedBox(height: 12),
                            Text(
                              'No events found',
                              style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.deepNavy),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Try clearing search filters or changing the event category.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight),
                            ),
                            const SizedBox(height: 14),
                            GlassButton(
                              label: 'Reset All Filters',
                              icon: Icons.refresh_rounded,
                              isPrimary: false,
                              height: 42,
                              onPressed: () {
                                _searchController.clear();
                                eventProvider.resetFilters();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 85),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return EventCard(
                        event: event,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
