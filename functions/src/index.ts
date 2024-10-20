/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

import * as functions from "firebase-functions";
import {OpenAI} from "openai";

// Replace with your OpenAI API key
const OPENAI_API_KEY = functions.config().openai.api_key;

const openai = new OpenAI({
  apiKey: OPENAI_API_KEY,
});

// Type definition for chat completion messages
type ChatCompletionMessage = {
  role: "system" | "user" | "assistant";
  content: string;
};

// Function to handle ChatGPT queries
export const generateResponse = functions.https.onCall(
  async (data) => {
    const userMessages: ChatCompletionMessage[] = data.messages;
    const model = data.model || "gpt-3.5-turbo-0125";

    const prefixMessage: ChatCompletionMessage = {
      role: "system",
      content: "You are a nutrition expert, please only respond " +
      "to questions that are related to diet and nutrition. If the following" +
      "prompt is not related to diet or nutrition, please reject to answer.",
    };
    // Prepend the prefixMessage to the user's messages
    const messages = [prefixMessage, ...userMessages];

    try {
      const response = await openai.chat.completions.create({
        model: model,
        messages: messages,
      });

      const content = response.choices[0].message.content;
      const tokensUsed = response.usage?.total_tokens;

      return {
        content: content,
        tokensUsed: tokensUsed,
      };
    } catch (error) {
      console.error("Error calling OpenAI API:", error);
      throw new functions.https.HttpsError(
        "internal",
        "OpenAI API call failed"
      );
    }
  }
);

// Function to validate food items
export const validFoodItem = functions.https.onCall(
  async (data) => {
    const imageUrl = data.imageUrl;

    try {
      const response = await openai.chat.completions.create({
        model: "gpt-4o",
        messages: [
          {
            role: "user",
            content: [
              {type: "text", text:
                "You are a nutrition expert. Please tell me if the image " +
                "contains any types of food." +
                "Please only give YES or NO answer." +
                "If you are not sure, then answer NO."},
              {
                type: "image_url",
                image_url: {
                  "url": imageUrl,
                },
              },
            ],
          },
        ],
      });

      const answer = response.choices[0].message?.content
        ?.trim()
        .toUpperCase();
      return {valid: answer === "YES"};
    } catch (error) {
      console.error("Error calling OpenAI API:", error);
      throw new functions.https.HttpsError(
        "internal",
        "OpenAI API call failed"
      );
    }
  }
);

// Function to generate calorie count from image
export const generateCalories = functions.https.onCall(
  async (data) => {
    const imageUrl = data.imageUrl;

    try {
      const response = await openai.chat.completions.create({
        model: "gpt-4o",
        messages: [
          {
            role: "user",
            content: [
              {type: "text", text:
                "You are a nutrition expert. Please estimate the " +
                "calories of the provided image." + "Please only " +
                "provide the calorie number, do not give any textual" +
                "explanation."},
              {
                type: "image_url",
                image_url: {
                  "url": imageUrl,
                },
              },
            ],
          },
        ],
        max_tokens: 30,
      });
      const calorieString = response.choices[0].message?.content?.trim();
      return {calories: calorieString};
    } catch (error) {
      console.error("Error calling OpenAI API:", error);
      throw new functions.https.HttpsError(
        "internal",
        "OpenAI API call failed"
      );
    }
  }
);

// Function to generate meal name from image
export const generateMealName = functions.https.onCall(
  async (data) => {
    const imageUrl = data.imageUrl;

    try {
      const response = await openai.chat.completions.create({
        model: "gpt-4o",
        messages: [
          {
            role: "user",
            content: [
              {type: "text", text:
                "You are a nutrition expert. Please predict the name " +
                "of the food." + "Please only provide the name of the food."},
              {
                type: "image_url",
                image_url: {
                  "url": imageUrl,
                },
              },
            ],
          },
        ],
      });

      const mealName = response.choices[0].message?.content?.trim();
      return {mealName: mealName};
    } catch (error) {
      console.error("Error calling OpenAI API:", error);
      throw new functions.https.HttpsError(
        "internal",
        "OpenAI API call failed"
      );
    }
  }
);

// Function that merges the 3 functions above (ACTIVE RIGHT NOW).
export const analyzeFoodImage = functions.https.onCall(
  async (data) => {
    const imageUrl = data.imageUrl;

    try {
      const response = await openai.chat.completions.create({
        model: "gpt-4o",
        messages: [
          {
            role: "user",
            content: [
              {
                type: "text",
                text: `You are a nutrition expert. Based on the provided image,
                please answer the following questions in the format below.
                First, tell me if the image contains any types of food (YES/NO)
                .
                Second, estimate the number of calories in the picture. Provide
                the calorie number as a single value only. Do not give a range.
                If there is packaging information, utilize these information.
                Third, predict the name of the food. 
                Use the following format for the response:
                Food: [YES/NO]
                Calories: [calorie_number]
                Meal: [food_name]`,
              },
              {
                type: "image_url",
                image_url: {
                  url: imageUrl,
                },
              },
            ],
          },
        ],
        max_tokens: 100, // Adjust tokens based on response size
      });

      const result = response.choices[0].message?.content?.trim();

      // Parse the response string into structured data
      const lines = result?.split("\n") || [];
      const foodMatch = lines.find((line) => line.startsWith("Food:"));
      const calorieMatch = lines.find((line) => line.startsWith("Calories:"));
      const mealMatch = lines.find((line) => line.startsWith("Meal:"));

      const valid = foodMatch?.split("Food: ")[1]?.trim() === "YES";
      const calories = calorieMatch?.split("Calories: ")[1]?.trim();
      const mealName = mealMatch?.split("Meal: ")[1]?.trim();

      return {
        valid,
        calories,
        mealName,
      };
    } catch (error) {
      console.error("Error calling OpenAI API:", error);
      throw new functions.https.HttpsError(
        "internal",
        "OpenAI API call failed"
      );
    }
  }
);
