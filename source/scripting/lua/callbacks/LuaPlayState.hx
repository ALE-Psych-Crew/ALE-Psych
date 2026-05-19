package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

class LuaPlayState extends LuaPresetBase
{
    final playState:PlayState = PlayState.instance;

    public function new(lua:LuaScript)
    {
        super(lua);

        set('addBehindOpponents', function (tag:String)
        {
            if (tagIs(tag, flixel.FlxBasic))
                playState.addBehindOpponents(getTag(tag));
        });

        set('addBehindPlayers', function (tag:String)
        {
            if (tagIs(tag, flixel.FlxBasic))
                playState.addBehindPlayers(getTag(tag));
        });

        set('addBehindExtras', function (tag:String)
        {
            if (tagIs(tag, flixel.FlxBasic))
                playState.addBehindExtras(getTag(tag));
        });

        set('addBehindDad', function (tag:String)
        {
            if (tagIs(tag, flixel.FlxBasic))
                playState.addBehindDad(getTag(tag));
        });

        set('addBehindBF', function (tag:String)
        {
            if (tagIs(tag, flixel.FlxBasic))
                playState.addBehindBF(getTag(tag));
        });

        set('addBehindGF', function (tag:String)
        {
            if (tagIs(tag, flixel.FlxBasic))
                playState.addBehindGF(getTag(tag));
        });

        set('addBehindGroup', function (tag:String, group:String)
        {
            if (tagIs(group, flixel.group.FlxTypedGroup) && tagIs(tag, flixel.FlxBasic))
                playState.addBehindGroup(getTag(group), getTag(tag));
        });

        set('importStageObject', function (tag:String, key:String)
        {
            setTag(tag, playState.stage.get(key));
        });

        set('createMobileHitboxes', function(strl:Int)
        {
            playState.createMobileHitboxes(playState.strumLines.members[strl]);
        });
    }
}