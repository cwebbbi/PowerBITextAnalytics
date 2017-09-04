// This file contains a number of M queries to test the functions in this custom data connector
// uncomment a single let expression to test each query

//Detect Language without specifying number of languages
/*
let
    input = {"hello all", "this is a test", "bonjour hello", "guten tag"},
    result = TextAnalytics.DetectLanguage(input)
in
    result
    */

//Detect Language with number of languages specified
/*
let
    input = {"hello all", "this is a test", "bonjour hello", "guten tag"},
    result = TextAnalytics.DetectLanguage(input,2)
in
    result
*/  

//Key Phrases without specifying language, input text all English phrases
/*
let
    input = {"blue is my favourite colour", "what time it is please?", "twinkle, twinkle little star, how I wonder what you are"},
    result = TextAnalytics.KeyPhrases(input)
in
    result
    */

//Key Phrases specifying language of the input text
/*
let
    input = {"blue is my favourite colour", "Ich spreche nicht viel Deutsch", "Je suis un homme", "¿Dónde hay un restaurante?"},
    languages = {"en", "de", "fr", "es"},
    result = TextAnalytics.KeyPhrases(input, languages)
in
    result
    */

 //Sentiment without specifying language, input text all English phrases 
 /*
 let
     input = {"this is great", "this is terrible", "this is so-so"},
     result = TextAnalytics.Sentiment(input)
in
    result
    */
    

 //Sentiment in multiple languages
 
let
     input = {"This is great", "Je ne suis pas content", "¿Dónde hay un restaurante?"},
     languages = {"en", "fr", "es"},
     result = TextAnalytics.Sentiment(input, languages)
in
    result

