import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/media_model.dart';
import '../services/firebase_datastore.dart';

class MediaProvider extends ChangeNotifier {
  final FirebaseDataStore _dataStore = FirebaseDataStore();

  List<MediaModel> _mediaList = [];
  String _selectedCategory = 'All';
  String _selectedDepartment = 'All';

  StreamSubscription? _mediaSub;

  MediaProvider() {
    _init();
  }

  void _init() {
    _mediaList = _dataStore.mediaGallery;
    _mediaSub = _dataStore.mediaStream.listen((list) {
      _mediaList = list;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _mediaSub?.cancel();
    super.dispose();
  }

  List<MediaModel> get allMedia => _mediaList;
  String get selectedCategory => _selectedCategory;
  String get selectedDepartment => _selectedDepartment;

  List<MediaModel> get publicMedia {
    return _mediaList.where((m) {
      if (!m.isApproved) return false;
      if (_selectedCategory != 'All' &&
          m.category.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }
      if (_selectedDepartment != 'All' &&
          m.department.toLowerCase() != _selectedDepartment.toLowerCase()) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.uploadedOn.compareTo(a.uploadedOn));
  }

  List<MediaModel> get featuredMedia =>
      _mediaList.where((m) => m.isApproved && m.isFeatured).toList();

  List<MediaModel> get pendingApprovalMedia =>
      _mediaList.where((m) => !m.isApproved).toList();

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setDepartment(String department) {
    _selectedDepartment = department;
    notifyListeners();
  }

  Future<void> toggleLike(String mediaId, String userId) async {
    await _dataStore.toggleMediaLike(mediaId, userId);
  }

  Future<void> uploadMedia({
    required String eventId,
    required String eventTitle,
    required String mediaUrl,
    required String caption,
    required String category,
    required String department,
    required String uploadedBy,
    required String uploaderName,
    MediaType type = MediaType.image,
  }) async {
    final media = MediaModel(
      id: 'med_${DateTime.now().millisecondsSinceEpoch}',
      eventId: eventId,
      eventTitle: eventTitle,
      mediaType: type,
      mediaUrl: mediaUrl,
      caption: caption,
      category: category,
      department: department,
      uploadedBy: uploadedBy,
      uploaderName: uploaderName,
      isApproved: true,
      uploadedOn: DateTime.now(),
    );
    await _dataStore.uploadMedia(media);
  }

  Future<void> toggleApproval(String mediaId, bool isApproved) async {
    await _dataStore.toggleMediaApproval(mediaId, isApproved);
  }

  Future<void> toggleFeatured(String mediaId, bool isFeatured) async {
    await _dataStore.toggleMediaFeatured(mediaId, isFeatured);
  }

  Future<void> deleteMedia(String mediaId) async {
    await _dataStore.deleteMedia(mediaId);
  }
}
