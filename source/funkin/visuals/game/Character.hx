package funkin.visuals.game;

import utils.ALEFormatter;

import core.structures.ALECharacter;

import core.enums.CharacterType;

class Character extends Bopper
{
    public var type:CharacterType;

    public function new(initial:String, type:CharacterType)
    {
        super();

        this.type = type;

        change(initial);

        anim.onFinish.add((name) -> {
            if (offsets.exists(name + '-loop'))
                playAnim(name + '-loop');
        });
    }

    public var data:ALECharacter;

    public var id:String;

    public var vocals:Array<FlxSound> = [];

    public function change(id:String, ?type:CharacterType)
    {
        if (type != null)
            this.type = type;

        final jsonData:ALECharacter = ALEFormatter.getCharacter(id, this.type);

        if (jsonData == null)
            return;

        this.id = id;

        data = jsonData;
        
        scale.x = scale.y = data.scale;

        flipX = data.flipX != (this.type == 'player');

        flipY = data.flipY;

        antialiasing = data.antialiasing && ClientPrefs.data.antialiasing;

        offsets.clear();

        loadFrames(cast data.type, data.textures, data.frames);

        for (animData in data.animations)
        {
            addAnimation(cast data.type, animData.name, animData.prefix, animData.framerate, animData.loop, animData.indices);

            offsets.set(animData.name, animData.offset);
        }

        if (offsets.exists('danceLeft') && offsets.exists('danceRight'))
            playAnim('danceLeft');
        else
            playAnim('idle');

        updateHitbox();
    }

    public var danceTimer:Float = 0;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (danceTimer > 0)
            danceTimer -= elapsed;
    }

    public function playTimerAnim(?anim:String, ?applyTimer:Bool, ?force:Bool)
    {
        if (anim != null)
            playAnim(anim, force);

        if (applyTimer ?? true)
            danceTimer = data.animationLength;
    }

    public function sing(?anim:String, ?applyTimer:Bool, ?force:Bool)
    {
        playTimerAnim(anim, applyTimer, force);

        for (vocal in vocals)
            if (vocal != null)
                vocal.volume = 1;
    }

    public function miss(?anim:String, ?applyTimer:Bool, ?force:Bool)
    {
        playTimerAnim(anim, applyTimer, force);

        for (vocal in vocals)
            if (vocal != null)
                vocal.volume = 0;
    }

    override public function beatHit(curBeat:Int)
    {
        super.beatHit(curBeat);

        if (curBeat % data.danceModulo == 0 && danceTimer <= 0)
            if (offsets.exists('danceLeft') && offsets.exists('danceRight'))
                playAnim(curBeat % (data.danceModulo * 2) == 0 ? 'danceLeft' : 'danceRight');
            else
                playAnim('idle');
    }
}