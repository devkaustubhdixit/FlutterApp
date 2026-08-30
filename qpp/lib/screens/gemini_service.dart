import 'dart:convert';
import 'package:http/http.dart' as http;

/// Calls the Gemini API directly over REST instead of using the
/// google_generative_ai package, which predates Gemini 3 and doesn't
/// expose newer fields like thinkingConfig.
///
/// NOTE ON API KEY SAFETY:
/// This class expects the key at build time via
/// --dart-define=GEMINI_API_KEY=xxxx. For a production release, don't
/// ship the key in the app at all -- have this class call your own
/// backend instead, which holds the key and forwards to Gemini
/// server-side, so the key can't be extracted from the compiled app.
class GeminiService {
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const _model = 'gemini-3.6-flash';
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  static const _systemPrompt = '''
You are a calm, patient companion chatting with an older adult who has
dementia. Follow these rules strictly:
- Use short, simple sentences and a warm, reassuring tone.
- Never point out that the person repeated a question or seems confused.
  If they ask the same thing again, answer it again patiently.
- Do not give medical advice, medication guidance, or diagnoses. If asked
  about symptoms, medication, or health decisions, gently say that's a
  great question for their doctor or caregiver.
- Keep replies brief (2-4 sentences) so they're easy to follow.
- If the person expresses distress, fear, confusion about where they are,
  mentions a fall, chest pain, or wanting to go somewhere unsafely, respond
  gently and encourage them to talk to their caregiver right away.
''';

  static final _escalationKeywords = [
    'fell',
    'fall',
    'chest pain',
    "can't breathe",
    'lost',
    "don't know where i am",
    'scared',
    'help me',
    'hurt',
  ];

  bool messageNeedsEscalation(String userText) {
    final lower = userText.toLowerCase();
    return _escalationKeywords.any((kw) => lower.contains(kw));
  }

  /// Full conversation history, kept here so each request carries context
  /// (Gemini is stateless between calls -- there's no server-side session).
  final List<Map<String, dynamic>> _history = [];

  Future<String> sendMessage(String text) async {
    _history.add({
      'role': 'user',
      'parts': [
        {'text': text}
      ],
    });

    final body = {
      'system_instruction': {
        'parts': [
          {'text': _systemPrompt}
        ],
      },
      'contents': _history,
      'generationConfig': {
        // Generous headroom: thinking tokens + visible answer both draw
        // from this budget on Gemini 3 models, so keep it well above
        // what a 2-4 sentence reply alone would need.
        'maxOutputTokens': 1024,
        // Keep internal reasoning light since this is simple companionable
        // chat, not a task needing deep multi-step reasoning. This leaves
        // more of the token budget for the actual visible reply.
        'thinkingConfig': {'thinkingLevel': 'low'},
      },
    };

    final response = await http.post(
      Uri.parse('$_endpoint?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini API error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      return "I'm not sure what to say to that, but I'm here with you.";
    }

    final finishReason = candidates[0]['finishReason'];
    final parts = candidates[0]['content']?['parts'] as List?;
    final reply = (parts != null && parts.isNotEmpty)
        ? (parts[0]['text'] as String? ?? '')
        : '';

    if (reply.isEmpty) {
      // Ran out of budget entirely (e.g. all spent on thinking).
      return "I'm not sure what to say to that, but I'm here with you.";
    }

    if (finishReason == 'MAX_TOKENS') {
      // Got a partial reply -- still show it, but this signals
      // maxOutputTokens may need to go even higher for this kind of prompt.
      // ignore: avoid_print
      print('Warning: Gemini reply was truncated (MAX_TOKENS).');
    }

    _history.add({
      'role': 'model',
      'parts': [
        {'text': reply}
      ],
    });

    return reply;
  }

  /// Call this if you ever need to reset context (e.g. new session/day).
  void resetConversation() {
    _history.clear();
  }
}