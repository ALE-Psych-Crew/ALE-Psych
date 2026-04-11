package utils.cool;

import flixel.graphics.frames.FlxFrame;
import flixel.graphics.FlxGraphic;

import animate.FlxAnimate;

import core.structures.JsonSpriteAnimation;
import core.structures.JsonSprite;

import core.enums.SpriteType;

class SpriteUtil
{
    public static function spriteFromJson(?sprite:FlxSprite, json:JsonSprite, ?imageDirectory:String = ''):FlxSprite
    {
        sprite ??= new FunkinSprite();

        if (sprite is FunkinSprite)
            cast(sprite, FunkinSprite).config = json;
        
        // LogUtil.benchmark(() -> {
            loadSpriteFrames(sprite, json.type, ArrayUtil.setArrayPrefix(json.images, imageDirectory), json.frames);
        // }, 'Frames Loading');

        // LogUtil.benchmark(() -> {
            if (json.type != 'image' && json.animations != null) for (index => animData in json.animations) addSpriteAnim(sprite, json.type, animData);
        // }, 'Animations Add');

        // LogUtil.benchmark(() -> {
            if (json.properties != null) ReflectUtil.setProperties(sprite, json.properties);
        // }, 'Properties Setting');

        // LogUtil.benchmark(() -> {
            sprite.updateHitbox();
        // }, 'Hitbox Updating');

        return sprite;
    }

    public static function loadSpriteFrames(sprite:FlxSprite, type:SpriteType, images:Array<String>, ?framesNum:Int)
    {
        switch (type)
        {
            case IMAGE:
                sprite.loadGraphic(Paths.image(images[0]));
            case SHEET:
                sprite.frames = Paths.getMultiAtlas(images);
            case MAP:
                if (sprite is FlxAnimate)
                    cast(sprite, FlxAnimate).frames = Paths.getAnimateAtlas(images[0]);
            case FRAMES:
                final graphic:FlxGraphic = Paths.image(images[0]);

                sprite.loadGraphic(graphic, true, Math.floor(graphic.width / framesNum));
        }
    }

    static var framesCache:Map<String, FlxFrame> = new Map();

    public static function addSpriteAnim(sprite:FlxSprite, type:SpriteType, animData:JsonSpriteAnimation)
    {
        if (type == IMAGE)
            return;

        animData.prefix ??= animData.name;
        animData.frameRate ??= 24;
        animData.loop ??= false;
        
        switch (type)
        {
            case IMAGE:
                
            case SHEET:
                if (animData.indices == null || animData.indices.length <= 0)
                {


                    sprite.animation.addByPrefix(animData.name, animData.prefix, animData.frameRate, animData.loop);
                } else {
                    sprite.animation.addByIndices(animData.name, animData.prefix, animData.indices, '', animData.frameRate, animData.loop);
                }
            case FRAMES:
                sprite.animation.add(animData.name, animData.indices, animData.frameRate, animData.loop);
            case MAP:
                if (sprite is FlxAnimate)
                {
                    final animateSprite:FlxAnimate = cast sprite;

                    if (animData.indices == null || animData.indices.length <= 0)
                        animateSprite.anim.addByFrameLabel(animData.name, animData.prefix, animData.frameRate, animData.loop);
                    else
                        animateSprite.anim.addByFrameLabelIndices(animData.name, animData.prefix, animData.indices, animData.frameRate, animData.loop);
                }
        }

        if (sprite is FunkinSprite && animData.offset != null)
            cast(sprite, FunkinSprite).offsets.set(animData.name, {x: animData.offset.x, y: animData.offset.y});
    }
}