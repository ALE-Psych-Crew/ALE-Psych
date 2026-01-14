package core.structures;

import haxe.ds.StringMap;

typedef CacheArray = {
    cache:StringMap<Dynamic>,
    permanent:Array<String>
}