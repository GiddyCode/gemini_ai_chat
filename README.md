
# Google - Gemini AI Chat

<img  alt="FlutterXGemini " src="https://raw.githubusercontent.com/GiddyCode/gemini_ai_chat/main/example/assets/images/FlutterXGemini.png"/>

This package seamlessly integrates Gemini's features into your application, incorporating clean code, robust exception handling, and smooth integration with both new and existing flutter apps. Additionally, it includes a chat feature supporting voice chat, text-only chat, and image+text chat.

# Example 

<table>
  <tr>
    <td>
      <img width="450" src="https://raw.githubusercontent.com/GiddyCode/gemini_ai_chat/main/example/assets/gif/voiceonly.gif" />
    </td>
    <td>
      <img width="450" src="https://raw.githubusercontent.com/GiddyCode/gemini_ai_chat/main/example/assets/gif/textandimage.gif" />
    </td>
  </tr>
</table>


## Setup

- [x] [Prerequisite](#prerequisite)
- [x] [Initialize GeminiAI](#initialize-geminiai)

## Prerequisite

To use Gemini AI, you need to obtain the Gemini AI's API key, for that you need to sign up for a Gemini account at [ai.google.dev](https://ai.google.dev/) Once you have acquired the Gemini API key, you are all set!


## Initialize GeminiAI

Before using GeminiAI you have to initialize it. - Make sure you add your API Key. 

```dart
const apiKey = "--- Your GeminiAI Api Key --- ";

final geminiAI = GeminiAI(
  apiKey: apiKey,
);
```


## Usage

- [x] [Generate contect from text-only input](#voicetext-only-input)
- [x] [Generate content from text and image input](#text-and-image-input)
- [x] [Extra Configuration (Not Rerquired)](#extra-configuration)
- [x] [Safety Settings](#safety-settings)


### Voice/Text only input

You can generate text based content by passing your query (String) in the method.
NB: This is best suited for generating content with text or voice only input as it uses the Gemini-pro model

```dart
String query = "---- Your Query Sytring ----";

geminiAI.generateTextFromQuery(query)
.then((value) => print(value.text))
.catchError((e) => print(e));
```

<table>
  <tr>
    <td>
      <img width="300" src="https://raw.githubusercontent.com/GiddyCode/gemini_ai_chat/main/example/assets/gif/textonly.gif" />
    </td>
    <td>
      <img width="300" src="https://raw.githubusercontent.com/GiddyCode/gemini_ai_chat/main/example/assets/gif/voiceonly.gif" />
    </td>
  </tr>
</table>



### Text and image input

You can also generate text-based content by first selecting an Image from your gallery (or camera) and then adding  the query (String).

```dart
//Get the file you want to analyze from your device or reference it from your asset bundle
File image = File("assets/myimage.png")
String queryText = "---- Your Query Sytring ----";

geminiAI.generateTextFromQueryAndImages(
  query: queryText,
  image: image
)
.then((value) => print(value.text))
.catchError((e) => print(e));
```

<img width="300" src="https://raw.githubusercontent.com/GiddyCode/gemini_ai_chat/main/example/assets/gif/textandimage.gif" />


## Extra Configuration

The library has been developed with the average user in mind. However, if you wish to customize your responses, you can do that by customizing the GenerationConfig.

### Adding the Custom Configuration

**Example**
```dart
// Generation Configuration
final config = GenerationConfig(
    temperature: 0.5, //Temperature controls the degree of randomness in token selection.
    maxOutputTokens: 100, //Token limit determines the maximum amount of text output. 100 tokens is about 60-80 words.
    topP: 1.0, //Top-p, also known as nucleus sampling, controls the cumulative probability of the generated tokens
    topK: 40, //The top-k parameter limits the model’s predictions to the top k most probable tokens at each step of generation
    stopSequences: [] //Define a stopping signal for the model using a unique character sequence to halt content generation. Opt for a sequence unlikely to be found in the generated content to avoid inadvertent interruptions.
);
```

**Add it To The Instance**

```dart
const apiKey = "--- Your GeminiAI Api Key --- ";

// Gemini Instance
final geminiAI = GeminiAI(
    apiKey: apiKey,
    config: config // this is where the config goes
);
```



### Safety settings

To ensure responses are targeted and filtered for particular age groups, target populations or product use cases, The Safety settings can be adjusted.

**Safety Categories**

These are the basic categories in this plugin, you might wish to adjust according to your needs

```dart
HARM_CATEGORY_UNSPECIFIED
HARM_CATEGORY_DEROGATORY
HARM_CATEGORY_TOXICITY
HARM_CATEGORY_VIOLENCE
HARM_CATEGORY_SEXUAL
HARM_CATEGORY_MEDICAL
HARM_CATEGORY_DANGEROUS
HARM_CATEGORY_HARASSMENT
HARM_CATEGORY_HATE_SPEECH
HARM_CATEGORY_SEXUALLY_EXPLICIT
HARM_CATEGORY_DANGEROUS_CONTENT	
```


**Safety Threshold**

This regulates your safety frequency.

```dart
HARM_BLOCK_THRESHOLD_UNSPECIFIED	
BLOCK_LOW_AND_ABOVE	
BLOCK_MEDIUM_AND_ABOVE
BLOCK_ONLY_HIGH	
BLOCK_NONE
```


#### Using it

**Specify Which You Want to use**

```dart
// Safety Settings
final safety1 = SafetySettings(
  category: SafetyCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
  threshold: SafetyThreshold.BLOCK_ONLY_HIGH
);
```

```dart
/*Add it to the GeminiAI Instance*/

final geminiAI = GeminiAI(
  apiKey:"--- Your GeminiAI Api Key ---",
  safetySettings: [
    safety1,
    // safety2
  ]  
);
```

**This Plugin Was Developed By:**

<img  alt="GideonLogo" width="200" src="https://raw.githubusercontent.com/GiddyCode/gemini_ai_chat/main/example/assets/images/gideonLogo.png"/>

