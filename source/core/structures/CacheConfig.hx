package core.structures;

import haxe.Constraints.Function;

import haxe.ds.StringMap;

@:structInit class CacheConfig
{
    public var prefix:String = '';
    public var postfix:String = '';
    public var method:Function = () -> {};
    public var checkExistence:Bool = true;
    public var cache:Map<String, {permanent:Bool, content:Dynamic}> = new StringMap();
    public var forceCleaning:Bool = false;
}