package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import flixel.text.FlxText.FlxTextBorderStyle;

using StringTools;

class LuaText extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);
		
        /**
         * Creates a `FlxText`
         *
         * @param tag ID of the text
         * @param text Text to display
         * @param width Maximum text width
         * @param x Position `x`
         * @param y Position `y`
         */
        set('makeLuaText', function(tag:String, text:String, width:Int, x:Float, y:Float)
        {
            setTag(tag, new FlxText(x, y, width, text));
        });

        /**
         * Applies a border to text
         *
         * @param tag ID of the text
         * @param size Border thickness
         * @param color Border color
         * @param style Border style. Can be `shadow`, `outline`, `outline_fast` or `none`
         */
        set('setTextBorder', function(tag:String, size:Float, color:FlxColor, ?style:String)
        {
            if (tagIs(tag, FlxText))
            {
                var text:FlxText = getTag(tag);
                text.borderStyle = switch(style.toLowerCase().trim())
                {
                    case 'shadow':
                        FlxTextBorderStyle.SHADOW;
                    case 'outline':
                        FlxTextBorderStyle.OUTLINE;
                    case 'outline_fast':
                        FlxTextBorderStyle.OUTLINE_FAST;
                    default:
                        FlxTextBorderStyle.NONE;
                };
                text.borderSize = size;
                text.borderColor = color;
            }
        });

        /**
         * Applies a font to text
         *
         * @param tag ID of the text
         * @param newFont Font to apply
         */
        set('setTextFont', function(tag:String, newFont:String)
        {
            if (tagIs(tag, FlxText))
            {
                var text:FlxText = getTag(tag);

                text.font = Paths.font(newFont);
            }
        });

        /**
         * Adds a text to the game
         *
         * @param tag ID of the text
         *
         * @deprecated Use `add` instead
         */
        set('addLuaText', function(tag:String)
        {
            deprecatedPrint('Use "add" instead of "addLuaText"');

            if (tagIs(tag, FlxSprite))
                game.add(getTag(tag));
        });

        /**
         * Removes a text from the game
         *
         * @param tag ID of the text
         * @param destroy Defines whether the text should be destroyed
         *
         * @deprecated Use `remove` instead
         */
        set('removeLuaText', function(tag:String, ?destroy:Bool)
        {
            deprecatedPrint('Use "remove" instead of "removeLuaText"');

            if (tagIs(tag, FlxSprite))
                game.remove(getTag(tag), destroy);
        });
    }
}
