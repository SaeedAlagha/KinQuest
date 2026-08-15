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
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`KinQuest Gemini server running on port ${PORT}`);
});
