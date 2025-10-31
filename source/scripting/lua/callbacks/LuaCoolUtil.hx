package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import funkin.visuals.shaders.ALERuntimeShader;

import flixel.FlxState;
import flixel.FlxSubState;

import core.enums.PrintType;

import core.structures.PlayStateJSONData;

class LuaCoolUtil extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        /**
         * Gets a color from a String that contains its HEX code
         * 
         * @param str String with the HEX code
         * 
         * @return Obtained color
         */
        set('colorFromString', function(str:String):FlxColor
        {
            return CoolUtil.colorFromString(str);
        });

        /**
         * Gets the most frequent color in a sprite
         * 
         * @param tag ID of the sprite
         * 
         * @return Most frequent color
         */
        set('getDominantColor', function(tag:String):FlxColor
        {
            if (tagIs(tag, FlxSprite))
                return CoolUtil.dominantColor(getTag(tag));

            return FlxColor.BLACK;
        });

        /**
         * Gets a color from a list
         * 
         * @param arr List with the color in RGB
         * 
         * @return Obtained color
         */
        set('colorFromArray', function(arr:Array<Int>):FlxColor
        {
            return CoolUtil.colorFromArray(arr);
        });


        /**
         * Resets the engine and some of its variables
         */
        set('resetEngine', function()
        {
            CoolUtil.resetEngine();
        });

        /**
         * Reloads the engine metadata found in `data.json`
         */
        set('reloadGameMetadata', function()
        {
            CoolUtil.reloadGameMetadata();
        });
        
        /**
         * Changes the window and game size
         * 
         * @param width Game width
         * @param height Game height
         * @param centerWindow Defines whether to center the game on screen or not
         */
        set('resizeGame', function(width:Int, height:Int, ?centerWindow:Bool)
        {
            CoolUtil.resizeGame(width, height, centerWindow);
        });


        /**
         * Searches for a file path ignoring spaces and case, being more flexible
         * 
         * @param path File path
         * @param missingPrint Defines whether to warn if the file does not exist
         * 
         * @return Real file path
         */
        set('searchComplexFile', function(path:String, ?missingPrint:Bool):String
        {
            return CoolUtil.searchComplexFile(path, missingPrint);
        });

        /**
         * Searches for a file path within a folder ignoring spaces and case
         * 
         * @param parent Folder where it is searched
         * @param file File being searched
         * 
         * @return Real file path
         */
        set('searchFile', function(parent:String, file:String):String
        {
            return CoolUtil.searchFile(parent, file);
        });

        /**
         * Opens the file explorer at a specific folder
         * 
         * @param folder Folder to open
         * @param absolute Defines whether to resolve from the computer root or from the game folder
         */
        set('openFolder', function(folder:String, ?absolute:Bool)
        {
            CoolUtil.openFolder(folder, absolute);
        });

        /**
         * Lowercases a string and replaces spaces with hyphens
         * 
         * @param str String to process
         * 
         * @return Processed string
         */
        set('formatToSongPath', function(str:String):String
        {
            return CoolUtil.formatToSongPath(str);
        });


        /**
         * Prints text that includes the time it was printed and colors to help distinguish the displayed information
         * 
         * @param text Text to display
         * @param type Type of text to display. Can be `error`, `warning`, `deprecated`, `trace`, `hscript`, `lua`, `missing_file`, `missing_folder`, `custom` or `pop-up`,
         * @param customType Assigns a custom text type
         * @param customColor Assigns a custom text color
         */
        set('debugTrace', function(text:Dynamic, ?type:PrintType, ?customType:String = '', ?customColor:FlxColor)
        {
            CoolUtil.debugTrace(text, type, customType, customColor);
        });

        /**
         * Helps obtain a string which, when printed to the console, will have the indicated color
         * 
         * @param str Text to color
         * @param color Color to apply
         * 
         * @return Colored text
         */
        set('ansiColorString', function(str:String, color:FlxColor):String
        {
            return CoolUtil.ansiColorString(str, color);
        });


        /**
         * Rounds a decimal number but allows showing a certain number of decimals
         * 
         * @param num Number to round
         * @param decimals Maximum number of decimals to show
         * 
         * @return Rounded number with its decimals
         */
        set('floorDecimal', function(num:Float, decimals:Int):Float
        {
            return CoolUtil.floorDecimal(num, decimals);
        });

        /**
         * Snaps a number to a grid
         * 
         * @param f Original value
         * @param snap Number of divisions or steps
         * 
         * @return Value quantized to the nearest multiple of 1/snap
         */
        set('quantize', function(f:Float, snap:Float):Float
        {
            return CoolUtil.quantize(f, snap);
        });

        /**
         * Generates a list of numbers
         * 
         * @param max Maximum number of the list
         * @param min Minimum number of the list
         * 
         * @return List of numbers
         */
        set('numberArray', function(max:Int, ?min:Int):Array<Int>
        {
            return CoolUtil.numberArray(max, min);
        });

        /**
         * Interpolates between two values taking FPS into account
         * 
         * @param v1 Start value
         * @param v2 End value
         * @param ratio Interpolation ratio (0 to 1)
         * 
         * @return Interpolated value adjusted to the FPS rate
         */
        set('fpsLerp', function(v1:Float, v2:Float, ratio:Float):Float
        {
            return CoolUtil.fpsLerp(v1, v2, ratio);
        });

        /**
         * Adjusts a ratio based on elapsed time and clamps it between 0 and 1
         * 
         * @param ratio Base ratio
         * 
         * @return Ratio corrected according to FPS
         */
        set('fpsRatio', function(ratio:Float):Float
        {
            return CoolUtil.fpsRatio(ratio);
        });


        /**
         * Preloads a song JSON in PlayState
         * 
         * @param name Song name
         * @param difficulty Song difficulty
         * 
         * @return Table with the song path (`.route`) and the loaded JSON (`.json`)
         */
        set('loadPlayStateSong', function(name:String, difficulty:String):PlayStateJSONData
        {
            return CoolUtil.loadPlayStateSong(name, difficulty);
        });
        
        /**
         * Loads a song
         * 
         * @param name Song name
         * @param difficulty Song difficulty
         * @param goToPlayState Defines whether the game should go to PlayState
         */
        set('loadSong', function(name:String, difficulty:String, ?goToPlayState)
        {
            CoolUtil.loadSong(name, difficulty, goToPlayState);
        });

        /**
         * Loads a week
         * 
         * @param weekName Week name
         * @param names List with the song names
         * @param difficulty Week difficulty
         * @param goToPlayState Defines whether the game should go to PlayState
         */
        set('loadWeek', function(weekName:String, names:Array<String>, difficulty:String, ?goToPlayState:Bool)
        {
            CoolUtil.loadWeek(weekName, names, difficulty, goToPlayState);
        });

        
        /**
         * Reinitializes the current state
         */
        set('resetState', function()
        {
            CoolUtil.resetState();
        });

        /**
         * Switches the game to a state
         * 
         * @param state Class path of the state
         * @param args Arguments for the class instance
         * @param skipTransIn Defines whether the entry transition will be shown
         * @param skipTransOut Defines whether the exit transition will be shown
         */
        set('switchState', function(state:String, ?args:Array<Dynamic>, ?skipTransIn:Bool, ?skipTransOut:Bool)
        {
            var cl:Dynamic = LuaPresetUtils.getClass(state);

            if (cl == null)
                return;

            CoolUtil.switchState(Type.createInstance(cl, args ?? []), skipTransIn, skipTransOut);
        });

        /**
         * Opens a sub-state
         * 
         * @param substate Class path of the substate
         * @param args Arguments for the class instance
         */
        set('openSubState', function(substate:String, ?args:Array<Dynamic>)
        {
            var cl:Dynamic = LuaPresetUtils.getClass(substate);

            if (cl == null)
                return;

            CoolUtil.openSubState(Type.createInstance(cl, args ?? []));
        });


        /**
         * Capitalizes a string
         * 
         * @param str String to capitalize
         * 
         * @return Capitalized string
         */
        set('capitalizeString', function(str:String):String
        {
            return CoolUtil.capitalize(str);
        });

        /**
         * Extracts a list based on the line breaks of a string
         * 
         * @param str String to process
         * 
         * @return List of lines
         */
        set('listFromString', function(str:String):Array<String>
        {
            return CoolUtil.listFromString(str);
        });


        /**
         * Opens a URL in the browser
         * 
         * @param site Site URL
         */
        set('browserLoad', function(site:String)
        {
            CoolUtil.browserLoad(site);
        });

        /**
         * Gets the target the engine was compiled for
         * 
         * @return Obtained target
         */
        set('getBuildTarget', function():String
        {
            return CoolUtil.getBuildTarget();
        });
    }
}
