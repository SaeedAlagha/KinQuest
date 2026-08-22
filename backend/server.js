const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const { GoogleGenAI } = require("@google/genai");

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json({ limit: "2mb" }));
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
app.post("/api/memory-challenge", async (req, res) => {
  try {
    const {
      imageUrl,
      title,
      description,
      location,
      date,
      count,
    } = req.body;

    if (!imageUrl) {
      return res.status(400).json({
        error: "Memory image is required",
      });
    }

    const requestedCount = Number(count) || 3;
    const questionCount = Math.min(Math.max(requestedCount, 1), 5);

    const imageResponse = await fetch(imageUrl);

    if (!imageResponse.ok) {
      throw new Error("Could not download memory image");
    }

    const imageArrayBuffer = await imageResponse.arrayBuffer();

    const base64Image = Buffer.from(imageArrayBuffer).toString("base64");

    const contentType =
      imageResponse.headers.get("content-type") || "image/jpeg";

    const prompt = `
Create exactly ${questionCount} multiple-choice questions for a family memory game.

Memory information:

Title: ${title || "Not provided"}
Story: ${description || "Not provided"}
Location: ${location || "Not provided"}
Date: ${date || "Not provided"}

You are also given the actual family photo.

This game is called Memory Challenge.

The purpose is to help family members remember real shared moments.

Generate a mixture of these question styles:

1. VISUAL
Ask about a clearly visible detail in the photo.

Examples:
- What color is the object shown?
- What activity appears to be happening?
- Which item can be seen in the photo?

2. STORY
Ask something directly supported by the written memory story.

3. PLACE
Ask about the saved location only when a useful location was provided.

4. MEMORY
Connect information visible in the photo with information from the written story.

Important rules:

- Every answer MUST be supported by either the photo or the supplied memory information.
- Never invent names, relationships, locations, events, emotions, or facts.
- Do not identify or guess the identity of a person from their face.
- Do not infer sensitive personal information from appearance.
- If a detail is uncertain, do not ask about it.
- Questions must be family friendly.
- Appropriate for children and adults.
- Avoid embarrassing questions.
- Avoid medical, political, sexual, hateful, violent, or otherwise sensitive topics.
- Each question must have exactly 4 answer options.
- Exactly one option must be correct.
- Wrong options should be believable but clearly incorrect.
- Keep questions concise.
- Do not repeat questions.

Return ONLY valid JSON.
`;

    const response = await ai.models.generateContent({
      model: "gemini-3.5-flash",
      contents: [
        {
          inlineData: {
            mimeType: contentType,
            data: base64Image,
          },
        },
        {
          text: prompt,
        },
      ],
      config: {
        responseMimeType: "application/json",
        responseJsonSchema: {
          type: "object",
          properties: {
            questions: {
              type: "array",
              minItems: questionCount,
              maxItems: questionCount,
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
                  type: {
                    type: "string",
                    enum: [
                      "visual",
                      "story",
                      "place",
                      "memory",
                    ],
                  },
                },
                required: [
                  "question",
                  "options",
                  "correctIndex",
                  "type",
                ],
              },
            },
          },
          required: ["questions"],
        },
      },
    });

    const result = JSON.parse(response.text);

    if (!Array.isArray(result.questions)) {
      throw new Error(
        "Gemini returned an invalid Memory Challenge response",
      );
    }

    res.json({
      questions: result.questions,
    });
  } catch (error) {
    console.error("Memory Challenge generation error:", error);

    res.status(500).json({
      error: "Failed to generate Memory Challenge questions",
    });
  }
});
app.post("/api/family-impostor", async (req, res) => {
  try {
    const { rounds } = req.body;

    const requestedRounds = Number(rounds) || 5;
    const roundCount = Math.min(Math.max(requestedRounds, 1), 10);

    const prompt = `
Generate exactly ${roundCount} Family Impostor rounds.

This is for KinQuest, a family bonding game played by children and adults together.

For each round, generate:
- one simple category
- one secret word that belongs to that category

Good categories include:
- Food
- Places
- Animals
- Objects
- Activities
- Movies
- Sports
- Travel
- Nature
- School
- Home

Rules:
- Family friendly
- Easy enough for different age groups
- The secret word should be recognizable
- Avoid very obscure words
- No politics
- No sexual content
- No drugs or alcohol
- No graphic violence
- No hateful content
- No duplicate secret words
- Keep category and word concise

Return ONLY valid JSON in this exact structure:

{
  "rounds": [
    {
      "category": "Places",
      "word": "Beach"
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
            rounds: {
              type: "array",
              items: {
                type: "object",
                properties: {
                  category: {
                    type: "string",
                  },
                  word: {
                    type: "string",
                  },
                },
                required: ["category", "word"],
              },
            },
          },
          required: ["rounds"],
        },
      },
    });

    const result = JSON.parse(response.text);

    res.json(result);
  } catch (error) {
    console.error("Family Impostor generation error:", error);

    res.status(500).json({
      error: "Failed to generate Family Impostor rounds",
    });
  }
});app.post("/api/secret-mission", async (req, res) => {
  try {
    const { players, language } = req.body;

    if (!Array.isArray(players) || players.length < 2) {
      return res.status(400).json({
        error: "At least two players are required",
      });
    }

    const cleanedPlayers = players
      .filter((player) => typeof player === "string")
      .map((player) => player.trim())
      .filter((player) => player.length > 0)
      .slice(0, 12);

    if (cleanedPlayers.length < 2) {
      return res.status(400).json({
        error: "At least two valid players are required",
      });
    }

    const outputLanguage =
      language === "ar" ? "Arabic" : "English";

    const prompt = `
You generate missions for a family party game called Secret Mission.

The game is played together in person using one shared phone.

Players:
${cleanedPlayers.map((player) => `- ${player}`).join("\n")}

Generate exactly one DIFFERENT secret mission for each player.

Write all visible mission text in ${outputLanguage}.

HOW THE GAME WORKS:
Each player privately sees their mission.
They then try to complete the mission naturally without the other players realizing what their mission is.

GOOD EXAMPLES:
- Get someone to say "really?"
- Make two people laugh without telling a joke
- Convince someone to bring you a glass of water
- Use the word "banana" naturally three times
- Get someone to copy one of your gestures
- Get someone to ask what you are doing
- Make somebody mention food
- Get two people to agree with you about something silly
- Get somebody to compliment something in the room
- Make someone look behind them

RULES:
- Family friendly
- Suitable for children and adults
- Safe
- Funny or social
- Realistically achievable during a family gathering
- Each mission must be different
- Keep missions short
- Nothing dangerous
- Nothing sexual
- Nothing hateful
- Nothing humiliating
- No drugs or alcohol
- No politics
- No physical fighting
- Do not require spending money
- Do not require leaving the home
- Do not damage property
- Do not require physical contact
- Do not request private information
- Do not ask someone to lie about something serious
- Do not tell the player to reveal their mission
- Do not explain the mission
- Do not mention AI

IMPORTANT:
The playerName field must match one of the supplied player names EXACTLY.

Return ONLY valid JSON:

{
  "missions": [
    {
      "playerName": "Exact player name",
      "mission": "Secret mission"
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
            missions: {
              type: "array",
              items: {
                type: "object",
                properties: {
                  playerName: {
                    type: "string",
                  },
                  mission: {
                    type: "string",
                  },
                },
                required: ["playerName", "mission"],
              },
            },
          },
          required: ["missions"],
        },
      },
    });

    const result = JSON.parse(response.text);

    if (
      !Array.isArray(result.missions) ||
      result.missions.length !== cleanedPlayers.length
    ) {
      throw new Error(
        "Gemini returned an invalid number of missions",
      );
    }

    for (const mission of result.missions) {
      if (
        typeof mission.playerName !== "string" ||
        typeof mission.mission !== "string" ||
        mission.mission.trim().length === 0
      ) {
        throw new Error("Gemini returned an invalid mission");
      }
    }

    res.json({
      missions: result.missions,
    });
  } catch (error) {
    console.error("Secret Mission generation error:", error);

    res.status(500).json({
      error: "Failed to generate Secret Mission missions",
    });
  }
});app.post("/api/caption-battle/modes", async (req, res) => {
  try {
    const { count, language } = req.body;

    const requestedCount = Number(count) || 3;
    const modeCount = Math.min(Math.max(requestedCount, 1), 5);

    const outputLanguage =
      language === "ar" ? "Arabic" : "English";

    const prompt = `
You create round themes for a family party game called Caption Battle.

During each round:
- The family sees one real family photo.
- Every player secretly writes a caption.
- Captions are shown anonymously.
- Everyone votes for their favorite caption.
- Players cannot vote for their own caption.

Generate exactly ${modeCount} DIFFERENT round themes.

Write every theme in ${outputLanguage}.

The theme must be short and instantly understandable.

Examples of the STYLE:
- Funny Caption
- Breaking News
- Movie Title
- Wrong Answers Only
- Future Historian
- Family Documentary
- Social Media Post
- What Happened Next?

Do not simply copy the examples every time.

Rules:
- Family friendly
- Suitable for all ages
- Encourage creativity and humor
- Maximum about 5 words per theme
- No duplicate themes
- No sexual content
- No hateful content
- No graphic violence
- No bullying
- No politics

Return ONLY valid JSON:

{
  "modes": [
    "Funny Caption",
    "Breaking News",
    "Movie Title"
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
            modes: {
              type: "array",
              items: {
                type: "string",
              },
            },
          },
          required: ["modes"],
        },
      },
    });

    const result = JSON.parse(response.text);

    if (
      !Array.isArray(result.modes) ||
      result.modes.length !== modeCount
    ) {
      throw new Error("Gemini returned an invalid Caption Battle mode count");
    }

    const cleanedModes = result.modes
      .filter((mode) => typeof mode === "string")
      .map((mode) => mode.trim())
      .filter((mode) => mode.length > 0);

    if (cleanedModes.length !== modeCount) {
      throw new Error("Gemini returned invalid Caption Battle modes");
    }

    res.json({
      modes: cleanedModes,
    });
  } catch (error) {
    console.error("Caption Battle mode generation error:", error);

    res.status(500).json({
      error: "Failed to generate Caption Battle modes",
    });
  }
});
app.post("/api/pass-the-bomb", async (req, res) => {
  try {
    const { count } = req.body;

    const requestedCount = Number(count) || 5;
    const categoryCount = Math.min(
      Math.max(requestedCount, 1),
      10,
    );

    const prompt = `
Generate exactly ${categoryCount} categories for a family game called Pass the Bomb.

KinQuest is a family bonding app played together on one shared phone.

During each round, players take turns naming something that matches the category.
They cannot repeat an answer.
A hidden random timer is running while the phone is passed around.

The categories should create quick, funny, easy conversation.

Good examples:

- Things you find in a kitchen
- Animals that live in water
- Things you bring on holiday
- Things people do before school
- Foods you eat with your hands
- Excuses for being late
- Things Grandma might say
- Things you should not bring camping
- Things found in a family living room
- Things people forget at home
- Reasons someone might laugh
- Things you might see at the beach

Rules:

- Family friendly
- Suitable for children and adults
- Easy enough that many answers are possible
- Each category should allow at least 10 reasonable answers
- Mix normal categories with funny creative categories
- No politics
- No sexual content
- No drugs or alcohol
- No graphic violence
- No hateful content
- No duplicate categories
- Keep each category short
- Do not include answers
- Do not number the category text

Return ONLY valid JSON in this exact structure:

{
  "categories": [
    "Things you find in a kitchen",
    "Animals that live in water"
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
            categories: {
              type: "array",
              items: {
                type: "string",
              },
              minItems: categoryCount,
              maxItems: categoryCount,
            },
          },
          required: ["categories"],
        },
      },
    });

    const result = JSON.parse(response.text);

    res.json(result);
  } catch (error) {
    console.error(
      "Pass the Bomb generation error:",
      error,
    );

    res.status(500).json({
      error: "Failed to generate Pass the Bomb categories",
    });
  }
});
app.post("/api/pass-the-bomb/validate", async (req, res) => {
  try {
    const { category, answer } = req.body;

    if (
      typeof category !== "string" ||
      category.trim().length === 0 ||
      typeof answer !== "string" ||
      answer.trim().length === 0
    ) {
      return res.status(400).json({
        valid: false,
        reason: "Missing category or answer.",
      });
    }

    const prompt = `
You are the answer judge for a fast family party game called Pass the Bomb.

CATEGORY:
"${category.trim()}"

PLAYER ANSWER:
"${answer.trim()}"

Decide whether the player's answer reasonably belongs in the category.

Judge like a normal, friendly family playing together.

ACCEPT:
- Clearly correct answers
- Common synonyms
- Singular/plural differences
- Minor spelling mistakes when the intended word is obvious
- Informal wording
- Creative answers that reasonably fit the category

REJECT:
- Completely unrelated answers
- Random words
- Gibberish
- Nonsense
- Answers that clearly contradict the category

IMPORTANT:
Be forgiving.
Do not reject a reasonable answer just because it is unusual.

Examples:

Category: Animals that live in water
Answer: Shark
Valid: true

Category: Animals that live in water
Answer: Microwave
Valid: false

Category: Things found in a kitchen
Answer: Fridge
Valid: true

Category: Things found in a kitchen
Answer: Cloud
Valid: false

Return ONLY valid JSON:

{
  "valid": true,
  "reason": "Short explanation"
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
            valid: {
              type: "boolean",
            },
            reason: {
              type: "string",
            },
          },
          required: ["valid", "reason"],
        },
      },
    });

    const result = JSON.parse(response.text);

    res.json({
      valid: result.valid === true,
      reason:
        typeof result.reason === "string"
          ? result.reason
          : "",
    });
  } catch (error) {
    console.error(
      "Pass the Bomb answer validation error:",
      error,
    );

    res.status(500).json({
      error: "Failed to validate Pass the Bomb answer",
    });
  }
});
app.post("/api/draw-and-guess", async (req, res) => {
  try {
    const { count } = req.body;

    const requestedCount = Number(count) || 6;
    const promptCount = Math.min(Math.max(requestedCount, 1), 12);

    const prompt = `
Generate exactly ${promptCount} unique drawing prompts for a family game called Draw & Guess.

This game is played by children and adults together.

Rules:
- Family friendly
- Easy to understand
- Fun to draw
- Fun to guess aloud
- Avoid prompts that are too abstract
- Avoid prompts that require writing words
- Mix animals, objects, actions, funny situations, and imaginative combinations
- No sexual content
- No graphic violence
- No drugs or alcohol
- No politics
- No hateful content
- No duplicate prompts
- Keep each prompt concise

Good examples:
- A penguin cooking dinner
- A cat driving a bus
- A dinosaur at the beach
- A robot making pancakes

Return ONLY valid JSON in this exact structure:

{
  "prompts": [
    {
      "text": "A penguin cooking dinner"
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
    console.error("Draw & Guess generation error:", error);

    res.status(500).json({
      error: "Failed to generate Draw & Guess prompts",
    });
  }
});
app.post("/api/family-missions/verify", async (req, res) => {
  try {
    const {
      missionId,
      title,
      description,
      proofHint,
      note,
      mimeType,
      imageBase64,
    } = req.body ?? {};

    if (
      typeof missionId !== "string" ||
      typeof title !== "string" ||
      typeof description !== "string" ||
      typeof imageBase64 !== "string" ||
      imageBase64.length === 0
    ) {
      return res.status(400).json({
        error: "Mission and proof image are required",
      });
    }

    const allowedMimeTypes = new Set([
      "image/jpeg",
      "image/png",
      "image/webp",
    ]);

    const normalizedMimeType =
      typeof mimeType === "string" && allowedMimeTypes.has(mimeType)
        ? mimeType
        : "image/jpeg";

    const cleanNote =
      typeof note === "string" ? note.trim().slice(0, 600) : "";

    const cleanProofHint =
      typeof proofHint === "string" ? proofHint.trim().slice(0, 500) : "";

    const prompt = `
You verify evidence submitted for a family activity mission in an app.

MISSION TITLE:
${title}

MISSION DESCRIPTION:
${description}

EXPECTED OR USEFUL PROOF:
${cleanProofHint || "A relevant image reasonably connected to the activity."}

USER EXPLANATION:
${cleanNote || "No explanation provided."}

You will also receive the submitted image.

Your goal is NOT to prove with absolute certainty that every detail happened.
Instead, determine whether the submitted evidence REASONABLY SUPPORTS that the
mission was completed.

Be fair to genuine users.

Important rules:
- Do not claim certainty about events that cannot be known from the image.
- A screenshot may be valid when appropriate, such as proof of a video call.
- A photo may be valid even if every participant is not visible.
- The explanation can provide context, but it cannot rescue completely unrelated evidence.
- Reject blank images, unrelated memes, obviously unrelated screenshots, or evidence that clearly does not support the mission.
- Use "uncertain" when the evidence is relevant but insufficient or ambiguous.
- Use "verified" when the evidence reasonably supports completion.
- Use "rejected" only when the evidence is clearly unrelated, unusable, or contradicts the mission.
- Do not identify people.
- Do not infer sensitive personal traits.
- Keep the reason brief, respectful, and useful.

Return ONLY JSON.

Allowed verdict values:
- "verified"
- "uncertain"
- "rejected"

Confidence must be a number from 0 to 1.
`;

    let response;
    let lastError;

    for (let attempt = 1; attempt <= 3; attempt += 1) {
      try {
        response = await ai.models.generateContent({
          model: "gemini-3.5-flash",
          contents: [
            {
              text: prompt,
            },
            {
              inlineData: {
                mimeType: normalizedMimeType,
                data: imageBase64,
              },
            },
          ],
          config: {
            responseMimeType: "application/json",
            responseJsonSchema: {
              type: "object",
              properties: {
                verdict: {
                  type: "string",
                  enum: ["verified", "uncertain", "rejected"],
                },
                confidence: {
                  type: "number",
                  minimum: 0,
                  maximum: 1,
                },
                reason: {
                  type: "string",
                },
              },
              required: ["verdict", "confidence", "reason"],
            },
          },
        });

        break;
      } catch (error) {
        lastError = error;

        const temporary =
          error?.status === 429 ||
          error?.status === 503;

        if (!temporary || attempt === 3) {
          throw error;
        }

        console.warn(
          `Mission verification AI busy. Retry ${attempt}/3...`,
        );

        await new Promise((resolve) => {
          setTimeout(resolve, attempt * 1500);
        });
      }
    }

    if (!response) {
      throw lastError ?? new Error("AI returned no response");
    }

    const result = JSON.parse(response.text);

    if (
      !["verified", "uncertain", "rejected"].includes(result.verdict) ||
      typeof result.confidence !== "number" ||
      typeof result.reason !== "string"
    ) {
      throw new Error("Invalid mission verification response");
    }

    return res.json({
      verdict: result.verdict,
      confidence: Math.max(0, Math.min(1, result.confidence)),
      reason: result.reason.trim(),
    });
  } catch (error) {
    console.error("Mission verification error:", error);

    if (error?.status === 429 || error?.status === 503) {
      return res.status(503).json({
        error:
          "AI verification is temporarily busy. Your proof was not lost. Please try again in a moment.",
      });
    }

    return res.status(500).json({
      error: "Could not verify mission proof",
    });
  }
});
app.post("/api/dont-say-it", async (req, res) => {
  try {
    const { count } = req.body;

    const requestedCount = Number(count) || 20;
    const cardCount = Math.min(Math.max(requestedCount, 1), 100);

    const prompt = `
Generate exactly ${cardCount} unique cards for a family game called Don't Say It.

For each card provide:
- one secret word
- exactly 4 forbidden words

The player must describe the secret word without saying any forbidden word.

Rules:
- Family friendly
- Suitable for children and adults
- Easy to understand
- Fun to describe
- Avoid obscure words
- Forbidden words should be the most obvious words someone would normally use
- No duplicate secret words
- No sexual content
- No drugs or alcohol
- No graphic violence
- No hateful content
- No politics

Example:

Secret word: Birthday
Forbidden words:
Cake
Candles
Party
Present

Return ONLY valid JSON in this exact structure:

{
  "cards": [
    {
      "word": "Birthday",
      "forbiddenWords": [
        "Cake",
        "Candles",
        "Party",
        "Present"
      ]
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
            cards: {
              type: "array",
              items: {
                type: "object",
                properties: {
                  word: {
                    type: "string",
                  },
                  forbiddenWords: {
                    type: "array",
                    items: {
                      type: "string",
                    },
                  },
                },
                required: ["word", "forbiddenWords"],
              },
            },
          },
          required: ["cards"],
        },
      },
    });

    const result = JSON.parse(response.text);

    res.json(result);
  } catch (error) {
    console.error("Don't Say It generation error:", error);

    res.status(500).json({
      error: "Failed to generate Don't Say It cards",
    });
  }
});

app.post("/api/emoji-guess/check-answer", async (req, res) => {
  try {
    const { expectedAnswer, playerAnswer } = req.body;

    if (!expectedAnswer || !playerAnswer) {
      return res.status(400).json({
        match: false,
      });
    }

    const prompt = `
You are checking an answer for a family Emoji Guess game.

Expected answer:
"${expectedAnswer}"

Player answer:
"${playerAnswer}"

Decide whether the player's answer clearly refers to the same answer.

Allow:
- capitalization differences
- punctuation differences
- small spelling mistakes
- common shortened forms
- answers that clearly identify the same movie, place, animal, food, object, or phrase

Do NOT accept:
- answers that are only vaguely related
- a broader category when a specific answer is expected
- a different answer with similar meaning

Return ONLY valid JSON:

{
  "match": true
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

    res.json({
      match: result.match === true,
    });
  } catch (error) {
    console.error("Emoji Guess answer check error:", error);

    res.status(500).json({
      match: false,
    });
  }
});
app.post("/api/attack-or-defend", async (req, res) => {
  try {
    const { category, difficulty, count, language } = req.body;

    const allowedCategories = new Set([
      "Mixed",
      "General Knowledge",
      "Science",
      "Geography",
      "Sports",
      "Entertainment",
    ]);

    const allowedDifficulties = new Set([
      "easy",
      "medium",
      "hard",
    ]);

    const cleanCategory = allowedCategories.has(category)
      ? category
      : "Mixed";

    const cleanDifficulty = allowedDifficulties.has(difficulty)
      ? difficulty
      : "medium";

    const requestedCount = Number(count) || 20;
    const questionCount = Math.min(
      Math.max(requestedCount, 1),
      50,
    );

    const outputLanguage =
      language === "ar" ? "Arabic" : "English";

    const difficultyInstruction = {
      easy:
        "Use familiar knowledge suitable for younger players and adults. Questions should be straightforward.",
      medium:
        "Use moderately challenging general knowledge suitable for a mixed-age family.",
      hard:
        "Use challenging but reasonable knowledge. Avoid obscure specialist facts.",
    }[cleanDifficulty];

    const categoryInstruction =
      cleanCategory === "Mixed"
        ? "Use a balanced mixture of general knowledge, science, geography, sports, and entertainment."
        : `Focus questions on ${cleanCategory}.`;

    const prompt = `
Generate exactly ${questionCount} unique multiple-choice questions for a competitive family game called Attack or Defend.

Write all visible question and answer text in ${outputLanguage}.

CATEGORY:
${cleanCategory}

DIFFICULTY:
${cleanDifficulty}

${categoryInstruction}
${difficultyInstruction}

HOW THE GAME WORKS:
- Exactly two players compete.
- Correct answers earn energy.
- Players spend energy to attack each other.
- When attacked, the defender receives one of these questions and must answer quickly to block the attack.
- Questions therefore need to be clear enough to answer under time pressure.

RULES:
- Family friendly
- Suitable for children and adults
- Exactly 4 answer options
- Exactly one correct option
- No duplicate questions
- No trick wording
- No ambiguous answers
- Keep question text concise
- Keep answer options concise
- No politics
- No sexual content
- No graphic violence
- No drugs or alcohol
- No hateful content
- Avoid questions whose answers could quickly become outdated
- Do not mention AI
- Do not mention Attack, Shield, Energy, or gameplay mechanics inside the question itself

Return ONLY valid JSON.
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

    if (
      !Array.isArray(result.questions) ||
      result.questions.length !== questionCount
    ) {
      throw new Error(
        "Gemini returned an invalid Attack or Defend question count",
      );
    }

    res.json({
      questions: result.questions,
    });
  } catch (error) {
    console.error(
      "Attack or Defend generation error:",
      error,
    );

    res.status(500).json({
      error: "Failed to generate Attack or Defend questions",
    });
  }
});
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`KinQuest Gemini server running on port ${PORT}`);
});
