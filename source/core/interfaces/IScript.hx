package core.interfaces;

import core.enums.ScriptType;

interface IScript
{
    public final type:ScriptType;

    public function set(name:String, value:Dynamic);

    public function call(name:String, args:Array<Dynamic>);
}