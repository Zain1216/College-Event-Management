import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../services/firebase_datastore.dart';

enum EventSortBy {
  newest,
  mostPopular,
  dateUpcoming,
  topRated,
}

class EventProvider extends ChangeNotifier {
  final FirebaseDataStore _dataStore = FirebaseDataStore();

  List<EventModel> _allEvents = [];
  String _searchQuery = '';
  String _selectedCategory = 'All'; // 'All', 'Technical', 'Cultural', 'Sports', 'Seminar', 'Workshop'
  String _selectedDepartment = 'All';
  EventSortBy _sortBy = EventSortBy.dateUpcoming;

  StreamSubscription? _eventsSub;

  EventProvider() {
    _initEvents();
  }

  void _initEvents() {
    _allEvents = _dataStore.events;
    _eventsSub = _dataStore.eventsStream.listen((events) {
      _allEvents = events;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _eventsSub?.cancel();
    super.dispose();
  }

  List<EventModel> get allEvents => _allEvents;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedDepartment => _selectedDepartment;
  EventSortBy get sortBy => _sortBy;

  // Filtered Events for Discovery & Student Dashboard
  List<EventModel> get publicEvents {
    return _allEvents.where((e) {
      // General students see approved, live, and completed events
      final isPublicStatus = e.status == EventStatus.approved ||
          e.status == EventStatus.live ||
          e.status == EventStatus.completed;
      if (!isPublicStatus) return false;

      // Category filter
      if (_selectedCategory != 'All' &&
          e.category.displayName.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }

      // Department filter
      if (_selectedDepartment != 'All' &&
          e.department.toLowerCase() != _selectedDepartment.toLowerCase()) {
        return false;
      }

      // Search Query & Tags & Fuzzy Matching
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final matchTitle = e.title.toLowerCase().contains(q);
        final matchDesc = e.description.toLowerCase().contains(q);
        final matchDept = e.department.toLowerCase().contains(q);
        final matchVenue = e.venue.toLowerCase().contains(q);
        final matchTags = e.tags.any((t) => t.toLowerCase().contains(q));
        if (!matchTitle && !matchDesc && !matchDept && !matchVenue && !matchTags) {
          return false;
        }
      }

      return true;
    }).toList()
      ..sort((a, b) {
        switch (_sortBy) {
          case EventSortBy.newest:
            return b.createdAt.compareTo(a.createdAt);
          case EventSortBy.mostPopular:
            return b.registeredCount.compareTo(a.registeredCount);
          case EventSortBy.topRated:
            return b.averageRating.compareTo(a.averageRating);
          case EventSortBy.dateUpcoming:
          default:
            return a.date.compareTo(b.date);
        }
      });
  }

  // Live / Ongoing Events
  List<EventModel> get liveEvents =>
      _allEvents.where((e) => e.status == EventStatus.live).toList();

  // Top Rated Events (Badged in SRS)
  List<EventModel> get topRatedEvents =>
      _allEvents.where((e) => e.isTopRated || e.averageRating >= 4.5).toList();

  // Pending Events for Admin Approval
  List<EventModel> get pendingApprovalEvents =>
      _allEvents.where((e) => e.status == EventStatus.pending).toList();

  // Events created by specific Organizer
  List<EventModel> getEventsByOrganizer(String organizerId) {
    return _allEvents.where((e) => e.organizerId == organizerId).toList();
  }

  // Search Auto-Suggestions
  List<String> getSearchSuggestions(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.trim().toLowerCase();
    final Set<String> suggestions = {};

    for (var e in _allEvents) {
      if (e.title.toLowerCase().contains(q)) suggestions.add(e.title);
      if (e.department.toLowerCase().contains(q)) suggestions.add(e.department);
      for (var tag in e.tags) {
        if (tag.toLowerCase().contains(q)) suggestions.add('#$tag');
      }
    }
    return suggestions.take(6).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setDepartment(String department) {
    _selectedDepartment = department;
    notifyListeners();
  }

  void setSortBy(EventSortBy sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _selectedDepartment = 'All';
    _sortBy = EventSortBy.dateUpcoming;
    notifyListeners();
  }

  // Organizer Actions
  Future<EventModel> createEvent(EventModel event) async {
    return await _dataStore.createEvent(event);
  }

  Future<void> updateEvent(EventModel event) async {
    await _dataStore.updateEvent(event);
  }

  // Admin Actions
  Future<void> approveEvent(String eventId) async {
    await _dataStore.setEventStatus(eventId, EventStatus.approved);
  }

  Future<void> rejectEvent(String eventId, String reason) async {
    await _dataStore.setEventStatus(eventId, EventStatus.cancelled, rejectionReason: reason);
  }

  Future<void> setEventLive(String eventId) async {
    await _dataStore.setEventStatus(eventId, EventStatus.live);
  }

  Future<void> completeEvent(String eventId) async {
    await _dataStore.setEventStatus(eventId, EventStatus.completed);
  }

  Future<void> cancelEvent(String eventId, {String? reason}) async {
    await _dataStore.setEventStatus(eventId, EventStatus.cancelled, rejectionReason: reason);
  }

  Future<void> deleteEvent(String eventId) async {
    await _dataStore.deleteEvent(eventId);
  }
}
