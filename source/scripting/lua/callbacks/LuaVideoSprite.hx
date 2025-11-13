package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;
import funkin.visuals.objects.VideoSprite;

class LuaVideoSprite extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        /**
         * Creates a `VideoSprite` and registers it for Lua access.
         *
         * This loads a video at the given position and optionally
         * starts playback immediately. When the video finishes loading or
         * reaches its end, Lua callbacks are triggered automatically:
         *   - `onVideoSpriteLoad(tag)`
         *   - `onVideoSpriteEndReached(tag)`
         *
         * @param tag Unique ID of the video sprite object.
         * @param x Position on the X axis.
         * @param y Position on the Y axis.
         * @param path Path of the video file (without extension).
         * @param playOnLoad Whether to start playback once loaded.
         * @param loop Whether the video should loop endlessly.
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
         * Begins or restarts playback of a `VideoSprite`.
         *
         * @param tag ID of the video sprite.
         */
        set('playVideoSprite', function(tag:String)
        {
            if (tagIs(tag, VideoSprite))
                getTag(tag).play();
        });

        /**
         * Stops playback of a `VideoSprite` immediately.
         *
         * @param tag ID of the video sprite.
         */
        set('stopVideoSprite', function(tag:String)
        {
            if (tagIs(tag, VideoSprite))
                getTag(tag).stop();
        });

        /**
         * Pauses playback of a `VideoSprite`.
         *
         * @param tag ID of the video sprite.
         */
        set('pauseVideoSprite', function(tag:String)
        {
            if (tagIs(tag, VideoSprite))
                getTag(tag).pause();
        });

        /**
         * Resumes playback of a paused `VideoSprite`.
         *
         * @param tag ID of the video sprite.
         */
        set('resumeVideoSprite', function(tag:String)
        {
            if (tagIs(tag, VideoSprite))
                getTag(tag).resume();
        });

        /**
         * Toggles the paused state of a `VideoSprite`.
         *
         * Useful if you want a single function to switch between pause and
         * resume behavior.
         *
         * @param tag ID of the video sprite.
         */
        set('toggleVideoSpritePaused', function(tag:String)
        {
            if (tagIs(tag, VideoSprite))
                getTag(tag).togglePaused();
        });
    }
}
