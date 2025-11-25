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

        set('colorFromString', function(str:String):FlxColor
        {
            return CoolUtil.colorFromString(str);
        });

        set('getDominantColor', function(tag:String):FlxColor
        {
            if (tagIs(tag, FlxSprite))
                return CoolUtil.dominantColor(getTag(tag));

            return FlxColor.BLACK;
        });

        set('colorFromArray', function(arr:Array<Int>):FlxColor
        {
            return CoolUtil.colorFromArray(arr);
        });


        set('resetEngine', function()
        {
            CoolUtil.resetEngine();
        });

        set('reloadGameMetadata', function()
        {
            CoolUtil.reloadGameMetadata();
        });
        
        set('resizeGame', function(width:Int, height:Int, ?centerWindow:Bool)
        {
            CoolUtil.resizeGame(width, height, centerWindow);
        });


        set('searchComplexFile', function(path:String, ?missingPrint:Bool):String
        {
            return CoolUtil.searchComplexFile(path, missingPrint);
        });

        set('searchFile', function(parent:String, file:String):String
        {
            return CoolUtil.searchFile(parent, file);
        });

        set('openFolder', function(folder:String, ?absolute:Bool)
        {
            CoolUtil.openFolder(folder, absolute);
        });

        set('formatToSongPath', function(str:String):String
        {
            return CoolUtil.formatToSongPath(str);
        });


        set('debugTrace', function(text:Dynamic, ?type:PrintType, ?customType:String = '', ?customColor:FlxColor)
        {
            CoolUtil.debugTrace(text, type, customType, customColor);
        });

        set('ansiColorString', function(str:String, color:FlxColor):String
        {
            return CoolUtil.ansiColorString(str, color);
        });


        set('floorDecimal', function(num:Float, decimals:Int):Float
        {
            return CoolUtil.floorDecimal(num, decimals);
        });

        set('quantize', function(f:Float, snap:Float):Float
        {
            return CoolUtil.quantize(f, snap);
        });

        set('numberArray', function(max:Int, ?min:Int):Array<Int>
        {
            return CoolUtil.numberArray(max, min);
        });

        set('fpsLerp', function(v1:Float, v2:Float, ratio:Float):Float
        {
            return CoolUtil.fpsLerp(v1, v2, ratio);
        });

        set('fpsRatio', function(ratio:Float):Float
        {
            return CoolUtil.fpsRatio(ratio);
        });


        set('loadPlayStateSong', function(name:String, difficulty:String):PlayStateJSONData
        {
            return CoolUtil.loadPlayStateSong(name, difficulty);
        });
        
        set('loadSong', function(name:String, difficulty:String, ?goToPlayState)
        {
            CoolUtil.loadSong(name, difficulty, goToPlayState);
        });

        set('loadWeek', function(weekName:String, names:Array<String>, difficulty:String, ?goToPlayState:Bool)
        {
            CoolUtil.loadWeek(weekName, names, difficulty, goToPlayState);
        });

        
        set('resetState', function()
        {
            CoolUtil.resetState();
        });

        set('switchState', function(state:String, ?args:Array<Dynamic>, ?skipTransIn:Bool, ?skipTransOut:Bool)
        {
            var cl:Dynamic = LuaPresetUtils.getClass(state);

            if (cl == null)
                return;

            CoolUtil.switchState(Type.createInstance(cl, args ?? []), skipTransIn, skipTransOut);
        });

        set('openSubState', function(substate:String, ?args:Array<Dynamic>)
        {
            var cl:Dynamic = LuaPresetUtils.getClass(substate);

            if (cl == null)
                return;

            CoolUtil.openSubState(Type.createInstance(cl, args ?? []));
        });


        set('capitalizeString', function(str:String):String
        {
            return CoolUtil.capitalize(str);
        });

        set('listFromString', function(str:String):Array<String>
        {
            return CoolUtil.listFromString(str);
        });


        set('browserLoad', function(site:String)
        {
            CoolUtil.browserLoad(site);
        });

        set('getBuildTarget', function():String
        {
            return CoolUtil.getBuildTarget();
        });
    }
}
