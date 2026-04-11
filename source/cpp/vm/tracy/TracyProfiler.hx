package cpp.vm.tracy;

#if TRACY_ALLOWED
import api.NativeTracyProfiler;
#end

import core.enums.PlotFormatType;

class TracyProfiler
{
    public static function frameMark():Void
    {
        #if TRACY_ALLOWED
        NativeTracyProfiler.frameMark();
        #end
    }

    public static function message(_msg:String, ?_color:Int = 0x000000):Void
    {
        #if TRACY_ALLOWED
        NativeTracyProfiler.message(_msg, _color);
        #end
    }

    public static function messageAppInfo(_info:String):Void
    {
        #if TRACY_ALLOWED
        NativeTracyProfiler.messageAppInfo(_info);
        #end
    }

    public static function plot(_name:String, _val:cpp.Float32):Void
    {
        #if TRACY_ALLOWED
        NativeTracyProfiler.plot(_name, _val);
        #end
    }

    public static function plotConfig(_name:String, _format:PlotFormatType, ?_step:Bool=false, ?_fill:Bool=false, ?_color:Int=0x000000):Void
    {
        #if TRACY_ALLOWED
        NativeTracyProfiler.plotConfig(_name, _format, _step, _fill, _color);
        #end
    }

    public static function setThreadName(_name:String, ?_groupHint:Int=1):Void
    {
        #if TRACY_ALLOWED
        NativeTracyProfiler.setThreadName(_name, _groupHint);
        #end
    }

    public static function zoneScoped(_name:String):Void
    {
        #if TRACY_ALLOWED
        NativeTracyProfiler.zoneScoped(_name);
        #end
    }
}