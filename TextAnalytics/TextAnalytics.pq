section TextAnalytics;

//Function parameters with documentation

//Function to expose the Key Phrases web service
[DataSource.Kind="TextAnalytics"]
shared TextAnalytics.KeyPhrases = Value.ReplaceType(KeyPhrasesImpl, KeyPhrasesParameters);

KeyPhrasesParameters =
   type function (
        optional inputtext as ( type list meta[
        Documentation.FieldCaption = "Input Text"
        ]),
        optional languages as ( type list meta[
        Documentation.FieldCaption = "Languages"
        ])
        )
        as table meta[
        Documentation.Name = "KeyPhrases",
        Documentation.LongDescription = "Calls the Microsoft Cognitive Services Text Analytics Key Phrases API",
        Documentation.Examples = {[
            Description = "Returns a table with the key phrases identified from each piece of text",
            Code = "TextAnalytics.KeyPhrases({""blue is my favourite colour"", ""what time it is please?"", ""twinkle, twinkle little star, how I wonder what you are""})",
            Result = "#table({""id"", ""text"", ""call bucket"", ""keyPhrases""}, {{0, ""blue is my favourite colour"", 1, ""blue""}, {1, ""Hello world"", 1, ""time""}, {2, ""twinkle, twinkle little star, how I wonder what you are"", 1, ""twinkle""}, {2, ""twinkle, twinkle little star, how I wonder what you are"", 1, ""little star""}})"
        ]}
        ];

