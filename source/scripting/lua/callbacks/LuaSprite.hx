package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import openfl.display.BlendMode;

import flixel.util.FlxColor;

using StringTools;

@:access(openfl.display.BlendMode)
class LuaSprite extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        /**
         * Creates a `FlxSprite`
         * 
         * @param tag Sprite ID
         * @param image Image path
         * @param x Position on `x`
         * @param y Position on `y`
         */
        set('makeLuaSprite', function(tag:String, ?image:String, ?x:Float, ?y:Float)
        {
            var sprite:FlxSprite = new FlxSprite(x, y);

            if (image != null)
                sprite.loadGraphic(Paths.image(image));

            sprite.animation.finishCallback = function(name:String)
            {
                lua.call('onSpriteAnimationComplete', [tag, name]);
            };

            setTag(tag, sprite);
        });

        /**
         * Loads a graphic into a sprite
         * 
         * @param tag Sprite ID
         * @param sprite Image path
         * @param gridX Maximum graphic width
         * @param gridY Maximum graphic height
         */
        set('loadGraphic', function(tag:String, sprite:String, ?gridX:Int = 0, ?gridY:Int = 0)
        {
            if (tagIs(tag, FlxSprite))
                getTag(tag).loadGraphic(Paths.image(sprite), gridX != 0 || gridY != 0, gridX, gridY);
        });

        /**
         * Creates a square graphic and loads it into a sprite
         * 
         * @param tag Sprite ID
         * @param x Graphic width
         * @param y Graphic height
         * @param color Graphic color
         */
        set('makeGraphic', function(tag:String, x:Float, y:Float, ?color:FlxColor)
        {
            if (tagIs(tag, FlxSprite))
                getTag(tag).makeGraphic(x, y, color);
        });

        /**
         * Loads an animated graphic into a sprite
         * 
         * @param tag Sprite ID
         * @param sprite Image path
         * @param spriteType Graphic type. Can be `sparrow`, `packer`, `aseprite`
         */
        set('loadFrames', function(tag:String, sprite:String, ?spriteType:String)
        {
            if (tagIs(tag, FlxSprite))
                getTag(tag).frames = switch ((spriteType ?? 'multi').toLowerCase())
                {
                    case 'sparrow':
                        Paths.getSparrowAtlas(sprite);
                    case 'packer':
                        Paths.getPackerAtlas(sprite);
                    case 'aseprite':
                        Paths.getAsepriteAtlas(sprite);
                    default:
                        Paths.getAtlas(sprite);
                };
        });

        /**
         * Adds an animation to the sprite
         * 
         * @param tag Sprite ID
         * @param name Animation name
         * @param prefix Animation prefix in the atlas
         * @param framerate Animation speed in frames
         * @param loop Defines whether the animation should loop
         */
        set('addAnimationByPrefix', function(tag:String, name:String, prefix:String, ?framerate:Int, ?loop:Bool)
        {
            if (tagIs(tag, FlxSprite))
                getTag(tag).animation.addByPrefix(name, prefix, framerate, loop);
        });

        /**
         * Adds an animation to the sprite
         * 
         * @param tag Sprite ID
         * @param name Animation name
         * @param frames Indices that indicate which frames to play and in what order
         * @param framerate Animation speed in frames
         * @param loop Defines whether the animation should loop
         */
        set('addAnimation', function(tag:String, name:String, frames:Array<Int>, ?framerate:Int, ?loop:Bool)
        {
            if (tagIs(tag, FlxSprite))
                getTag(tag).animation.add(name, frames, framerate, loop);
        });

        /**
         * Adds an animation to the sprite
         * 
         * @param tag Sprite ID
         * @param name Animation name
         * @param prefix Animation prefix in the atlas
         * @param indices Indices that indicate which frames to play and in what order
         * @param framerate Animation speed in frames
         * @param loop Defines whether the animation should loop
         */
        set('addAnimationByIndices', function(tag:String, name:String, prefix:String, indices:Array<Int>, ?framerate:Int, ?loop:Bool)
        {
            if (tagIs(tag, FlxSprite))
                getTag(tag).animation.addByIndices(name, prefix, indices, '', framerate, loop);
        });

        /**
         * Plays a sprite animation
         * 
         * @param tag Sprite ID
         * @param name Animation name
         * @param forced Forces the animation to play
         */
        set('playAnim', function(tag:String, name:String, ?forced:Bool, ?reversed:Bool, ?startFrame:Int)
        {
            if (tagIs(tag, FlxSprite))
                getTag(tag).animation.play(name, forced, reversed, startFrame);
        });

        /**
         * Sets the sprite size in pixels
         * 
         * @param tag Sprite ID
         * @param w Sprite width
         * @param h Sprite height
         */
        set('setGraphicSize', function(tag:String, w:Int, h:Int)
        {
            if (tagIs(tag, FlxSprite))
                getTag(tag).setGraphicSize(w, h);
        });

        /**
         * Updates the sprite hitbox
         * 
         * @param tag Sprite ID
         */
        set('updateHitbox', function(tag:String)
        {
            if (tagIs(tag, FlxSprite))
                getTag(tag).updateHitbox();
        });

        /**
         * Changes how a sprite's colors blend with others
         * 
         * @param tag Sprite ID
         * @param mode Defines the color blend mode. Can be `add`,`alpha`,`darken`,`difference`,`erase`,`hardlight`,`invert`,`layer`,`lighten`,`multiply`,`normal`,`overlay`,`screen`,`shader` or `subtract`
         */
        set('setBlendMode', function(tag:String, mode:String)
        {
            if (tagIs(tag, FlxSprite))
                getTag(tag).blend = BlendMode.fromString(mode.trim().toLowerCase());
        });

        /**
         * Gets the color of a pixel in a sprite
         * 
         * @param tag Sprite ID
         * @param x Pixel `x` position
         * @param y Pixel `y` position
         * 
         * @return Pixel color
         */
        set('getPixelColor', function(tag:String, x:Int, y:Int):Int
        {
            if (tagIs(tag, FlxSprite))
                return getTag(tag).pixels.getPixel32(x, y);

            return FlxColor.BLACK;
        });

        /**
         * Adds a sprite to the game
         * 
         * @param tag Sprite ID
         * 
         * @deprecated Use `add` instead
         */
        set('addLuaSprite', function(tag:String)
        {
            deprecatedPrint('Use "add" instead of "addLuaSprite"');

            if (tagIs(tag, FlxSprite))
                game.add(getTag(tag));
        });

        /**
         * Removes a sprite from the game
		 * 
		 * @param tag Sprite ID
		 * @param destroy Defines whether the sprite should be destroyed
		 * 
		 * @deprecated Use `remove` instead
         */
        set('removeLuaSprite', function(tag:String, ?destroy:Bool)
        {
            deprecatedPrint('Use "remove" instead of "removeLuaSprite"');

            if (tagIs(tag, FlxSprite))
                game.remove(getTag(tag), destroy);
        });

        /**
         * Gets the `x` coordinate of the sprite midpoint
         * 
         * @param tag Sprite ID
         * 
         * @return `x` of the sprite midpoint
         */
        set('getMidpointX', function(tag:String):Float
        {
            if (tagIs(tag, FlxSprite))
                return getTag(tag).getMidpoint().x;
            
            return 0;
        });

        /**
         * Gets the `y` coordinate of the sprite midpoint
         * 
         * @param tag Sprite ID
         * 
         * @return `y` of the sprite midpoint
         */
        set('getMidpointY', function(tag:String):Float
        {
            if (tagIs(tag, FlxSprite))
                return getTag(tag).getMidpoint().y;

            return 0;
        });

        /**
         * Gets the `x` coordinate of the sprite graphic midpoint
         * 
         * @param tag Sprite ID
         * 
         * @return `x` of the sprite graphic midpoint
         */
        set('getGraphicMidpointX', function(tag:String):Float
        {
            if (tagIs(tag, FlxSprite))
                return getTag(tag).getGraphicMidpoint().x;

            return 0;
        });

        /**
         * Gets the `y` coordinate of the sprite graphic midpoint
         * 
         * @param tag Sprite ID
         * 
         * @return `y` of the sprite graphic midpoint
         */
        set('getGraphicMidpointY', function(tag:String):Float
        {
            if (tagIs(tag, FlxSprite))
                return getTag(tag).getGraphicMidpoint().y;
            
            return 0;
        });

        /**
         * Gets the sprite screen `x` position
         * 
         * @param tag Sprite ID
         * 
         * @return Sprite screen `x` position
         */
        set('getScreenPositionX', function(tag:String):Float
        {
            if (tagIs(tag, FlxSprite))
                return getTag(tag).getScreenPosition().x;
            
            return 0;
        });

        /**
         * Gets the sprite screen `y` position
         * 
         * @param tag Sprite ID
         * 
         * @return Sprite screen `y` position
         */
        set('getScreenPositionY', function(tag:String):Float
        {
            if (tagIs(tag, FlxSprite))
                return getTag(tag).getScreenPosition().y;
            
            return 0;
        });
    }
}
