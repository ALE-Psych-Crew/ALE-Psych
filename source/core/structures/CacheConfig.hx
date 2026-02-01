package core.structures;

import haxe.Constraints.Function;

import haxe.ds.StringMap;

@:structInit class CacheConfig
{
    public var prefix:String = '';
    public var postfix:String = '';
    public var method:Function = () -> {};
    public var verifyExistence:Bool = true;
    public var cache:StringMap<{permanent:Bool, content:Dynamic}> = new StringMap();
}