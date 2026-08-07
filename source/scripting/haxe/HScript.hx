package scripting.haxe;

import core.interfaces.IScript;
import core.enums.StateType;

#if ALE_HSCRIPT
import ale.hscript.Script;
#else
import ale.rulescript.RuleScript;
import rulescript.Context;
#end

class HScript extends #if ALE_HSCRIPT Script #else RuleScript #end implements IScript
{
    public final type:StateType;

	override public function new(scriptName:String, context:#if ALE_HSCRIPT Dynamic #else Context #end, ?args:Array<Dynamic>, type:StateType, ?presets:Array<Class<HScriptPresetBase>>)
	{
		this.type = type;

		super(scriptName, #if ALE_HSCRIPT null #end , type == STATE ? FlxG.state : FlxG.state.subState, context);

        for (pre in presets ?? [])
            Type.createInstance(pre, [this]);

		set('game', #if ALE_HSCRIPT interp.variables.superInstance #else superInstance #end);

		#if ALE_HSCRIPT
		safeExecute();
		#else
		run();
		#end
		
		call('new', args);
	}
}