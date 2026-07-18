package funkin.visuals.game;

import core.structures.JsonStrumLineConfig;

class Splash extends StrumLineObject
{
    public var strum:Strum;

    public function new(id:String, strlData:JsonStrumLineConfig, allowShader:Bool, data:Int)
    {
        pathPrefix = 'splashes/';

        super(id, strlData, allowShader, data);

        exists = false;

        animation.onFinish.add(_ -> exists = false);
    }
    
    public function splash()
    {
        exists = true;

        playAnim(strumLineConfig.splash[FlxG.random.int(0, strumLineConfig.splash.length - 1)]);

        if (strum != null)
        {
            x = strum.x + strum.width / 2 - width / 2;
            y = strum.y + strum.height / 2 - height / 2;
        }
    }
}