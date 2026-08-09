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
app.post("/api/never-have-i-ever", async (req, res) => {
  try {
    const { category, count } = req.body;

    if (!category) {
      return res.status(400).json({
        error: "Category is required",
      });
    }

    const requestedCount = Number(count) || 10;
    const promptCount = Math.min(Math.max(requestedCount, 1), 20);

    const prompt = `
Generate exactly ${promptCount} unique Never Have I Ever statements.

Category: ${category}

This is for KinQuest, a family game.

Rules:
- Family friendly
- Appropriate for children and adults
- Fun and lighthearted
- No sexual content
- No graphic violence
- No drugs or alcohol
- No politics
- No hateful content
- No dangerous challenges
- No duplicate statements
- Keep each statement concise
- Start each statement with "Never have I ever"

Return ONLY valid JSON in this exact format:

{
  "prompts": [
    {
      "text": "Never have I ever..."
    }
  ]
}
`;

    const response = await ai.models.generateContent({
      model: "gemini-3.5-flash",
      contents: prompt,
      config: {
  responseMimeType: "application/json",
  responseJsonSchema: {
    type: "object",
    properties: {
      prompts: {
        type: "array",
        items: {
          type: "object",
          properties: {
            text: {
              type: "string",
            },
          },
          required: ["text"],
        },
      },
    },
    required: ["prompts"],
  },
},
    });

    const result = JSON.parse(response.text);

    res.json(result);
  } catch (error) {
    console.error("Never Have I Ever generation error:", error);

    res.status(500).json({
      error: "Failed to generate Never Have I Ever prompts",
    });
  }
});
app.post("/api/trivia", async (req, res) => {
  try {
    const { category, count } = req.body;

    if (!category) {
      return res.status(400).json({
        error: "Category is required",
      });
    }

    const requestedCount = Number(count) || 10;
    const questionCount = Math.min(Math.max(requestedCount, 1), 15);

    const prompt = `
Generate exactly ${questionCount} unique multiple-choice trivia questions.

Category: ${category}

This is for KinQuest, a family game.

Rules:
- Family friendly
- Appropriate for children and adults
- Medium difficulty
- Each question must have exactly 4 answer options
- Only one answer can be correct
- No politics
- No sexual content
- No graphic violence
- No hateful content
- No duplicate questions
- Keep questions and answers concise

Return ONLY valid JSON in this exact structure:

{
  "questions": [
    {
      "question": "question text",
      "options": [
        "answer 1",
        "answer 2",
        "answer 3",
        "answer 4"
      ],
      "correctIndex": 0
    }
  ]
}
`;

    const response = await ai.models.generateContent({
      model: "gemini-3.5-flash",
      contents: prompt,
      config: {
        responseMimeType: "application/json",
        responseJsonSchema: {
          type: "object",
          properties: {
            questions: {
              type: "array",
              items: {
                type: "object",
                properties: {
                  question: {
                    type: "string",
                  },
                  options: {
                    type: "array",
                    minItems: 4,
                    maxItems: 4,
                    items: {
                      type: "string",
                    },
                  },
                  correctIndex: {
                    type: "integer",
                    minimum: 0,
                    maximum: 3,
                  },
                },
                required: [
                  "question",
                  "options",
                  "correctIndex",
                ],
              },
            },
          },
          required: ["questions"],
        },
      },
    });

    const result = JSON.parse(response.text);

    res.json(result);
  } catch (error) {
    console.error("Trivia generation error:", error);

    res.status(500).json({
      error: "Failed to generate trivia questions",
    });
  }
});
app.post("/api/truth-or-dare", async (req, res) => {
  try {
    const { category, count } = req.body;

    if (!category) {
      return res.status(400).json({
        error: "Category is required",
      });
    }

    const requestedCount = Number(count) || 10;
    const promptCount = Math.min(Math.max(requestedCount, 1), 20);

    const prompt = `
Generate exactly ${promptCount} unique Truth or Dare prompts.

Category: ${category}

This is for KinQuest, a family game.

Rules:
- Family friendly
- Appropriate for children and adults
- Mix truth questions and dares
- Fun and lighthearted
- No sexual content
- No graphic violence
- No drugs or alcohol
- No politics
- No hateful content
- No dangerous dares
- No embarrassing or humiliating dares
- No duplicate prompts
- Keep each prompt concise

Return ONLY valid JSON in this structure:

{
  "prompts": [
    {
      "type": "truth",
      "text": "prompt text"
    },
    {
      "type": "dare",
      "text": "prompt text"
    }
  ]
}
`;

    const response = await ai.models.generateContent({
      model: "gemini-3.5-flash",
      contents: prompt,
      config: {
        responseMimeType: "application/json",
        responseJsonSchema: {
          type: "object",
          properties: {
            prompts: {
              type: "array",
              items: {
                type: "object",
                properties: {
                  type: {
                    type: "string",
                    enum: ["truth", "dare"],
                  },
                  text: {
                    type: "string",
                  },
                },
                required: ["type", "text"],
              },
            },
          },
          required: ["prompts"],
        },
      },
    });

    const result = JSON.parse(response.text);

    res.json(result);
  } catch (error) {
    console.error("Truth or Dare generation error:", error);

    res.status(500).json({
      error: "Failed to generate Truth or Dare prompts",
    });
  }
});
app.post("/api/emoji-guess", async (req, res) => {
  try {
    const { category, count } = req.body;

    if (!category) {
      return res.status(400).json({
        error: "Category is required",
      });
    }

    const requestedCount = Number(count) || 10;
    const puzzleCount = Math.min(Math.max(requestedCount, 1), 20);

    const prompt = `
Generate exactly ${puzzleCount} unique Emoji Guess puzzles.

Category: ${category}

This is for KinQuest, a family game.

Rules:
- Family friendly
- Appropriate for children and adults
- Use emojis to represent the answer
- Answers should be easy to medium difficulty
- Keep answers concise
- Give a short helpful hint
- No duplicate puzzles
- No sexual content
- No graphic violence
- No drugs or alcohol
- No politics
- No hateful content

Return ONLY valid JSON in this structure:

{
  "puzzles": [
    {
      "emojis": "🍕🧀",
      "answer": "Cheese Pizza",
      "hint": "A popular food"
    }
  ]
}
`;

    const response = await ai.models.generateContent({
      model: "gemini-3.5-flash",
      contents: prompt,
      config: {
        responseMimeType: "application/json",
        responseJsonSchema: {
          type: "object",
          properties: {
            puzzles: {
              type: "array",
              items: {
                type: "object",
                properties: {
                  emojis: {
                    type: "string",
                  },
                  answer: {
                    type: "string",
                  },
                  hint: {
                    type: "string",
                  },
                },
                required: ["emojis", "answer", "hint"],
              },
            },
          },
          required: ["puzzles"],
        },
      },
    });

    const result = JSON.parse(response.text);
    res.json(result);
  } catch (error) {
    console.error("Emoji Guess generation error:", error);
    res.status(500).json({
      error: "Failed to generate Emoji Guess puzzles",
    });
  }
});
app.post("/api/family-quiz", async (req, res) => {
  try {
    const { category, count, familyMembers } = req.body;

    if (!category) {
      return res.status(400).json({
        error: "Category is required",
      });
    }

    if (!Array.isArray(familyMembers)) {
      return res.status(400).json({
        error: "Family members are required",
      });
    }

    const normalizedFamilyMembers = [
      ...new Set(
        familyMembers
          .map((member) => String(member).trim())
          .filter((member) => member.length > 0),
      ),
    ].slice(0, 8);

    if (normalizedFamilyMembers.length < 2) {
      return res.status(400).json({
        error: "At least 2 unique family members are required",
      });
    }

    const requestedCount = Number(count) || 10;
    const questionCount = Math.min(Math.max(requestedCount, 1), 8);
    const isVotingMode = category === "Most Likely To";

    const categoryInstructions = {
      "Family Fun":
        "Use playful family activities, imaginary situations, and lighthearted choices.",
      Favorites:
        "Ask about favorite foods, movies, hobbies, places, activities, colors, or other preferences.",
      Habits:
        "Ask about personal routines and habits such as sleeping, cleaning, studying, eating, or getting ready.",
      Memories:
        "Ask about family trips, celebrations, funny moments, traditions, and shared experiences without inventing specific past events.",
      "Most Likely To":
        "Generate only friendly 'Who is most likely to...' voting prompts.",
    }[category];

    if (!categoryInstructions) {
      return res.status(400).json({
        error: "Unsupported Family Quiz category",
      });
    }

    const sharedRules = `
This is for KinQuest, a family bonding game.

Rules:
- Family friendly and appropriate for children and adults
- Fun, positive, and lighthearted
- No general knowledge or factual trivia
- No sexual content
- No drugs or alcohol
- No politics
- No hateful, dangerous, or humiliating content
- No duplicate questions
`;

    const prompt = isVotingMode
      ? `
Generate exactly ${questionCount} unique family voting prompts.

Category: ${category}
${categoryInstructions}
Family members playing: ${normalizedFamilyMembers.join(", ")}
${sharedRules}
- Phrase every prompt as "Who is most likely to...?"
- Do not choose a winner or provide a correct answer
- Do not include answer options; the app supplies the family member names

Return ONLY valid JSON in this structure:
{
  "questions": [
    {
      "question": "Who is most likely to organize a surprise family outing?"
    }
  ]
}
`
      : `
Generate exactly ${questionCount} unique Guess My Answer questions.

Category: ${category}
${categoryInstructions}
Family members playing: ${normalizedFamilyMembers.join(", ")}
${sharedRules}
- One rotating family member will answer privately, then the others will guess that real answer
- Phrase each question in the second person using "you" or "your"
- Provide exactly 4 concise and meaningfully different answer choices
- Answer choices must describe preferences, activities, habits, or memories; they must not be family member names
- Do not choose or imply a correct answer

Return ONLY valid JSON in this structure:
{
  "questions": [
    {
      "question": "Which snack would you choose for a family movie night?",
      "options": ["Popcorn", "Pizza", "Fruit", "Ice cream"]
    }
  ]
}
`;

    const questionProperties = isVotingMode
      ? {
          question: {
            type: "string",
          },
        }
      : {
          question: {
            type: "string",
          },
          options: {
            type: "array",
            minItems: 4,
            maxItems: 4,
            items: {
              type: "string",
            },
          },
        };

    const requiredQuestionFields = isVotingMode
      ? ["question"]
      : ["question", "options"];

    const response = await ai.models.generateContent({
      model: "gemini-3.5-flash",
      contents: prompt,
      config: {
        responseMimeType: "application/json",
        responseJsonSchema: {
          type: "object",
          properties: {
            questions: {
              type: "array",
              items: {
                type: "object",
                properties: questionProperties,
                required: requiredQuestionFields,
              },
            },
          },
          required: ["questions"],
        },
      },
    });

    const result = JSON.parse(response.text);

    if (!Array.isArray(result.questions)) {
      throw new Error("Gemini returned an invalid Family Quiz response");
    }

    const questions = result.questions.map((question) => {
      if (typeof question.question !== "string") {
        throw new Error("Gemini returned an invalid Family Quiz question");
      }

      if (isVotingMode) {
        return {
          question: question.question,
          options: normalizedFamilyMembers,
        };
      }

      if (!Array.isArray(question.options) || question.options.length !== 4) {
        throw new Error("Gemini returned invalid Guess My Answer options");
      }

      return {
        question: question.question,
        options: question.options,
      };
    });

    res.json({ questions });
  } catch (error) {
    console.error("Family Quiz generation error:", error);
    res.status(500).json({
      error: "Failed to generate Family Quiz questions",
    });
  }
});
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`KinQuest Gemini server running on port ${PORT}`);
});
