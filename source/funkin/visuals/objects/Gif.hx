package funkin.visuals.objects;

import com.yagp.GifRenderer.GifMap;
import com.yagp.Gif as YapgGif;
import com.yagp.GifPlayer;

import core.visuals.GifUtil;
import core.interfaces.IGif;

class Gif extends FlxSprite implements IGif
{
    public var player:Null<GifPlayer>;

    public var map:Null<GifMap>;

    public function new(?x:Float, ?y:Float, ?gif:YapgGif)
    {
        super(x, y);

        if (gif != null)
            loadPlayer(gif);
    }

    public function loadPlayer(gif:YapgGif):Gif
    {
        GifUtil.loadPlayer(this, gif);

        return this;
    }

    public function loadMap(gif:YapgGif):Gif
    {
        GifUtil.loadMap(this, gif);

        return this;
    }

    override function update(elapsed:Float)
    {
        GifUtil.update(this, elapsed);

        super.update(elapsed);
    }

    override function destroy()
    {
        super.destroy();

        GifUtil.destroy(this);
    }
}