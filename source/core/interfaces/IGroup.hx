package core.interfaces;

import flixel.FlxBasic;

interface IGroup extends IFlxDestroyable
{
    public var members(default, null):Array<FlxBasic>;

    public function add(obj:FlxBasic):FlxBasic;
    public function insert(index:Int, obj:FlxBasic):FlxBasic;
    public function remove(obj:FlxBasic, destroy:Bool = false):FlxBasic;

    public function forEachAlive(func:FlxBasic -> Void, recurse:Bool = false):Void;
}