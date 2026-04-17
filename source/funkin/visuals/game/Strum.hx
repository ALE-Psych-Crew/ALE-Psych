package funkin.visuals.game;

import core.structures.JsonStrumLineConfig;

class Strum extends StrumLineObject
{
    public var modifier:Dynamic;

    public var children:Array<Note> = [];

    public var idleTime:Float = 0.15;

    public var direction:Float = 0;

    public function new(id:String, strlData:JsonStrumLineConfig)
    {
        allowOffset = false;

        pathPrefix = 'strums/';

        super(id, strlData);

        playAnim(strumLineConfig.idle);
    }

    public var idleTimer:Float = 0;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (idleTimer > 0 && strumLine.botplay)
        {
            idleTimer -= elapsed;

            if (idleTimer <= 0)
                playAnim(strumLineConfig.idle);
        }
    }

    override function playAnim(name:String, ?force:Bool = true)
    {
        super.playAnim(name, force);
        
        textureShader.enabled = animation.name != strumLineConfig.idle && strumLineConfig.shader != null;

        idleTimer = animation.name == strumLineConfig.idle ? -1 : idleTime;
        
        centerOffsets();
        centerOrigin();
    }

    override function destroy()
    {
        super.destroy();

        children = null;
    }
}