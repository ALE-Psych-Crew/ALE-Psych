package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import scripting.lua.LuaPresetUtils;

using StringTools;

class LuaRemoved extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);
		
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
			'getColorFromHex',
			'addOffset',
			'makeAnimatedLuaSprite',
			'setScrollFactor'
        ])
            set(name, () -> { errorPrint('"' + name + '" function was removed'); });
    }
}