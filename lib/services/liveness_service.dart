import 'dart:async';
import 'package:facial_liveness_verification/facial_liveness_verification.dart';

class LivenessService {
  late LivenessDetector _detector;
  StreamSubscription<LivenessState>? _subscription;

  // Initialize the detector with your preferred HNG-ready config
  Future<void> initializeDetector({
    required Function(LivenessState) onStateChanged,
    required Function(dynamic) onComplete,
  }) async {
    _detector = LivenessDetector(
      const LivenessConfig(
        challenges: [ChallengeType.smile, ChallengeType.blink],
        enableAntiSpoofing: true,
        challengeTimeout: Duration(seconds: 15),
      ),
    );

    // Listen to the stream and pass updates back to the UI
    _subscription = _detector.stateStream.listen((state) {
      onStateChanged(state);

      if (state.type == LivenessStateType.completed) {
        onComplete(state.result);
      }
    });

    await _detector.initialize();
  }

  // Start the actual camera stream
  Future<void> start() async => await _detector.start();

  // Stop the stream
  Future<void> stop() async => await _detector.stop();

  // Getter for the camera controller to show preview in UI
  dynamic get cameraController => _detector.cameraController;

  // Cleanup resources to prevent memory leaks
  void dispose() {
    _subscription?.cancel();
    _detector.stop();
    _detector.dispose();
  }

  // Helper to get user-friendly messages
  String getStatusMessage(LivenessState state) {
    switch (state.type) {
      case LivenessStateType.faceDetected:
        return "Face detected! Stay still.";
      case LivenessStateType.positioned:
        return "Good! Follow the instructions.";
      case LivenessStateType.challengeInProgress:
        return "Action: ${state.currentChallenge?.instruction ?? 'Look at camera'}";
      case LivenessStateType.completed:
        return "Verification Successful!";
      case LivenessStateType.error:
        return "Error: ${state.error?.message ?? 'Try again'}";
      default:
        return "Align your face within the frame";
    }
  }
}
