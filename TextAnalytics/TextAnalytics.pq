section TextAnalytics;

//Function to expose the Key Phrases web service
[DataSource.Kind="TextAnalytics"]
shared TextAnalytics.KeyPhrases = (optional inputtext as list, optional numberoflanguages as number) as table => 
        GetKeyPhrases(inputtext);


//Function to expose the Detect Language web service
[DataSource.Kind="TextAnalytics"]
shared TextAnalytics.DetectLanguage = (optional inputtext as list, optional numberoflanguages as number) as table =>
        if numberoflanguages = null 
        then
            GetLanguages(inputtext)
        else
            GetLanguages(inputtext, numberoflanguages);

//Function to expose the Sentiment web service
[DataSource.Kind="TextAnalytics"]
shared TextAnalytics.Sentiment = (optional inputtext as list, optional numberoflanguages as number) as table => 
        GetSentiment(inputtext);

//Helper functions

GetKeyPhrases = (inputtext as list) as table =>
let
    //If no data is supplied, create a list with one sample document
    inputtexttest = if inputtext=null then {"Hello World"} else inputtext,
    PrepareData = PrepareInputText(inputtexttest),
    //Call the web service once for each partition
    CallWebService = List.Transform(PrepareData, each CallTextAnalyticsWebService("keyPhrases", _)),
    //Combine list of tables into one table
    OneTable = Table.Combine(CallWebService),
    #"Expanded Column1" = Table.ExpandRecordColumn(OneTable, "Column1", {"id", "keyPhrases"}, {"id", "keyPhrases"}),
    #"Expanded Column2" = Table.ExpandListColumn(#"Expanded Column1", "keyPhrases"),
    JoinWithOriginalTable = Table.Join(Table.Combine(PrepareData), "id", #"Expanded Column2", "id")
in
     JoinWithOriginalTable;

GetLanguages = (inputtext as list, optional numberoflanguages as number) as table =>
let
    //If no data is supplied, create a list with one sample document
    inputtexttest = if inputtext=null then {"Hello World"} else inputtext,
    PrepareData = PrepareInputText(inputtexttest),
    //Call the web service once for each partition
    CallWebService = List.Transform(PrepareData, each if numberoflanguages=null then CallTextAnalyticsWebService("languages", _) else CallTextAnalyticsWebService("languages", _, numberoflanguages)),
    //Combine list of tables into one table
    OneTable = Table.Combine(CallWebService),
    #"Expanded Column1" = Table.ExpandRecordColumn(OneTable, "Column1", {"id", "detectedLanguages"}, {"id", "detectedLanguages"}),
    #"Expanded Column2" = Table.ExpandListColumn(#"Expanded Column1", "detectedLanguages"),
    #"Expanded Column3" = Table.ExpandRecordColumn(#"Expanded Column2", "detectedLanguages", {"name", "iso6391Name", "score"}, {"name", "iso6391Name", "score"}),
    JoinWithOriginalTable = Table.Join(Table.Combine(PrepareData), "id", #"Expanded Column3", "id")
in
     JoinWithOriginalTable;

GetSentiment = (inputtext as list) as table =>
let
    //If no data is supplied, create a list with one sample document
    inputtexttest = if inputtext=null then {"Hello World"} else inputtext,
    PrepareData = PrepareInputText(inputtexttest),
    //Call the web service once for each partition
    CallWebService = List.Transform(PrepareData, each CallTextAnalyticsWebService("sentiment", _)),
    //Combine list of tables into one table
    OneTable = Table.Combine(CallWebService),
    #"Expanded Column1" = Table.ExpandRecordColumn(OneTable, "Column1", {"id", "score"}, {"id", "score"}),
    JoinWithOriginalTable = Table.Join(Table.Combine(PrepareData), "id", #"Expanded Column1", "id")
in
     JoinWithOriginalTable;

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
 //                         Headers = [#"Ocp-Apim-Subscription-Key"="cfa8a47784754cb4a39cc645673d384a"]
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

PrepareInputText = (inputtext as list) =>
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
                    each {Text.From([rowcounter]), TruncateText{[rowcounter]}, Text.From([bucketid])}),
    //Turn the list returned by the FindBuckets step into a table
    CreateTable = #table({"id", "text", "call bucket"}, FindBuckets),
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

