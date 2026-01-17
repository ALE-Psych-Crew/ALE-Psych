package funkin.visuals.objects;

import flixel.graphics.FlxGraphic;

import core.enums.CharacterType;

class Icon extends FlxSprite
{
    public function new(type:CharacterType, ?id:String, ?x:Float, ?y:Float)
    {
        super(x, y);

        change(id, type);
    }

    public var id:String;

    public var type:CharacterType;

    public var offsetX:Float = 0;
    public var offsetY:Float = 0;

    public function change(?id:String, ?type:CharacterType)
    {
        if (type != null)
            this.type = type;

        if (id == null)
            return;

        this.id = id;

        final graphic:FlxGraphic = Paths.image('icons/icon-' + id, false, false) ?? Paths.image('icons/' + id, false, false) ?? Paths.image('icons/face');

        loadGraphic(graphic, true, Math.floor(graphic.width / 2));

        animation.add('neutral', [0], 0, false);
        animation.add('lose', [1], 0, false);

        animation.play('neutral');

        updateHitbox();
        centerOrigin();
    }
}