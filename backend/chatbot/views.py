import os
from django.conf import settings
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

# Gemini integration
try:
    import google.generativeai as genai
    genai.configure(api_key=settings.GEMINI_API_KEY)
    _GEMINI_MODEL = genai.GenerativeModel('gemini-pro')
    GEMINI_AVAILABLE = bool(settings.GEMINI_API_KEY)
except Exception:
    GEMINI_AVAILABLE = False

SYSTEM_PROMPT = """You are MedBot, the AI awareness assistant for MedCycle — a platform for safe antibiotic disposal to combat Antimicrobial Resistance (AMR).

Your role:
1. Guide users on SAFE disposal of unused/expired antibiotics.
2. Educate about AMR — what it is, why it matters, and how disposal affects it.
3. Help users find disposal options (pharmacies or home disposal).
4. Answer questions about the MedCycle app features.
5. Provide multilingual support when asked (Hindi, Tamil, Bengali, etc.).

Key facts to share:
- AMR kills ~1.27 million people annually (WHO 2019 data).
- Flushing antibiotics is dangerous — it contaminates water and accelerates AMR.
- Proper disposal at pharmacy drop-off points is the safest method.
- MedCycle rewards users with points for every safe disposal.

Keep responses concise, friendly, and in plain language suitable for all literacy levels.
If a question is unrelated to antibiotics, AMR, or medicine disposal, politely redirect the conversation.
"""

# Fallback responses for common questions when Gemini is unavailable
FALLBACK_RESPONSES = {
    'dispose': (
        "To dispose of antibiotics safely:\n"
        "1. Find your nearest MedCycle drop-off pharmacy using the app map.\n"
        "2. Bring your unused/expired antibiotics in their original packaging.\n"
        "3. Scan the QR code at the pharmacy to earn reward points!\n\n"
        "If no pharmacy is nearby, use our Home Disposal Guide in the app."
    ),
    'amr': (
        "Antimicrobial Resistance (AMR) happens when bacteria become resistant to antibiotics "
        "due to overuse or improper disposal. It kills over 1.27 million people per year globally. "
        "By safely disposing of your antibiotics, you help prevent AMR from spreading!"
    ),
    'points': (
        "You earn 10 points for every antibiotic disposal. "
        "High-risk antibiotics (like fluoroquinolones) earn bonus points. "
        "Verified pharmacy drop-offs earn an extra 5 bonus points. "
        "Collect points to unlock badges like 'AMR Hero' and 'Health Guardian'!"
    ),
    'default': (
        "Hi! I'm MedBot, your antibiotic disposal guide. "
        "I can help you with:\n"
        "- Safe antibiotic disposal methods\n"
        "- Finding nearby drop-off pharmacies\n"
        "- Understanding AMR and why it matters\n"
        "- Earning reward points\n\n"
        "What would you like to know?"
    ),
}


def _get_fallback(message: str) -> str:
    msg_lower = message.lower()
    if any(w in msg_lower for w in ['dispos', 'throw', 'get rid', 'waste']):
        return FALLBACK_RESPONSES['dispose']
    if any(w in msg_lower for w in ['amr', 'resistance', 'antibiotic resist']):
        return FALLBACK_RESPONSES['amr']
    if any(w in msg_lower for w in ['point', 'reward', 'badge', 'earn']):
        return FALLBACK_RESPONSES['points']
    return FALLBACK_RESPONSES['default']


@api_view(['POST'])
def chat(request):
    """
    AI chatbot endpoint.
    Body: { "message": "...", "history": [...] }
    """
    message = request.data.get('message', '').strip()
    history = request.data.get('history', [])  # list of {role, text} dicts

    if not message:
        return Response({'error': 'message is required'}, status=status.HTTP_400_BAD_REQUEST)

    if GEMINI_AVAILABLE:
        try:
            chat_session = _GEMINI_MODEL.start_chat(history=[])
            # Inject system context on first message
            full_prompt = f"{SYSTEM_PROMPT}\n\nUser: {message}"
            response = chat_session.send_message(full_prompt)
            reply = response.text
            source = 'gemini'
        except Exception as e:
            reply = _get_fallback(message)
            source = 'fallback'
    else:
        reply = _get_fallback(message)
        source = 'fallback'

    return Response({
        'reply': reply,
        'source': source,
        'suggestions': _get_followup_suggestions(message),
    })


def _get_followup_suggestions(message: str) -> list:
    """Return quick-reply suggestion buttons based on context."""
    msg_lower = message.lower()
    if 'dispos' in msg_lower:
        return [
            "Find nearest pharmacy",
            "Home disposal steps",
            "What antibiotics can I dispose?",
        ]
    if 'amr' in msg_lower or 'resistance' in msg_lower:
        return [
            "How does disposal help AMR?",
            "Which antibiotics are high risk?",
            "Safe disposal methods",
        ]
    return [
        "How to dispose antibiotics safely?",
        "What is AMR?",
        "How do I earn reward points?",
    ]
