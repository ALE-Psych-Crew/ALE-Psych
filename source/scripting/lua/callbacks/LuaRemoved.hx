package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import scripting.lua.LuaPresetUtils;

using StringTools;

class LuaRemoved extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);
		
        /**
         * Emits an error for callbacks that were removed from the engine
         */
        for (name in [
			'getRunningScripts',
			'callScript',
			'getGlobalFromScript',
			'setGlobalFromScript',
			'getGlobals',
			'isRunning',
			'addLuaScript',
			'addHScript',
			'removeLuaScript',
			'removeHScript',
			'addScore',
			'addMisses',
			'addHits',
			'setScore',
			'setMisses',
			'setHits',
			'getScore',
			'getMisses',
			'getHits',
			'setHealth',
			'addHealth',
			'getHealth',
			'addCharacterToList',
			'getSongPosition',
			'getCharacterX',
			'setCharacterX',
			'getCharacterY',
			'setCharacterY',
			'setRatingPercent',
			'setRatingName',
			'setRatingFC',
			'luaSpriteExists',
			'luaTextExists',
			'luaSoundExists',
			'setHealthBarColors',
			'setTimeBarColors',
			'startVideo',
			'close',
			'getColorFromHex',
			'addOffset',
			'makeAnimatedLuaSprite',
			'setScrollFactor'
        ])
            set(name, () -> { errorPrint('"' + name + '" function was removed'); });
    }
}