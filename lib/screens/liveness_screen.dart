import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:facial_liveness_verification/facial_liveness_verification.dart';
import 'dashboard_screen.dart';

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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 4. Real Camera Preview
          if (_isInitialized && _detector.cameraController != null)
            Center(
              child: AspectRatio(
                aspectRatio: 1 / _detector.cameraController!.value.aspectRatio,
                child: CameraPreview(_detector.cameraController!),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF83C5BE)),
            ),

          // 5. Figma-style UI Overlay
          _buildOverlay(),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Text(
              "Liveness Check",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          // Status Message Box
          Container(
            margin: const EdgeInsets.all(30),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF006D77).withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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
