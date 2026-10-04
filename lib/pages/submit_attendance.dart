import 'dart:io';
import 'dart:typed_data';
import 'package:attandance/data/endpoint/attendance/request.dart';
import 'package:attandance/main.dart';
import 'package:attandance/widgets/live_clock.dart';
import 'package:attandance/data/central_api_caller.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

enum AttendancePageType { attendance, detail }

enum AttendanceType { checkin, checkout }

class AttendanceInfo {
  final DateTime? time;
  final num latitude;
  final num longitude;
  final String photo;

  AttendanceInfo({
    this.time,
    this.latitude = 0,
    this.longitude = 0,
    this.photo = "",
  });
}

class SubmitAttendance extends StatefulWidget {
  final AttendancePageType pageType;
  final AttendanceType attendanceType;
  final AttendanceInfo checkInDetail;
  final AttendanceInfo checkOutDetail;

  const SubmitAttendance({
    super.key,
    this.pageType = AttendancePageType.attendance,
    this.attendanceType = AttendanceType.checkin,
    required this.checkInDetail,
    required this.checkOutDetail,
  });

  @override
  State<SubmitAttendance> createState() => _SubmitAttendanceState();
}

class _SubmitAttendanceState extends State<SubmitAttendance> {
  File? _capturedImage;
  double? _latitude;
  double? _longitude;
  CentralApiCaller apiCaller = CentralApiCaller();
  final ImagePicker _picker = ImagePicker();

  // In-memory cache to prevent redundant API calls during the app session
  static final Map<String, Uint8List> _photoCache = {};

