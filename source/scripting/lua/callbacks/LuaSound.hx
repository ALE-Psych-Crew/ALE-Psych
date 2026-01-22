package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

class LuaSound extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);
        
        set('playMusic', function(sound:String, ?volume:Float, ?loop:Bool)
        {
            FlxG.sound.playMusic(Paths.music(sound), volume, loop);
        });

        set('playSound', function(sound:String, ?volume:Float, ?tag:String, ?loop:Bool)
        {
            setTag(tag, FlxG.sound.play(Paths.sound(sound), volume, loop, null, true, function()
            {
                lua.call('onSoundFinished', [tag]);
            }));
        });

        set('stopSound', function(tag:String)
        {
            if (tagIs(tag, FlxSound))
                getTag(tag).stop();
        });

        set('pauseSound', function(tag:String)
        {
            if (tagIs(tag, FlxSound))
                getTag(tag).pause();
        });

        set('resumeSound', function(tag:String)
        {
            if (tagIs(tag, FlxSound))
                getTag(tag).resume();
        });

        set('soundFadeIn', function(tag:String, ?duration:Float, ?fromValue:Float, ?toValue:Float)
        {
            if (tagIs(tag, FlxSound))
                getTag(tag).fadeIn(duration, fromValue, toValue, (_) -> {
                    lua.call('onSoundFadeInFinished', [tag]);
                });
        });

        set('soundFadeOut', function(tag:String, ?duration:Float, ?toValue:Float)
        {
            if (tagIs(tag, FlxSound))
                getTag(tag).fadeOut(duration, toValue, (_) -> {
                    lua.call('onSoundFadeOutFinished', [tag]);
                });
        });

        set('soundFadeCancel', function(tag:String)
        {
            if (tagIs(tag, FlxSound))
                getTag(tag).fadeTween?.cancel();
        });
    }
}
