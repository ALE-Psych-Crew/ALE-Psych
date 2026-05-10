package utils.cool;

import flixel.FlxSubState;
import flixel.FlxState;

#if ALLOW_HSCRIPT
import ale.rulescript.RuleScriptGlobal;
#end

class StateUtil
{
	public static function switchState(state:FlxState, ?skipTransIn:Bool, ?skipTransOut:Bool)
	{
		if (state == null)
			return;

		if (state is CustomState)
		{
            final custom:String = Std.downcast(state, CustomState).scriptName;
			
            if (Paths.exists('scripts/states/' + custom + RuleScriptGlobal.SCRIPT_EXTENSION) || Paths.exists('scripts/states/' + custom + '.lua'))
                transitionSwitch(state, skipTransIn, skipTransOut);
            else
                debugTrace('Custom State called "' + custom + '" doesn\'t Exist', MISSING_FILE);
		} else {
			transitionSwitch(state, skipTransIn, skipTransOut);
		}
	}

	public static function transitionSwitch(state:FlxState, skipTransIn:Bool = false, skipTransOut:Bool = false)
	{
		FlxG.switchState(state);
	}

	public static function openSubState(subState:FlxSubState = null)
	{
		if (subState == null)
			return;

        if (subState is CustomSubState)
        {
            final custom:String = Std.downcast(subState, CustomSubState).scriptName;
            
            if (Paths.exists('scripts/substates/' + custom + RuleScriptGlobal.SCRIPT_EXTENSION) || Paths.exists('scripts/substates/' + custom + '.lua'))
                FlxG.state.openSubState(subState);
            else
                debugTrace('Custom SubState called "' + custom + '" doesn\'t Exist', MISSING_FILE);
        } else {
			FlxG.state.openSubState(subState);
		}
	}
}