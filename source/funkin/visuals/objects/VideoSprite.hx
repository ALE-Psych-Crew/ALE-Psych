package funkin.visuals.objects;

#if VIDEOS_ALLOWED
import hxvlc.flixel.FlxVideoSprite;
import hxvlc.util.Handle;

class VideoSprite extends FlxVideoSprite
{
    public var finishCallback:Void -> Void;
    public var errorCallback:String -> Void;
    public var loadCallback:Void -> Void;

    override public function new(?x:Float = 0, ?y:Float = 0, path:String, playOnLoad:Bool = true, loop:Bool = false, ?loadCallback:Void -> Void, ?finishCallback:Void -> Void, ?errorCallback:String -> Void)
    {
        super(x, y);

        this.finishCallback = finishCallback ?? () -> {};
        this.errorCallback = errorCallback ?? (message:String) -> {};
        this.loadCallback = loadCallback ?? () -> {};

        setupVideo(path, loop, playOnLoad);
    }
    
    private function setupVideo(path:String, loop:Bool, playOnLoad)
    {
        Handle.initAsync(
            function(success:Bool):Void
            {
                if (!success)
                    return;

                active = false;

                antialiasing = ClientPrefs.data.antialiasing;

                bitmap.onEncounteredError.add(
                    function (message:String)
                    {
                        debugTrace('VLC Error: ' + message, ERROR);

                        if (errorCallback != null)
                            errorCallback(message);
                    }
                );

                bitmap.onEndReached.add(
                    function ()
                    {
                        if (finishCallback != null)
                            finishCallback();
                    }
                );

                bitmap.onFormatSetup.add(
                    function ():Void
                    {
                        if (bitmap != null && bitmap.bitmapData != null)
                        {
                            final scale:Float = Math.min(FlxG.width / bitmap.bitmapData.width, FlxG.height / bitmap.bitmapData.height);
        
                            setGraphicSize(bitmap.bitmapData.width * scale, bitmap.bitmapData.height * scale);
                            
                            updateHitbox();

                            loadCallback();
                        }
                    }
                );

                try
                {
                    load(path, loop ? ['input-repeat=65545'] : null);
                } catch(e:Dynamic) {
                    debugTrace('VLC Error: ' + e, ERROR);
                }

                if (playOnLoad)
                    play();
            }
        );
    }
}
#end