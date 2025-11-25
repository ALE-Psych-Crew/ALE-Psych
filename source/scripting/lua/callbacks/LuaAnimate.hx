package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import funkin.visuals.objects.PsychFlxAnimate;

class LuaAnimate extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('makeFlxAnimateSprite', function(tag:String, ?x:Float, ?y:Float, ?loadFolder:String)
        {
            var sprite:PsychFlxAnimate = new PsychFlxAnimate(x, y);

            if (loadFolder != null)
                Paths.loadAnimateAtlas(sprite, loadFolder);

            setTag(tag, sprite);
        });
        
        set('loadAnimateAtlas', function(tag:String, folderOrImg:Dynamic, ?spriteJson:Dynamic, ?animationJson:Dynamic)
        {
            if (tagIs(tag, PsychFlxAnimate))
                Paths.loadAnimateAtlas(getTag(tag), folderOrImg, spriteJson, animationJson);
        });

        set('addAnimationBySymbolIndices', function(tag:String, name:String, symbol:String, indices:Any, ?framerate:Float, ?loop:Bool, ?matX:Float, ?matY:Float)
        {
            if (!tagIs(tag, PsychFlxAnimate))
                return;

            var obj:PsychFlxAnimate = getTag(tag);

			if(indices == null)
				indices = [0];

			else if(Std.isOfType(indices, String))
			{
				var strIndices:Array<String> = cast (indices, String).trim().split(',');

				var myIndices:Array<Int> = [];

				for (i in 0...strIndices.length)
					myIndices.push(Std.parseInt(strIndices[i]));
				
				indices = myIndices;
			}

			obj.anim.addBySymbolIndices(name, symbol, indices, framerate, loop, matX, matY);

			if (obj.anim.curSymbol == null)
			{
				var obj2:PsychFlxAnimate = cast (obj, PsychFlxAnimate);

                obj2.anim.play(name, true);
			}
        });
    }
}
