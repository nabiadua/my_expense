import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:facial_liveness_verification/facial_liveness_verification.dart';
import 'dashboard_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class LivenessScreen extends StatefulWidget {
  const LivenessScreen({super.key});

  @override
  State<LivenessScreen> createState() => _LivenessScreenState();
}

class _LivenessScreenState extends State<LivenessScreen> {
  late LivenessDetector _detector;
  StreamSubscription<LivenessState>? _subscription;
  String _status = 'Initializing Camera...';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLiveness();
  }

  Future<void> _initializeLiveness() async {
    // 1. Create detector with custom config (matching Figma's "Pro" feel)
    _detector = LivenessDetector(
      const LivenessConfig(
        challenges: [ChallengeType.smile, ChallengeType.blink],
        enableAntiSpoofing: true,
        challengeTimeout: Duration(seconds: 10),
      ),
    );

    // 2. Listen to state updates
    _subscription = _detector.stateStream.listen((state) {
      if (!mounted) return;

      setState(() {
        _status = _getStatusMessage(state);
      });

      // 3. Handle successful verification
      if (state.type == LivenessStateType.completed) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    });

    try {
      await _detector.initialize();
      await _detector.start();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _status = "Error: $e";
      });
    }
  }

  String _getStatusMessage(LivenessState state) {
    switch (state.type) {
      case LivenessStateType.faceDetected:
        return 'Face detected! Stay still.';
      case LivenessStateType.positioned:
        return 'Perfect! Hold that position.';
      case LivenessStateType.challengeInProgress:
        return 'Action Required: ${state.currentChallenge?.instruction ?? "Look at the camera"}';
      case LivenessStateType.completed:
        return 'Verification Successful!';
      case LivenessStateType.error:
        return 'Error: ${state.error?.message ?? "Unknown error"}';
      default:
        return 'Align your face in the frame';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Matches Figma background
      body: Stack(
        children: [
          // 1. Camera Layer (The Background)
          if (_isInitialized && _detector.cameraController != null)
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: _detector.cameraController!.value.aspectRatio,
                child: CameraPreview(_detector.cameraController!),
              ),
            ),

          // 2. The Custom Mask Layer (The Circle cutout)
          // This dims the camera preview except for the circle in the middle
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.9), // Dimming color
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 280, // Size of your circle
                      width: 280,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. UI Overlay Layer
          _buildNewOverlay(),
        ],
      ),
    );
  }

  Widget _buildNewOverlay() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
        child: Column(
          children: [
            // Header Section
            Text(
              'Identity Verification',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Center your face in the frame',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),

            const Spacer(), // Pushes circle to center
            // 4. Verification Circle Border (Visual only)
            Container(
              width: 285,
              height: 285,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0056D2), width: 4),
              ),
            ),

            const SizedBox(height: 24),

            // 5. Status / Challenge Tooltip (Blink/Smile)
            if (_status.contains("Action Required"))
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9C4), // Yellow challenge box
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _status.replaceAll("Action Required: ", ""),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // 6. End-to-End Encrypted Badge (The Box below circle)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_outlined, size: 16, color: Colors.black54),
                  SizedBox(width: 8),
                  Text(
                    'End-to-end encrypted',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Status footer
            Text(
              _status.contains("Action Required") ? "Verifying..." : _status,
              style: const TextStyle(
                color: Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _detector.stop();
    _detector.dispose();
    super.dispose();
  }
}
