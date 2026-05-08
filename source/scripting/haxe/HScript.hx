package scripting.haxe;

import core.interfaces.IScript;
import core.enums.ScriptType;

import ale.rulescript.RuleScript;

import rulescript.Context;

class HScript extends RuleScript implements IScript
{
    public final type:ScriptType;

	override public function new(scriptName:String, context:Context, ?args:Array<Dynamic>, type:ScriptType)
	{
		this.type = type;

		super(scriptName, type == STATE ? FlxG.state : FlxG.state.subState, context);

		set('game', superInstance);

		run();
		
		call('new', args);
	}
}