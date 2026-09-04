const assert = require("node:assert/strict");
const fs = require("node:fs");
const test = require("node:test");

test("games and Sila Chat keep separate server-side AI providers", () => {
  const server = fs.readFileSync("server.js", "utf8");
  const gameAi = fs.readFileSync("game_ai.js", "utf8");
  const silaChat = fs.readFileSync("sila_chat.js", "utf8");

  assert.match(server, /gameAi\.generateContent/);
  assert.doesNotMatch(server, /openrouter\.ai/);
  assert.match(gameAi, /GoogleGenAI/);
  assert.doesNotMatch(gameAi, /OpenRouter|openrouter\.ai/);
  assert.match(silaChat, /openrouter\.ai\/api\/v1\/chat\/completions/);
  assert.doesNotMatch(silaChat, /GoogleGenAI|GEMINI_API_KEY/);
});

test("Flutter client does not contain Gemini or OpenRouter API secrets", () => {
  const dartFiles = [];

  function visit(directory) {
    for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
      const path = `${directory}/${entry.name}`;
      if (entry.isDirectory()) visit(path);
      if (entry.isFile() && path.endsWith(".dart")) dartFiles.push(path);
    }
  }

  visit("../lib");
  const clientSource = dartFiles
    .map((path) => fs.readFileSync(path, "utf8"))
    .join("\n");

  assert.doesNotMatch(clientSource, /GEMINI_API_KEY|OPENROUTER_API_KEY/);
  assert.doesNotMatch(clientSource, /openrouter\.ai\/api|generativelanguage\.googleapis\.com/);
});
