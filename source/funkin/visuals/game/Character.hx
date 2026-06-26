package funkin.visuals.game;

import core.structures.JsonCharacter;

import core.enums.CharacterType;

import utils.Formatter;

class Character extends Bopper
{
    public var type:CharacterType;

    public var id:String;

    public var _castConfig(get, never):JsonCharacter;
    function get__castConfig():JsonCharacter
        return cast config;

    public function new(id:String, type:CharacterType)
    {
        pathPrefix = 'characters/';

        super();

        change(id, type);
    }

    public function change(id:String, ?type:CharacterType)
    {
        restart();

        if (type != null)
            this.type = type;

        fromJson(Formatter.getCharacter(id, type));

        flipX = _castConfig.properties.flipX != (this.type == 'player');

        this.id = id;

        if (_castConfig.bopAnimations != null && _castConfig.bopAnimations.length > 0)
            beatHit = curBeat -> if (bopTimer <= 0 && !blockBop) playAnim(_castConfig.bopAnimations[curBeat % _castConfig.bopAnimations.length]);

        playAnim(_castConfig.initialAnimation ?? _castConfig?.bopAnimations[0]);

        anim.onFinish.add(name -> playAnim(name + '-loop'));
    }

    function resetBlockers()
    {
        blockBop = blockSing = blockMiss = false;

        bopTimer = singTimer = missTimer = 0;
    }

    public var bopTimer:Float = 0;
    public var blockBop:Bool = false;

    public var singTimer:Float = 0;
    public var blockSing:Bool = false;

    public var missTimer:Float = 0;
    public var blockMiss:Bool = false;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (bopTimer > 0)
            bopTimer -= elapsed;

        if (singTimer > 0)
            singTimer -= elapsed;

        if (missTimer > 0)
            missTimer -= elapsed;
    }

    override function playAnim(anim:String, ?force:Bool = true)
    {
        super.playAnim(anim, force);

        resetBlockers();
    }

    public function playSpecialAnim(anim:String, ?force:Bool, ?blockBop:Bool = true, ?bopTimer:Float, ?blockSing:Bool = false, ?singTimer:Float, ?blockMiss:Bool = false, ?missTimer:Float)
    {
        playTimedAnim(anim, force, false);

        this.blockBop = blockBop;

        if (bopTimer != null)
            this.bopTimer = bopTimer;

        this.blockSing = blockSing;

        if (singTimer != null)
            this.singTimer = singTimer;

        this.blockMiss = blockMiss;

        if (missTimer != null)
            this.missTimer = missTimer;
    }

    public function playTimedAnim(anim:String, ?force:Bool = true, ?applyTimer:Bool = true)
    {
        playAnim(anim, force);

        if (applyTimer)
            bopTimer = _castConfig.animationLength;
    }

    public var vocals:Array<Sound> = [];

    var singVolume:Float = 1;
    var missVolume:Float = 0;

    public function sing(?anim:String, ?force:Bool = true, ?applyTimer:Bool = true)
    {
        if (blockSing || singTimer > 0)
            return;

        playTimedAnim(anim, force, applyTimer);

        for (vocal in vocals)
            if (vocal != null)
                vocal.volume = singVolume;
    }

    public function miss(?anim:String, ?force:Bool = true, ?applyTimer:Bool = true)
    {
        if (blockMiss || missTimer > 0 || anim == null)
            return;

        playTimedAnim(anim, force, applyTimer);

        for (vocal in vocals)
            if (vocal != null)
                vocal.volume = missVolume;
    }

    override public function restart():FunkinSprite
    {
        super.restart();

        resetBlockers();

        return this;
    }
}