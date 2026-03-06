import { GoogleGenAI } from "@google/genai";
import { generateTemplateInterpretation } from "./interpretation-templates";

const apiKey = import.meta.env.VITE_GEMINI_API_KEY || "";
const ai = apiKey ? new GoogleGenAI({ apiKey }) : null;

// ── Prompt builder ─────────────────────────────────────────────────────────

function buildPrompt(data: unknown, lang: string): string {
  return `
You are Bazodiac's fusion astrologer — the ONLY system that synthesizes Western astrology, Chinese BaZi, and Wu-Xing Five Elements into one unified reading.

BIRTH DATA (JSON):
${JSON.stringify(data, null, 2)}

TASK: Write a deeply personal ${lang === 'de' ? 'German' : 'English'} horoscope interpretation (400–500 words, 5 paragraphs, Markdown, no bullet points). Address the reader as "${lang === 'de' ? 'du' : 'you'}".

STRUCTURE — each paragraph MUST cross-reference at least two systems:

1. **Your Cosmic Identity**: Start with the Western Sun sign and immediately bridge to the BaZi Day Master. What does THIS specific combination reveal that neither system alone can show?

2. **Emotional Depths**: Connect Moon sign with the BaZi pillars' emotional patterns. How does Wu-Xing's dominant element color these emotional currents?

3. **The Fusion Revelation**: This is the core. Use the fusion data to reveal the UNIQUE intersection — the pattern that emerges ONLY when Western + BaZi + Wu-Xing are layered together. This is what no other app can show. Make this paragraph feel like a discovery.

4. **Wu-Xing Balance**: Which elements are strong, which are weak? How does this elemental map interact with the Western Ascendant? Give one concrete life recommendation based on elemental balance.

5. **Your Path Forward**: Synthesize all three systems into a forward-looking invitation. End with a sentence that makes the reader feel truly seen.

TONE: Warm, precise, mystical but grounded. Never generic. Every sentence must feel like it was written for THIS specific birth chart.
`.trim();
}

// ── Main export ────────────────────────────────────────────────────────────

/**
 * @param data   The full BAFE API results
 * @param lang   The user's current language preference ("en" | "de")
 */
export async function generateInterpretation(data: unknown, lang: string = "en") {
  // Template-based interpretation from actual BAFE data (always available)
  const templateText = generateTemplateInterpretation(data, lang);

  // If Gemini API key is configured, try AI-generated interpretation first
  if (ai) {
    try {
      const response = (await Promise.race([
        ai.models.generateContent({
          model: "gemini-2.0-flash",
          contents: buildPrompt(data, lang),
          config: { temperature: 0.75 },
        }),
        new Promise((_, reject) =>
          setTimeout(() => reject(new Error("Gemini API timeout")), 20000),
        ),
      ])) as { text?: string };

      const aiText = response.text?.trim();
      if (aiText) return aiText;
    } catch (error) {
      console.warn("Gemini API failed or timed out, using template fallback:", error);
    }
  }

  // Use personalized template interpretation built from BAFE data
  if (templateText) return templateText;

  // Last resort: generic text (should rarely happen — only if BAFE returned no data)
  return lang === "de"
    ? "## Dein Bazodiac Fusion-Blueprint\n\nDein kosmisches Profil wird berechnet. Die vollständige Interpretation basierend auf deinen Geburtsdaten wird in Kürze verfügbar sein."
    : "## Your Bazodiac Fusion Blueprint\n\nYour cosmic profile is being calculated. The full interpretation based on your birth data will be available shortly.";
}
