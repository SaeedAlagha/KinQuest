const { GoogleGenAI } = require("@google/genai");

const DEFAULT_GEMINI_MODEL = "gemini-3.8-flash";
const DEFAULT_GEMINI_FALLBACK_MODEL = "gemini-2.5-flash";
const RETRYABLE_STATUS_CODES = new Set([429, 500, 502, 503, 504]);

class GameAiConfigurationError extends Error {
  constructor(message) {
    super(message);
    this.name = "GameAiConfigurationError";
    this.statusCode = 503;
  }
}

function errorStatus(error) {
  const status = Number(error?.status ?? error?.statusCode);
  return Number.isFinite(status) ? status : null;
}

function isRetryableProviderError(error) {
  if (error instanceof GameAiConfigurationError) return false;
  return RETRYABLE_STATUS_CODES.has(errorStatus(error));
}

function createGameAi({
  apiKey = process.env.GEMINI_API_KEY,
  primaryModel = process.env.GEMINI_MODEL,
  fallbackModel = process.env.GEMINI_FALLBACK_MODEL,
  client,
  sleep = (milliseconds) =>
    new Promise((resolve) => setTimeout(resolve, milliseconds)),
  retryDelayMs = 400,
} = {}) {
  const normalizedApiKey = apiKey?.trim();
  const normalizedPrimaryModel =
    primaryModel?.trim() || DEFAULT_GEMINI_MODEL;
  const normalizedFallbackModel =
    fallbackModel?.trim() || DEFAULT_GEMINI_FALLBACK_MODEL;
  let resolvedClient = client;

  function getClient() {
    if (resolvedClient) return resolvedClient;
    if (!normalizedApiKey) {
      throw new GameAiConfigurationError(
        "Gemini is not configured on the server.",
      );
    }

    resolvedClient = new GoogleGenAI({ apiKey: normalizedApiKey });
    return resolvedClient;
  }

  async function generateContent(request) {
    const models = [normalizedPrimaryModel];
    if (normalizedFallbackModel !== normalizedPrimaryModel) {
      models.push(normalizedFallbackModel);
    }

    let lastError;
    for (const [modelIndex, model] of models.entries()) {
      const maxAttempts = modelIndex === 0 ? 2 : 1;
      for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
        try {
          return await getClient().models.generateContent({
            ...request,
            model,
          });
        } catch (error) {
          lastError = error;
          if (!isRetryableProviderError(error)) throw error;

          if (attempt < maxAttempts) {
            await sleep(retryDelayMs * attempt);
          }
        }
      }
    }

    throw lastError ?? new Error("Gemini returned no response.");
  }

  return {
    configured: Boolean(normalizedApiKey || client),
    fallbackModel: normalizedFallbackModel,
    generateContent,
    primaryModel: normalizedPrimaryModel,
    provider: "Google Gemini",
  };
}

module.exports = {
  DEFAULT_GEMINI_FALLBACK_MODEL,
  DEFAULT_GEMINI_MODEL,
  GameAiConfigurationError,
  createGameAi,
  isRetryableProviderError,
};
