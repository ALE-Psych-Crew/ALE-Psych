package core.structures;

import haxe.Constraints.Function;

import haxe.ds.StringMap;

typedef CacheConfig = {
    var prefix:String;
    var postfix:String;
    var method:Function;
    var cache:StringMap<{permanent:Bool, content:Dynamic}>;
}