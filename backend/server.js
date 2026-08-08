const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const { GoogleGenAI } = require("@google/genai");

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
});

app.get("/", (req, res) => {
  res.json({
    message: "KinQuest Gemini server is running",
  });
});

app.post("/api/would-you-rather", async (req, res) => {
  try {
    const { category, count } = req.body;

    if (!category) {
      return res.status(400).json({
        error: "Category is required",
      });
    }

    const requestedCount = Number(count) || 5;
    const questionCount = Math.min(Math.max(requestedCount, 1), 10);

    const prompt = `
Generate exactly ${questionCount} unique Would You Rather questions.

Category: ${category}

This is for KinQuest, a family game.

Rules:
- Family friendly
- Appropriate for children and adults
- Fun and interesting
- No sexual content
- No graphic violence
- No drugs or alcohol
- No politics
- No hateful content
- No duplicate questions
- Keep each option concise

Return ONLY valid JSON in this exact format:

{
  "questions": [
    {
      "optionA": "first choice",
      "optionB": "second choice"
    }
  ]
}
`;

    const response = await ai.models.generateContent({
      model: "gemini-3.5-flash",
      contents: prompt,
      config: {
        responseMimeType: "application/json",
      },
    });

    const result = JSON.parse(response.text);

    res.json(result);
  } catch (error) {
    console.error("Gemini generation error:", error);

    res.status(500).json({
      error: "Failed to generate questions",
    });
  }
});
app.post("/api/charades", async (req, res) => {
  try {
    const { category, count } = req.body;

    if (!category) {
      return res.status(400).json({ error: "Category is required" });
    }

    const requestedCount = Number(count) || 10;
    const promptCount = Math.min(Math.max(requestedCount, 1), 20);

    const prompt = `
Generate exactly ${promptCount} unique Charades prompts.

Category: ${category}

This is for KinQuest, a family game.

Rules:
- Family friendly
- Appropriate for children and adults
- Easy to act out
- No sexual content
- No graphic violence
- No drugs or alcohol
- No politics
- No hateful content
- No duplicate prompts
- Keep each prompt short
- Return actions, animals, objects, people types, or situations depending on the category

Return ONLY valid JSON in this exact format:

{
  "prompts": [
    {
      "text": "charades prompt"
    }
  ]
}
`;

    const response = await ai.models.generateContent({
      model: "gemini-3.5-flash",
      contents: prompt,
      config: {
        responseMimeType: "application/json",
      },
    });

    const result = JSON.parse(response.text);
    res.json(result);
  } catch (error) {
    console.error("Charades generation error:", error);
    res.status(500).json({
      error: "Failed to generate charades prompts",
    });
  }
});
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`KinQuest Gemini server running on port ${PORT}`);
});