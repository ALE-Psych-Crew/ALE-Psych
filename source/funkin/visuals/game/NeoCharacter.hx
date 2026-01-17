package funkin.visuals.game;

import funkin.visuals.objects.FunkinSprite;

import utils.ALEFormatter;

import core.structures.ALECharacter;

import core.enums.CharacterType;

class NeoCharacter extends FunkinSprite
{
    public var type:CharacterType;

    public function new(initial:String, type:CharacterType)
    {
        super();

        this.type = type;

        change(initial);

        animation.onFinish.add((name) -> {
            if (offsets.exists(name + '-loop'))
                playAnim(name + '-loop');
        });
    }

    public var data:ALECharacter;

    public var id:String;

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

        frames = Paths.getMultiAtlas(data.textures);

        flipX = data.flipX != (this.type == 'player');

        flipY = data.flipY;

        antialiasing = data.antialiasing;

        offsets.clear();
        
        for (anim in data.animations)
        {
            if (anim.indices != null && anim.indices.length > 0)
                animation.addByIndices(anim.animation, anim.prefix, anim.indices, '', anim.framerate, anim.loop);
            else
                animation.addByPrefix(anim.animation, anim.prefix, anim.framerate, anim.loop);

            offsets.set(anim.animation, anim.offset);
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

    public function sing(?anim:String, ?applyTimer:Bool, ?force:Bool)
    {
        if (anim != null)
            playAnim(anim, force);

        if (applyTimer ?? true)
            danceTimer = data.animationLength;
    }

    public function dance()
    {
        if (Conductor.curBeat % data.danceModulo == 0 && danceTimer <= 0)
            if (offsets.exists('danceLeft') && offsets.exists('danceRight'))
                playAnim(Conductor.curBeat % (data.danceModulo * 2) == 0 ? 'danceLeft' : 'danceRight');
            else
                playAnim('idle');
    }
}