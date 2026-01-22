package scripting.haxe.callbacks;

import scripting.haxe.HScriptPresetBase;

import flixel.FlxBasic;

class HScriptPlayState extends HScriptPresetBase
{
    public var playState:PlayState = PlayState.instance;

    public function new(hs:HScript)
    {
        super(hs);

        hs.set('addBehindGF', function(obj:FlxBasic)
        {
            playState.insert(playState.members.indexOf(playState.gfGroup), obj);
        });
        
        hs.set('addBehindBF', function(obj:FlxBasic)
        {
            playState.insert(playState.members.indexOf(playState.boyfriendGroup), obj);
        });
        
        hs.set('addBehindDad', function(obj:FlxBasic)
        {
            playState.insert(playState.members.indexOf(playState.dadGroup), obj);
        });
    }
}