KeyPhrasesImpl = (optional inputtext as list, optional languages as list) as table => 
let
    //if inputtext parameter is null, use an empty list
    CheckForInputText = if inputtext = null then {} else List.Buffer(inputtext),
    BufferLanguages = if languages = null then null else List.Buffer(languages),
    PrepareData = if languages = null then PrepareInputText(CheckForInputText) else PrepareInputText(CheckForInputText, BufferLanguages),
    //Call the web service once for each partition
    CallWebService = List.Transform(PrepareData, each CallTextAnalyticsWebService("keyPhrases", _)),
    //Combine list of tables into one table
    OneTable = Table.Combine(CallWebService),
    #"Expanded Column1" = Table.ExpandRecordColumn(OneTable, "Column1", {"id", "keyPhrases"}, {"id", "keyPhrases"}),
    #"Expanded Column2" = Table.ExpandListColumn(#"Expanded Column1", "keyPhrases"),
    JoinWithOriginalTable = Table.Join(Table.Combine(PrepareData), "id", #"Expanded Column2", "id"),
    SetDataTypes = Table.TransformColumnTypes(JoinWithOriginalTable,{{"id", Int64.Type}, {"text", type text}, {"call bucket", Int64.Type}, {"keyPhrases", type text}}),
    SetLanguageDataType = if languages = null then SetDataTypes else Table.TransformColumnTypes(SetDataTypes,{{"language", type text}})
in
     SetLanguageDataType;


//Function to expose the Detect Language web service
[DataSource.Kind="TextAnalytics"]
shared TextAnalytics.DetectLanguage = Value.ReplaceType(DetectLanguageImpl, DetectLanguageParameters);

DetectLanguageParameters =
   type function (
        optional inputtext as ( type list meta[
        Documentation.FieldCaption = "Input Text"
        ]),
        optional numberoflanguages as ( type number meta[
        Documentation.FieldCaption = "Number Of Languages"
        ])
        )
        as table meta[
        Documentation.Name = "DetectLanguages",
        Documentation.LongDescription = "Calls the Microsoft Cognitive Services Text Analytics Detect Language API",
        Documentation.Examples = {[
            Description = "Returns a table with the languages identified from each piece of text",
            Code = "TextAnalytics.DetectLanguage({""Ich spreche nicht viel Deutsch"", ""Bonjour"", ""¿Dónde hay un restaurante?""})",
            Result = "#table({""id"", ""text"", ""call bucket"", ""name"", ""iso6391Name"", ""score""}, {{0, ""Ich spreche nicht viel Deutsch"", 1, ""German"", ""de"", 1}, {1, ""Bonjour"", 1, ""French"", ""fr"", 1}, {2, ""¿Dónde hay un restaurante?"", 1, ""Spanish"", ""es"", 1}})"
        ]}
        ];

DetectLanguageImpl = (optional inputtext as list, optional numberoflanguages as number) as table =>
let
    //if inputtext parameter is null, use an empty list
    CheckForInputText = if inputtext = null then {} else List.Buffer(inputtext),
    PrepareData = PrepareInputText(CheckForInputText),
    //Call the web service once for each partition
    CallWebService = List.Transform(PrepareData, each if numberoflanguages=null then CallTextAnalyticsWebService("languages", _) else CallTextAnalyticsWebService("languages", _, numberoflanguages)),
    //Combine list of tables into one table
    OneTable = Table.Combine(CallWebService),
    #"Expanded Column1" = Table.ExpandRecordColumn(OneTable, "Column1", {"id", "detectedLanguages"}, {"id", "detectedLanguages"}),
    #"Expanded Column2" = Table.ExpandListColumn(#"Expanded Column1", "detectedLanguages"),
    #"Expanded Column3" = Table.ExpandRecordColumn(#"Expanded Column2", "detectedLanguages", {"name", "iso6391Name", "score"}, {"name", "iso6391Name", "score"}),
    JoinWithOriginalTable = Table.Join(Table.Combine(PrepareData), "id", #"Expanded Column3", "id"),
    SetDataTypes = Table.TransformColumnTypes(JoinWithOriginalTable,{{"id", Int64.Type}, {"text", type text}, {"call bucket", Int64.Type}, {"name", type text}, {"iso6391Name", type text}, {"score", type number}})
in
     SetDataTypes;

//Function to expose the Sentiment web service
[DataSource.Kind="TextAnalytics"]
shared TextAnalytics.Sentiment = Value.ReplaceType(SentimentImpl, SentimentParameters);

SentimentParameters =
   type function (
        optional inputtext as ( type list meta[
        Documentation.FieldCaption = "Input Text"
        ]),
        optional languages as ( type list meta[
        Documentation.FieldCaption = "Languages"
        ])
        )
        as table meta[
        Documentation.Name = "Sentiment",
        Documentation.LongDescription = "Calls the Microsoft Cognitive Services Text Analytics Sentiment API",
        Documentation.Examples = {[
            Description = "Returns a table with the sentiment identified from each piece of text",
            Code = "TextAnalytics.Sentiment({""this is great"", ""this is terrible""})",
            Result = "#table({""id"", ""text"", ""call bucket"", ""score""}, {{0, ""this is great"", 0.99797004461288452}, {1, ""this is terrible"", 1, 0.00062239170074462891})"
        ]}
        ];

SentimentImpl = (optional inputtext as list, optional languages as list) as table => 
let
    //if inputtext parameter is null, use an empty list
    CheckForInputText = if inputtext = null then {} else List.Buffer(inputtext),
    BufferLanguages = if languages = null then null else List.Buffer(languages),
    PrepareData = if languages = null then PrepareInputText(CheckForInputText) else PrepareInputText(CheckForInputText, BufferLanguages),
    //Call the web service once for each partition
    CallWebService = List.Transform(PrepareData, each CallTextAnalyticsWebService("sentiment", _)),
    //Combine list of tables into one table
    OneTable = Table.Combine(CallWebService),
    #"Expanded Column1" = Table.ExpandRecordColumn(OneTable, "Column1", {"id", "score"}, {"id", "score"}),
    JoinWithOriginalTable = Table.Join(Table.Combine(PrepareData), "id", #"Expanded Column1", "id"),
    SetDataTypes = Table.TransformColumnTypes(JoinWithOriginalTable,{{"id", Int64.Type}, {"text", type text}, {"call bucket", Int64.Type}, {"score", type number}}),
    SetLanguageDataType = if languages = null then SetDataTypes else Table.TransformColumnTypes(SetDataTypes,{{"language", type text}})
in
     SetLanguageDataType;


//Helper functions

//Make a single call to one of the Text Analytics web services
CallTextAnalyticsWebService = (webservicename as text, inputtable as table, optional numberoflanguages as number) as table =>
    let
        //Get API key
        apiKey = Extension.CurrentCredential()[Key],
        //Prepare call
        TableForJSON = [documents=inputtable],
        OptionsRecord = [
                        Content=Json.FromValue(TableForJSON),
                        Headers = [#"Ocp-Apim-Subscription-Key"=apiKey],
                        ManualCredentials = true
                        ],
        AddNumberOfLanguagesToDetect = if numberoflanguages=null then OptionsRecord else Record.AddField(OptionsRecord, "Query", [numberOfLanguagesToDetect=Text.From(numberoflanguages)]),
        CallService = ()=>
                    Web.Contents(
                        "https://westus.api.cognitive.microsoft.com/text/analytics/v2.0/" & webservicename,
                        AddNumberOfLanguagesToDetect),
        //Call the service with a delay of 1 second between each call, to avoid hitting the rate limit
        CallServiceWithDelay = Function.InvokeAfter(CallService, #duration(0,0,0,1)),
        ResultsList = Json.Document(CallServiceWithDelay)[documents],
        #"Converted to Table" = Table.FromList(ResultsList, Splitter.SplitByNothing(), null, null, ExtraValues.Error)
in
    #"Converted to Table";

PrepareInputText = (inputtext as list, optional languages as list) =>
//Prepare input data for all web services
let
    //Truncate each document to 5120 characters, the maximum the web services will accept for a single document (ie 10KB)
    TruncateText = List.Transform(inputtext, each Text.Start(_, 5120)),
    //The web services only allow requests of 1MB at a time, and no more than 1000 documents at a time
    //so we need to create a list of tables with 1000 or less rows and where the size of the combined text is less than 1MB
    DocumentCount = List.Count(TruncateText),
    FindBuckets = List.Generate(
                    ()=>[rowcounter=0, bucketrowcounter=0, runningsum= Text.Length(TruncateText{0}), bucketid=1],
                    each [rowcounter]<DocumentCount,
                    each
                            if 
                                [bucketrowcounter]<999 and 
                                [runningsum] + (if [rowcounter]<DocumentCount-1 then Text.Length(TruncateText{[rowcounter]+1}) else 0)<=524288
                            then
                                [rowcounter=[rowcounter]+1, bucketrowcounter=[bucketrowcounter]+1,runningsum=[runningsum]+Text.Length(TruncateText{[rowcounter]+1}), bucketid=[bucketid]] 
                            else
                                [rowcounter=[rowcounter]+1, bucketrowcounter=0, runningsum=Text.Length(TruncateText{[rowcounter]+1}), bucketid=[bucketid]+1],
                    each
                        if languages=null then 
                        {Text.From([rowcounter]), TruncateText{[rowcounter]}, Text.From([bucketid])}
                        else
                        {Text.From([rowcounter]), TruncateText{[rowcounter]}, Text.From([bucketid]), languages{[rowcounter]}}),
    //Turn the list returned by the FindBuckets step into a table
    CreateTable = if languages = null then #table({"id", "text", "call bucket"}, FindBuckets) else #table({"id", "text", "call bucket", "language"}, FindBuckets),
    //Find total number of buckets
    BucketCount = List.Count(List.Distinct(List.Transform(FindBuckets, each _{2}))),
    //Split table into a list of tables
    SplitTable = Table.Partition(CreateTable, "call bucket", BucketCount, each Number.From(_))
in
    SplitTable;


// Data Source Kind description

TextAnalytics = [
    Authentication = [
        Key = []
    ],
    Label = Extension.LoadString("DataSourceLabel")
];


