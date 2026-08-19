import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../models/family_mission.dart';

class MissionVerificationResult {
  const MissionVerificationResult({
    required this.verdict,
    required this.confidence,
    required this.reason,
  });

  final String verdict;
  final double confidence;
  final String reason;

  bool get verified => verdict == 'verified';
  bool get uncertain => verdict == 'uncertain';
}

class FamilyMissionAiService {
  const FamilyMissionAiService();

  Future<MissionVerificationResult> verifyProof({
    required FamilyMission mission,
    required Uint8List imageBytes,
    required String mimeType,
    required String note,
  }) async {
    final response = await http
        .post(
          ApiConfig.endpoint('/api/family-missions/verify'),
          headers: await ApiConfig.authenticatedJsonHeaders(),
          body: jsonEncode({
            'missionId': mission.id,
            'title': mission.title,
            'description': mission.description,
            'proofHint': mission.proofHint,
            'note': note.trim(),
            'mimeType': mimeType,
            'imageBase64': base64Encode(imageBytes),
          }),
        )
        .timeout(const Duration(seconds: 45));

    final dynamic decoded = jsonDecode(response.body);

    if (response.statusCode != 200 || decoded is! Map<String, dynamic>) {
      final message = decoded is Map<String, dynamic>
          ? decoded['error']?.toString()
          : null;

      throw Exception(message ?? 'Could not verify mission proof');
    }

    final verdict = decoded['verdict']?.toString() ?? 'uncertain';

    final confidenceValue = decoded['confidence'];

    final confidence = confidenceValue is num
        ? confidenceValue.toDouble()
        : 0.0;

    final reason =
        decoded['reason']?.toString().trim() ??
        'The proof could not be clearly evaluated.';

    return MissionVerificationResult(
      verdict: verdict,
      confidence: confidence.clamp(0.0, 1.0),
      reason: reason,
    );
  }
}
