import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/constants/api_constants.dart';

class AiService {
  static Future<Map<String, dynamic>> analyzeSymptoms({
    required String symptoms,
    required String petName,
    required String petType,
    required String breed,
    required int ageYears,
  }) async {
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: ApiConstants.geminiApiKey,
    );

    final prompt = '''
You are an expert veterinary AI assistant. Analyze the following pet symptoms and provide a structured response.

Pet Details:
- Name: $petName
- Type: $petType
- Breed: $breed
- Age: $ageYears years
- Reported symptoms: $symptoms

Respond ONLY with a valid JSON object. No markdown, no code blocks, just raw JSON:
{
  "risk_score": <integer 0-100>,
  "risk_level": "<Low|Medium|High|Critical>",
  "extracted_symptoms": ["symptom1", "symptom2"],
  "possible_causes": ["cause1", "cause2", "cause3"],
  "immediate_actions": ["action1", "action2", "action3"],
  "care_plan": {
    "today": ["step1", "step2"],
    "next_48_hours": ["step1", "step2"],
    "see_vet_if": ["condition1", "condition2"]
  },
  "explanation": "2-3 sentence human-readable explanation"
}

Risk score: 0-25=Low, 26-50=Medium, 51-75=High, 76-100=Critical.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final text = response.text ?? '';
      final cleaned =
          text.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('AI analysis failed: $e');
    }
  }
}
