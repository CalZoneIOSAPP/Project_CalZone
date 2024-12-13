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

// Type definition for user profile
interface UserProfile {
  age?: number;
  gender?: string;
  targetCalories?: string;
  bmi?: number;
  weight?: number;
  weightTarget?: number;
  height?: number;
  activityLevel?: string;
}

// Type definition for food item
interface FoodItem {
  name: string;
  calories: number;
  mealType: string;
  timestamp: string;
}

// Function to generate meal suggestions
export const generateMealSuggestion = functions.https.onCall(
  async (data: {
    foodItems: FoodItem[];
    language?: string;
    userProfile?: UserProfile;
  }) => {
    const {foodItems, language = "en", userProfile} = data;

    // Format the food items into a readable string
    const foodItemsSummary = foodItems
      .map((item) =>
        `${item.name} (${item.calories} calories) for ${item.mealType}`
      )
      .join(", ");

    // Format user profile information for the AI
    let userContext = "";
    if (userProfile) {
      const contextParts = [];
      if (userProfile.age) contextParts.push(`age: ${userProfile.age}`);
      if (userProfile.gender) {
        contextParts.push(`gender: ${userProfile.gender}`);
      }
      if (userProfile.bmi) contextParts.push(`BMI: ${userProfile.bmi}`);
      if (userProfile.targetCalories) {
        contextParts.push(
          `daily calorie target: ${userProfile.targetCalories}`);
      }
      if (userProfile.weight && userProfile.weightTarget) {
        contextParts.push(
          `current weight: ${userProfile.weight}kg, ` +
          `target weight: ${userProfile.weightTarget}kg`
        );
      }
      if (userProfile.activityLevel) {
        contextParts.push(`activity level: ${userProfile.activityLevel}`);
      }
      if (contextParts.length > 0) {
        userContext = "User profile - " + contextParts.join(", ") + ". ";
      }
    }

    // Language-specific system prompts
    const systemPrompts: { [key: string]: string } = {
      "en": "You are a helpful nutrition expert and meal planner focused" +
        " only on food suggestions. Provide a very concise analysis of" +
        " today's meals followed by a specific meal suggestion. Consider" +
        " the user's profile for personalized advice. Do not include any" +
        " advice about drinking water or other beverages.",
      "zh-Hans": "你是一位专业的营养专家和膳食规划师，专注于食物建议。" +
        "请根据用户的个人信息，简明扼要地分析今天的饮食状况，然后给出具体" +
        "的膳食建议。请不要包含任何关于饮水或其他饮品的建议。",
      "cs": "Jste užitečný odborník na výživu a plánovač jídel." +
        " Poskytněte velmi stručnou analýzu dnešních jídel a následně" +
        " konkrétní návrh jídla s ohledem na profil uživatele." +
        " Nezahrnujte žádné rady ohledně pití vody nebo jiných nápojů.",
    };

    // Language-specific user prompts
    const userPrompts: { [key: string]: string } = {
      "en": `${userContext}Here are the meals recorded today:` +
        ` ${foodItemsSummary}. In 100 words or less: First, give a 1-2` +
        " sentence analysis of current nutritional balance. Then suggest" +
        " specific foods for the next meal, considering time of day," +
        " calories consumed, and user's profile. Focus on solid foods.",
      "zh-Hans": `${userContext}以下是今天记录的食物：${foodItemsSummary}。` +
        "请在100字以内：首先用1-2句话分析当前的营养均衡状况，然后根据" +
        "时间、已消耗的卡路里和用户的个人情况，具体建议下一餐吃什么。" +
        "仅限于实体食物建议。",
      "cs": `${userContext}Zde jsou jídla zaznamenaná dnes:` +
        ` ${foodItemsSummary}. Ve 100 slovech nebo méně: Nejprve v 1-2` +
        " větách analyzujte současnou nutriční rovnováhu. Poté navrhněte" +
        " konkrétní jídla pro další chod s ohledem na denní dobu a" +
        " spotřebované kalorie. Pouze pevná strava.",
    };

    try {
      const response = await openai.chat.completions.create({
        model: "gpt-4-turbo-preview",
        messages: [
          {
            role: "system",
            content: systemPrompts[language] || systemPrompts["en"],
          },
          {
            role: "user",
            content: userPrompts[language] || userPrompts["en"],
          },
        ],
        max_tokens: 150,
        temperature: 0.7,
      });

      const suggestion = response.choices[0].message.content;
      return {
        suggestion: suggestion?.trim() ||
          "Unable to generate suggestion at this time.",
      };
    } catch (error) {
      console.error("Error generating meal suggestion:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to generate meal suggestion"
      );
    }
  }
);
