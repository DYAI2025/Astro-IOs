import { GoogleGenAI } from "@google/genai";

const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

export async function generateInterpretation(data: any) {
  const prompt = `
You are Levi Bazi, an expert astrological AI agent. I have calculated the Western astrology, Chinese BaZi, and Wu-Xing (Five Elements) for a user using the BAFE API.
Here is the data:
${JSON.stringify(data, null, 2)}

Please write a plausible, insightful, and beautifully written astrological horoscope for the user's dashboard.
Focus on the fusion of their Western signs (Sun, Moon, Ascendant) and their Chinese BaZi elements.
Specifically, include detailed insights about their Chinese Zodiac animal and their dominant Wu Xing element, explaining how these interact with their Western traits to form their unique cosmic blueprint.
Provide actionable advice or a plausible horoscope reading based on these combined influences.
Keep it under 250 words. Write it directly to the user (e.g., "Your cosmic blueprint reveals...").
`;

  const response = await ai.models.generateContent({
    model: "gemini-3-flash-preview",
    contents: prompt,
    config: {
      temperature: 0.7,
    },
  });

  return response.text;
}
