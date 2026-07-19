package core.interfaces;

import core.enums.StateType;

interface IScript
{
    public final type:StateType;

    public function set(name:String, value:Dynamic):Void;

    public function call(name:String, ?args:Array<Dynamic>):Dynamic;
}