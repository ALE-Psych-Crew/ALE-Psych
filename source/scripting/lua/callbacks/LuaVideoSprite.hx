package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import funkin.visuals.objects.VideoSprite;

class LuaVideoSprite extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        /**
         * 
         */
        set('makeLuaVideoSprite', function(tag:String, ?x:Float, ?y:Float, ?path:String, ?playOnLoad:Bool, ?loop:Bool)
        {
            var obj:VideoSprite = new VideoSprite(x, y, Paths.video(path), playOnLoad, loop);

            obj.loadCallback = () -> {
                lua.call('onVideoSpriteLoad', [tag]);
            };

            obj.finishCallback = () -> {
                lua.call('onVideoSpriteEndReached', [tag]);
            };

            setTag(tag, obj);
        });

        /**
         * 
         */
        set('playVideoSprite', function(tag:String)
            {
                if (tagIs(tag, VideoSprite))
                    getTag(tag).play();
            }
        );

        /**
         * 
         */
        set('stopVideoSprite', function(tag:String)
            {
                if (tagIs(tag, VideoSprite))
                    getTag(tag).stop();
            }
        );

        /**
         * 
         */
        set('pauseVideoSprite', function(tag:String)
            {
                if (tagIs(tag, VideoSprite))
                    getTag(tag).pause();
            }
        );

        /**
         * 
         */
        set('resumeVideoSprite', function(tag:String)
            {
                if (tagIs(tag, VideoSprite))
                    getTag(tag).resume();
            }
        );

        /**
         * 
         */
        set('toggleVideoSpritePaused', function(tag:String)
            {
                if (tagIs(tag, VideoSprite))
                    getTag(tag).togglePaused();
            }
        );
    }
}
