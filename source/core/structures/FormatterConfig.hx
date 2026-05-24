package core.structures;

@:structInit class FormatterConfig
{
    public var path:String = '';
    public var format:String = '';
    public var example:Dynamic = {};
    public var resolvers:Array<Dynamic -> String -> Null<Array<Dynamic>> -> Dynamic> = [];
    public var fileCheck:Dynamic -> Bool = (_) -> true;
    public var exampleModifier:Dynamic -> String -> Array<Dynamic> -> Dynamic = (_:Dynamic, __:String, ___:Array<Dynamic>) -> null;
    public var cache:Map<String, Dynamic> = [];
}