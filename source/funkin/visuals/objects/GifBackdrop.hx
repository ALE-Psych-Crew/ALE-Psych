package funkin.visuals.objects;

import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;

import com.yagp.GifRenderer.GifMap;
import com.yagp.Gif as YapgGif;
import com.yagp.GifPlayer;

import core.visuals.GifUtil;
import core.interfaces.IGif;

class GifBackdrop extends FlxBackdrop implements IGif
{
    public var player:Null<GifPlayer>;

    public var map:Null<GifMap>;

    public function new(?gif:YapgGif, ?repeatAxes:FlxAxes, ?sX:Float, ?sY:Float)
    {
        super(repeatAxes, sX, sY);

        if (gif != null)
            loadPlayer(gif);
    }

    public function loadPlayer(gif:YapgGif):GifBackdrop
    {
        GifUtil.loadPlayer(this, gif);

        return this;
    }

    public function loadMap(gif:YapgGif):GifBackdrop
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