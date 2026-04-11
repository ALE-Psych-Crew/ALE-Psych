package cpp.vm.tracy;

import core.enums.PlotFormatType;

@:include('hx/TelemetryTracy.h')
extern class TracyProfiler
{
    @:native('::__hxcpp_tracy_framemark')
    public static function frameMark():Void;

    @:native('::__hxcpp_tracy_message')
    public static function message(_msg:String, ?_color:Int = 0x000000):Void;

    @:native('::__hxcpp_tracy_message_app_info')
    public static function messageAppInfo(_info:String):Void;

    @:native('::__hxcpp_tracy_plot')
    public static function plot(_name:String, _val:cpp.Float32):Void;

    @:native('::__hxcpp_tracy_plot_config')
    public static function plotConfig(_name:String, _format:PlotFormatType, ?_step:Bool=false, ?_fill:Bool=false, ?_color:Int=0x000000):Void;

    @:native('::__hxcpp_tracy_set_thread_name_and_group')
    public static function setThreadName(_name:String, ?_groupHint:Int=1):Void;

    @:native('HXCPP_TRACY_ZONE')
    public static function zoneScoped(_name:String):Void;
}