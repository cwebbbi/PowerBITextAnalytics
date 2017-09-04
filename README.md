# PowerBITextAnalytics
A Power BI custom data connector for the Microsoft Cognitive Services Text Analytics API

Full documentation for the Text Analytics API can be found [here](https://docs.microsoft.com/en-us/azure/cognitive-services/text-analytics/overview) and there is more detailed documentation available for the [Detect Language](https://westus.dev.cognitive.microsoft.com/docs/services/TextAnalytics.V2.0/operations/56f30ceeeda5650db055a3c7), [Key Phrases](https://westus.dev.cognitive.microsoft.com/docs/services/TextAnalytics.V2.0/operations/56f30ceeeda5650db055a3c6) and [Sentiment](https://westus.dev.cognitive.microsoft.com/docs/services/TextAnalytics.V2.0/operations/56f30ceeeda5650db055a3c9) APIs. 

Note: you will need to [sign up for the Text Analytics API](https://docs.microsoft.com/en-us/azure/cognitive-services/text-analytics/text-analytics-howto-signup) and [obtain an access key](https://docs.microsoft.com/en-us/azure/cognitive-services/text-analytics/text-analytics-howto-accesskey) before you use this custom data connector. A number of [pricing tiers](https://azure.microsoft.com/en-us/pricing/details/cognitive-services/text-analytics/) are available, including a free tier that allows for 5000 calls per month.

# Functionality
This custom data connector exposes three M functions:
- TextAnalytics.DetectLanguage(inputtext as list, optional numberoflanguages as number) as table
This function takes a list of text values and returns a table containing the input text and the language detected in each piece of text
- TextAnalytics.KeyPhrases(inputtext as list, optional languages as list) as table 
This function takes a list of text values (and an optional list of language identifiers for each piece of text) and returns a table containing the input text and key phrases detected in each piece of text. More than one key phrase may be returned for each piece of text.
- TextAnalytics.Sentiment(inputtext as list, optional languages as list) as table
This function takes a list of text values (and an optional list of language identifiers for each piece of text) and returns a table containing the input text and a score representing the sentiment detected for each piece of text.

There are a number of examples of how these functions can be used in the TextAnalytics.query.pq file included in the project, as well as this blog post on Chris Webb's BI Blog.
