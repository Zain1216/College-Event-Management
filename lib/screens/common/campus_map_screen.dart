import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../theme/app_theme.dart';
import '../student/event_details_screen.dart';

class CampusMapScreen extends StatefulWidget {
  final String? highlightEventId;

  const CampusMapScreen({super.key, this.highlightEventId});

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  late final MapController _mapController;
  final LatLng _campusCenter = const LatLng(12.9716, 77.5946); // University Campus Coordinates

  final List<Map<String, dynamic>> _campusVenues = [
    {
      'title': 'Computing Arena & Innovation Hub (Block B)',
      'desc': 'Host of TechNova 2026 Hackathon & Cyber CTF',
      'location': const LatLng(12.9724, 77.5951),
      'icon': Icons.computer,
      'color': AppColors.primary,
    },
    {
      'title': 'Open Air Amphitheatre',
      'desc': 'Host of Euphoria 2026 Band War & Cultural Galas',
      'location': const LatLng(12.9710, 77.5938),
      'icon': Icons.music_note,
      'color': AppColors.secondaryDark,
    },
    {
      'title': 'Indoor Sports Complex & Arena',
      'desc': 'Host of Inter-University 3x3 Basketball Slam',
      'location': const LatLng(12.9705, 77.5925),
      'icon': Icons.sports_basketball,
      'color': AppColors.accentOrange,
    },
    {
      'title': 'Robotics Arena (Mechanical Block)',
      'desc': 'Host of RoboClash 15kg Combat Arena',
      'location': const LatLng(12.9730, 77.5960),
      'icon': Icons.smart_toy,
      'color': AppColors.statusLive,
    },
    {
      'title': 'Main University Auditorium',
      'desc': 'Host of AI & Quantum Computing Summit Keynotes',
      'location': const LatLng(12.9716, 77.5946),
      'icon': Icons.account_balance,
      'color': AppColors.deepNavy,
    },
  ];

  Map<String, dynamic>? _selectedVenue;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedVenue = _campusVenues.first;
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Venues & GPS Navigation'),
      ),
      body: Stack(
        children: [
          // OpenStreetMap Tile Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _campusCenter,
              initialZoom: 16.5,
              maxZoom: 18.5,
              minZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.aptech.fusionfiesta',
              ),
              // Venue Marker Pins
              MarkerLayer(
                markers: _campusVenues.map((venue) {
                  final isSelected = _selectedVenue?['title'] == venue['title'];
                  return Marker(
                    point: venue['location'] as LatLng,
                    width: isSelected ? 50 : 40,
                    height: isSelected ? 50 : 40,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedVenue = venue);
                        _mapController.move(venue['location'] as LatLng, 17.0);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: venue['color'] as Color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          venue['icon'] as IconData,
                          color: Colors.white,
                          size: isSelected ? 26 : 20,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Top Info Pill
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.near_me, color: AppColors.primary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tap any campus pin to view live events hosted at that facility.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.deepNavy),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Venue Detail Card
          if (_selectedVenue != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (_selectedVenue!['color'] as Color).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _selectedVenue!['icon'] as IconData,
                            color: _selectedVenue!['color'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedVenue!['title'] as String,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                              ),
                              Text(
                                _selectedVenue!['desc'] as String,
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: AppColors.statusLive,
                                  content: Text('📍 GPS Navigation started to campus destination.'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.directions, size: 16),
                            label: const Text('Start GPS Route', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
