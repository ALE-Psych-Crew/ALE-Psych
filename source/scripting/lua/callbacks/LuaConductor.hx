package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

class LuaConductor extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);
        
        /**
         * 
         */
        set('getSongPosition', function()
        {
            return Conductor.songPosition;
        });

        /**
         * 
         */
        set('getSongStep', function()
        {
            return Conductor.curStep;
        });

        /**
         * 
         */
        set('getSongBeat', function()
        {
            return Conductor.curBeat;
        });

        /**
         * 
         */
        set('getSongSection', function()
        {
            return Conductor.curSection;
        });
    }
}
