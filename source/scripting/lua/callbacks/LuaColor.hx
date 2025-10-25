package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import flixel.util.FlxColor;

using StringTools;

class LuaColor extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        /**
         * Gets a color from its name
         * 
         * @param name Name of the color. See [FlxColor](https://api.haxeflixel.com/flixel/util/FlxColor.html)
         * 
         * @return Obtained color
         */
        set('getColorFromName', function(name:String):Int
        {
            return switch(name.toUpperCase())
            {
                case 'BLACK':
                    FlxColor.BLACK;
                case 'BLUE':
                    FlxColor.BLUE;
                case 'BROWN':
                    FlxColor.BROWN;
                case 'CYAN':
                    FlxColor.CYAN;
                case 'GRAY':
                    FlxColor.GRAY;
                case 'GREEN':
                    FlxColor.GREEN;
                case 'LIME':
                    FlxColor.LIME;
                case 'MAGENTA':
                    FlxColor.MAGENTA;
                case 'ORANGE':
                    FlxColor.ORANGE;
                case 'PINK': 
                    FlxColor.PINK;
                case 'PURPLE': 
                    FlxColor.PURPLE;
                case 'RED': 
                    FlxColor.RED;
                case 'TRANSPARENT': 
                    FlxColor.TRANSPARENT;
                case 'YELLOW': 
                    FlxColor.YELLOW;
                default: 
                    FlxColor.WHITE;
            };
        });

        /**
         * Gets a color from a String containing its HEX code
         * 
         * @param str String with the HEX code
         * 
         * @return Obtained color
         */
        set('getColorFromString', function(str:String):Int
        {
            return FlxColor.fromString(str);
        });

        /**
         * 
         */
        set('getColorFromRGB', function(r:Int, g:Int, b:Int):Int
        {
            return FlxColor.fromRGB(r, g, b);
        });
    }
}
