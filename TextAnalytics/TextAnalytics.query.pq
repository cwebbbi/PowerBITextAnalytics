// Use this file to write queries to test your data connector
let
    //input = {Text.Repeat("h",5125)},
    //input = List.Repeat({"hello world"},1001),
    //input = {"hello all", "this is a test", "bonjour", "guten tag"},
    //result = TextAnalytics.DetectLanguage(input)
    //input = {"this is great", "this is wonderful", "I hate you so much", "this is terrible", "I don't mind this", "It's so-so"},
    //result = TextAnalytics.Sentiment(input)
    input = {"I don't know if you know this, but blue is my favourite colour, more than any other one", "do you know what time it is please?", "twinkle, twinkle little star, how I wonder what you are", "I had a wonderful experience! The rooms were wonderful and the staff was helpful."},
    result = TextAnalytics.KeyPhrases(input)
in
    result
    //input