  @override
  void initState() {
    super.initState();
    _prefetchPhotos();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.pageType == AttendancePageType.attendance) {
        _initializeLocationServices();
      }
    });
  }

  Future<void> _initializeLocationServices() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Prompt user to allow location access
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Location permission is required for attendance.',
                ),
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showPermissionSettingsDialog();
        }
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled && mounted) {
        _showGpsDialog();
      }
    } catch (e) {
      debugPrint('Error initializing location services: $e');
    }
  }

  void _showGpsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.location_off, color: Colors.orange),
              SizedBox(width: 8),
              Text('GPS Required'),
            ],
          ),
          content: const Text(
            'Please turn on Location Services (GPS) on your device to proceed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
              },
              child: const Text('Turn On GPS'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionSettingsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'Location permission is permanently denied. Please enable it in system settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _prefetchPhotos() {
    if (widget.checkInDetail.photo != "") {
      _getAttendancePhoto(widget.checkInDetail.photo);
    }
    if (widget.checkOutDetail.photo != "") {
      _getAttendancePhoto(widget.checkOutDetail.photo);
    }
  }

  Future<Uint8List?> _getAttendancePhoto(String photoPath) async {
    if (photoPath.isEmpty) return null;

    // Return cached bytes if image is already fetched
    if (_photoCache.containsKey(photoPath)) {
      return _photoCache[photoPath];
    }

    try {
      final bytes = await apiCaller.attendance.getAttendancePhoto(photoPath);
      _photoCache[photoPath] = bytes;
      return bytes;
    } catch (e) {
      return null;
    }
  }

  // Helper method to handle Location Permissions & GPS retrieval
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled on your device.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  // Updated _takePhoto method
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        // Fetch GPS position immediately after photo capture
        final Position position = await _determinePosition();

        if (mounted) {
          setState(() {
            _capturedImage = File(photo.path);
            _latitude = position.latitude;
            _longitude = position.longitude;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture photo/location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _postAttendance(AttendanceType attendanceType) async {
    if (_capturedImage == null || _latitude == null || _longitude == null) {
      final message =
          widget.attendanceType == AttendanceType.checkout &&
              widget.checkOutDetail.time != null
          ? "Make sure to retake the photo and activate geolocation first"
          : "Make sure to take the photo and activate geolocation first";
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
      return;
    }

    final attendanceType = widget.attendanceType.name;
    final image = _capturedImage!;
    final latitude = _latitude!;
    final longitude = _longitude!;

    final request = PostAttendanceRequest(
      attendanceType: attendanceType,
      image: image,
      latitude: latitude,
      longitude: longitude,
    );

    final resp = await apiCaller.attendance.postAttendance(request);
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp.message), backgroundColor: Colors.red),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resp.message),
          backgroundColor: Colors.lightGreen,
        ),
      );

      globalDataSync.notifyDataChanged();

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialIndex = widget.attendanceType == AttendanceType.checkout
        ? 1
        : 0;

    return DefaultTabController(
      length: 2,
      initialIndex: initialIndex,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.pageType == AttendancePageType.attendance
                ? 'Submit Attendance'
                : 'Attendance Detail',
          ),
          bottom: const TabBar(
            labelColor: Color(0xFF0F172A),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF0F172A),
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Check in'),
              Tab(text: 'Check out'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAttendanceForm(
              isCheckIn: true,
              attendanceDetail: widget.checkInDetail,
            ),
            _buildAttendanceForm(
              isCheckIn: false,
              attendanceDetail: widget.checkOutDetail,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceForm({
    required bool isCheckIn,
    required AttendanceInfo attendanceDetail,
  }) {
    final bool showActionButtons =
        widget.pageType == AttendancePageType.attendance &&
        ((isCheckIn && widget.attendanceType == AttendanceType.checkin) ||
            (!isCheckIn && widget.attendanceType == AttendanceType.checkout));

    // Displays newly captured lat/lng if available, falling back to passed detail
    final currentLat = (showActionButtons && _latitude != null)
        ? _latitude
        : attendanceDetail.latitude;
    final currentLng = (showActionButtons && _longitude != null)
        ? _longitude
        : attendanceDetail.longitude;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: [
          widget.pageType == AttendancePageType.detail ||
                  (isCheckIn &&
                      widget.attendanceType == AttendanceType.checkout) ||
                  (!isCheckIn &&
                      widget.attendanceType == AttendanceType.checkin)
              ? LiveClockWidget(timeStamp: attendanceDetail.time)
              : const LiveClockWidget(),

          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: _buildImageWidget(
                  showActionButtons,
                  attendanceDetail.photo,
                ),
              ),
            ),
          ),

          // Capture / Recapture Photo Button
          if (showActionButtons)
            OutlinedButton.icon(
              onPressed: _takePhoto,
              icon: _capturedImage == null ? null : const Icon(Icons.refresh),
              label: Text(
                _capturedImage == null ? 'Capture Photo' : 'Recapture Photo',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

          // Location Info
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Point',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Lat: $currentLat', style: const TextStyle(fontSize: 16)),
                Text('Lng: $currentLng', style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),

          // Submit Button
          if (showActionButtons)
            ElevatedButton(
              onPressed: () async {
                await _postAttendance(
                  isCheckIn ? AttendanceType.checkin : AttendanceType.checkout,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                isCheckIn ? 'Submit Check In' : 'Submit Check Out',
                style: const TextStyle(fontSize: 18),
              ),
            ),
        ],
      ),
    );
  }

  // Helper widget to handle display prioritization (Captured File > Remote Photo > Placeholder)
  Widget _buildImageWidget(bool isFormActive, String? photoPath) {
    if (isFormActive && _capturedImage != null) {
      return Image.file(
        _capturedImage!,
        fit: BoxFit.contain,
        width: double.infinity,
      );
    }

    if (photoPath != null && photoPath.isNotEmpty) {
      return FutureBuilder<Uint8List?>(
        future: _getAttendancePhoto(photoPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.contain,
              width: double.infinity,
            );
          }
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Failed to load photo',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          );
        },
      );
    }

    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt, size: 64, color: Colors.grey),
        SizedBox(height: 8),
        Text('This will show your photo', style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
