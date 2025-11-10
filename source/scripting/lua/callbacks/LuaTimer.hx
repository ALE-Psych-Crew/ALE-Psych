package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

class LuaTimer extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        /**
         * Starts and runs a `FlxTimer`
         * 
         * @param tag Timer ID
         * @param time Timer duration
         * @param loops Number of repetitions of the timer
         */
        set('runTimer', function(tag:String, ?time:Float, ?loops:Int)
        {
            var timer:FlxTimer = new FlxTimer().start(time ?? 1, function(tmr:FlxTimer)
            {
                lua.call('onTimerComplete', [tag, tmr.loops, tmr.loopsLeft]);

                removeTag(tag);
            }, loops ?? 1);

            setTag(tag, timer);
        });
        
        /**
         * Cancels a timer
         * 
         * @param tag Timer ID
         */
        set('cancelTimer', function(tag:String)
        {
            if (tagIs(tag, FlxTimer))
            {
                getTag(tag).cancel();

                removeTag(tag);
            }
        });
    }
}
