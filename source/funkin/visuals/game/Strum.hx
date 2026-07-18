package funkin.visuals.game;

import core.structures.JsonStrumLineConfig;

class Strum extends StrumLineObject
{
    public var children:Array<Note> = [];

    public var idleTime:Float = 0.15;

    public var direction:Float = 0;

    public function new(id:String, strlData:JsonStrumLineConfig, allowShader:Bool, data:Int)
    {
        allowOffset = false;

        pathPrefix = 'notes/';

        super(id, strlData, allowShader, data);

        playAnim(strumLineConfig.idle);
    }

    var idleTimer:Float = 0;

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

    public var allowShaderDuringIdle:Bool = false;

    override function playAnim(name:String, ?force:Bool = true)
    {
        super.playAnim(name, force);

        if (shader != null)
            _castShader.multiplier = animation.name != strumLineConfig.idle || allowShaderDuringIdle ? 1 : 0;

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