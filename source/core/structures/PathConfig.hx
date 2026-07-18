package core.structures;

@:structInit
class PathConfig
{
    public var prefix:String = '';
    public var postfix:String = '';
    public var checkExistence:Bool = true;
    public var cache:Map<String, PathConfigCache> = new Map<String, PathConfigCache>();
    public var get:String -> Dynamic -> Bool -> Bool -> Dynamic = (_, _, _, _) -> null;
    public var forceCleaning:Bool = false;
    public var clearMethod:String -> Dynamic -> Void = (_, _) -> {};
}