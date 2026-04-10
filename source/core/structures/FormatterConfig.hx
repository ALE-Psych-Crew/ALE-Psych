package core.structures;

typedef FormatterConfig = {
    path:String,
    format:String,
    example:Dynamic,
    ?resolvers:Array<Dynamic -> String -> Null<Array<Dynamic>> -> Dynamic>,
    ?fileCheck:Dynamic -> Bool
}