package core.visuals;

import flixel.util.FlxDestroyUtil;
import flixel.graphics.FlxGraphic;

import com.yagp.GifRenderer;
import com.yagp.GifPlayer;
import com.yagp.Gif;

import core.interfaces.IGif;

@:publicFields
class GifUtil
{
    static function loadPlayer(spr:IGif, gif:Gif)
    {
        destroy(spr);

        spr.player = new GifPlayer(gif);

        if (spr is FlxSprite)
            cast(spr, FlxSprite).loadGraphic(FlxGraphic.fromBitmapData(spr.player.data, false, null, false));
    }

    static function loadMap(spr:IGif, gif:Gif)
    {
        destroy(spr);

        spr.map = GifRenderer.createMap(gif);

        if (spr is FlxSprite)
            cast(spr, FlxSprite).loadGraphic(FlxGraphic.fromBitmapData(spr.map.data, false, null, false), true, spr.map.width, spr.map.height);
    }

    static function update(spr:IGif, elapsed:Float)
        if (spr.player != null)
            spr.player.update(elapsed);

    static function destroy(spr:IGif)
    {
        if (spr.player != null)
        {
            spr.player.dispose();
            spr.player = null;
        }

        if (spr.map != null)
        {
            spr.map.data = FlxDestroyUtil.dispose(spr.map.data);
            spr.map = null;
        }
    }
}