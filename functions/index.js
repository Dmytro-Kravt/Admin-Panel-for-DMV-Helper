const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { GoogleGenerativeAI } = require("@google/generative-ai");

const geminiApiKey = defineSecret("GEMINI_API_KEY");

exports.generateQuestions = onCall(
  { secrets: [geminiApiKey] },
  async (request) => {

    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Нет доступа.");
    }

    // Теперь мы ждем ДВА параметра от Flutter: сырой текст и сам промпт
    const rawText = request.data.rawText;
    const systemPrompt = request.data.systemPrompt;

    if (!rawText || !systemPrompt) {
      throw new HttpsError("invalid-argument", "Отсутствуют данные или промпт для генерации.");
    }

    try {
      const genAI = new GoogleGenerativeAI(geminiApiKey.value());

      const model = genAI.getGenerativeModel({
        model: "gemini-3.1-flash-lite-preview",
        generationConfig: { responseMimeType: "application/json" },
        // Подставляем промпт, который прилетел из Remote Config
        systemInstruction: systemPrompt
      });

      const prompt = `Сырой текст: ${rawText}`;

      const result = await model.generateContent(prompt);
      const aiResponseText = result.response.text();

      return { resultData: aiResponseText };

    } catch (error) {
      console.error("Gemini Error:", error);
      throw new HttpsError("internal", "Ошибка на сервере при генерации ИИ.");
    }
  }
);