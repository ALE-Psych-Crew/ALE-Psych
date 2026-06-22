package funkin.visuals.game;

import funkin.visuals.objects.Bar;

import core.structures.JsonIcon;
import core.enums.CharacterType;

import utils.cool.MathUtil;
import utils.Formatter;

class Icon extends Bopper
{
    public var type:CharacterType;

    public var id:String;

    public var _castConfig(get, never):JsonIcon;
    function get__castConfig():JsonIcon
        return cast config;

    public function new(id:String, type:CharacterType)
    {
        pathPrefix = 'icons/';

        super();

        change(id, type);
    }

    public function change(id:String, ?type:CharacterType)
    {
        restart();

        if (type != null)
            this.type = type;

        fromJson(Formatter.getIcon(id));

        _castConfig.healthAnimations.sort((a, b) -> Reflect.compare(a.percent, b.percent));

        this.id = id;
    }

    public var bar:Bar;

    public var updatePosition:Float -> Void;
    public var updateScale:Float -> Void;

    public var animationIndex:Int = -1;

    public var checkAnimation:Float -> Void;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (updateScale != null)
            updateScale(elapsed);

        if (updatePosition != null)
            updatePosition(elapsed);

        if (checkAnimation != null)
            checkAnimation(elapsed);
    }

    override public function restart():FunkinSprite
    {
        super.restart();

        animationIndex = -1;

        beatHit = curBeat -> {
            if (_castConfig.bopModulo > 0 && curBeat % _castConfig.bopModulo == 0)
            {
                scale.x = _castConfig.bopScale.x;
                scale.y = _castConfig.bopScale.y;

                updateHitbox();

                update(0);
            }
        };

        updatePosition = elapsed -> {
            if (bar == null)
                return;

            final isRight:Bool = (type == 'player') == !bar.leftToRight;

            final barMiddle:FlxPoint = bar.getMiddle();

            x = isRight ? barMiddle.x - getAnimOffset().x : barMiddle.x - width + getAnimOffset().x;
            y = barMiddle.y - height / 2 - getAnimOffset().y;
        };

        updateScale = elapsed -> {
            if (_castConfig.speed <= 0)
                return;

            scale.x = MathUtil.fpsLerp(scale.x, _castConfig.properties.scale.x, _castConfig.speed);
            scale.y = MathUtil.fpsLerp(scale.y, _castConfig.properties.scale.y, _castConfig.speed);

            updateHitbox();
        };

        checkAnimation = elapsed -> {
            if (bar == null)
                return;

            flipX = ((type != 'player') == _castConfig.properties.flipX) == !bar.leftToRight;

            final percent:Float = type == 'player' ? bar.percent : (100 - bar.percent);

            while (animationIndex + 1 < _castConfig.healthAnimations.length && percent >= _castConfig.healthAnimations[animationIndex + 1].percent)
                animationIndex++;

            while (animationIndex >= 0 && percent < _castConfig.healthAnimations[animationIndex].percent)
                animationIndex--;

            final curAnimation = _castConfig.healthAnimations[animationIndex].name;

            if (animation.name != curAnimation)
            {
                playAnim(curAnimation);

                update(0);
            }            
        };

        return this;
    }
}