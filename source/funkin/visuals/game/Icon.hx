package funkin.visuals.game;

import funkin.visuals.objects.Bar;

import flixel.graphics.FlxGraphic;

import utils.cool.MathUtil;
import utils.ALEFormatter;

import core.structures.ALEIcon;

import core.enums.CharacterType;

class Icon extends Bopper
{
    public var bar:Bar;

    public function new(type:CharacterType, ?id:String, ?x:Float, ?y:Float)
    {
        super(x, y);

        change(id, type);
    }

    public var type:CharacterType;

    public var offsetX:Float = 0;
    public var offsetY:Float = 0;

    public var id:String;

    public var data:ALEIcon;

    public function change(?id:String, ?type:CharacterType)
    {
        if (type != null)
            this.type = type;

        if (id == null)
            return;

        this.id = id;

        data = ALEFormatter.getIcon(id);

        data.animations.sort((a, b) -> Math.floor(a.percent - b.percent));

        loadFrames(cast data.type, ['icons/' + data.texture], data.frames);

        for (animData in data.animations)
            addAnimation(cast data.type, animData.name, animData.prefix, animData.framerate, animData.loop, animData.indices);

        offsetX = data.offset.x;
        offsetY = data.offset.y;

        flipX = type != 'player' == data.flipX;

        flipY = data.flipY;

        checkAnimation();
    }

    override public function beatHit(curBeat:Int)
    {
        super.beatHit(curBeat);

        if (data.bopModulo > 0 && curBeat % data.bopModulo == 0)
        {
            scale.x = data.bopScale.x;
            scale.y = data.bopScale.y;

            updateHitbox();

            update(0);
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (data.lerp > 0)
        {
            scale.x = MathUtil.fpsLerp(scale.x, data.scale.x, data.lerp);
            scale.y = MathUtil.fpsLerp(scale.y, data.scale.y, data.lerp);

            updateHitbox();
        }

        if (bar != null)
        {
            final isRight:Bool = type == 'player' == bar.rightToLeft;

            final barMiddle:FlxPoint = bar.getMiddle();

            x = isRight ? (barMiddle.x - offsetX) : (barMiddle.x - width + offsetX);
            y = barMiddle.y - height / 2 + offsetY;

            flipX = type != 'player' == data.flipX;
        }

        checkAnimation();
    }

    var animationIndex:Int = -1;

    public function checkAnimation()
    {
        if (bar == null)
            return;

        final percent:Float = type == 'player' ? bar.percent : (100 - bar.percent);

        while (animationIndex + 1 < data.animations.length && percent >= data.animations[animationIndex + 1].percent)
            animationIndex++;

        while (animationIndex >= 0 && percent < data.animations[animationIndex].percent)
            animationIndex--;

        final curAnimation = data.animations[animationIndex].name;

        if (animation.name != curAnimation)
            playAnim(curAnimation);
    }
}