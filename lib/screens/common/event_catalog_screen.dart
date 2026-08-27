import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/event_card.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Catalog & Discovery'),
      ),
      body: Column(
        children: [
          // Search & Filter Toolbar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Global Search Bar with Auto-Suggestions (SRS 1.6 #3 & #10)
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by event name, department, or #tags...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              eventProvider.setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) => eventProvider.setSearchQuery(val),
                ),

                // Auto Suggestions Dropdown Preview
                if (suggestions.isNotEmpty && _searchController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: suggestions.map((s) => InkWell(
                            onTap: () {
                              _searchController.text = s.replaceAll('#', '');
                              eventProvider.setSearchQuery(s.replaceAll('#', ''));
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.history, size: 14, color: AppColors.textSecondaryLight),
                                  const SizedBox(width: 8),
                                  Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          )).toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = eventProvider.selectedCategory.toLowerCase() == cat.toLowerCase();
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppColors.primaryContainer,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                            color: isSelected ? AppColors.primaryDark : AppColors.textPrimaryLight,
                          ),
                          onSelected: (val) => eventProvider.setCategory(cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 10),

                // Sort Dropdown & Reset Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${events.length} Events',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondaryLight),
                    ),
                    Row(
                      children: [
                        const Text('Sort: ', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                        DropdownButton<EventSortBy>(
                          value: eventProvider.sortBy,
                          underline: const SizedBox(),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
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
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.borderLight),

          // Events List
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 54, color: AppColors.textMutedLight),
                          const SizedBox(height: 12),
                          const Text(
                            'No events found',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.deepNavy),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try clearing search filters or changing the event category.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              eventProvider.resetFilters();
                            },
                            child: const Text('Reset All Filters'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
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
