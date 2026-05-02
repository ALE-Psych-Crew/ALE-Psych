package funkin.modchart;

import core.structures.JsonBase;
import core.structures.BopData;

import funkin.visuals.game.Strum;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;

class ModchartModifier implements IFlxDestroyable
{
    public final strum:Strum;

    public var metadata:Map<String, Dynamic> = new Map<String, Dynamic>();

    public var baseX:Float;
    public var baseY:Float;
    public var baseAngle:Float;
    public var baseDirection:Float;
    public var baseScaleX:Float;
    public var baseScaleY:Float;

    public function new(strum:Strum, ?stepBop:BopData, ?beatBop:BopData, ?sectionBop:BopData, ?updateData:JsonBase, ?bopData:JsonBase)
    {
        this.strum = strum;

        baseX = strum.x;
        baseY = strum.y;
        baseAngle = strum.angle;
        baseDirection = strum.direction;
        baseScaleX = strum.scale.x;
        baseScaleY = strum.scale.y;

        this.updateData = updateData;
        this.bopData = bopData;

        this.stepBop = stepBop;
        this.beatBop = beatBop;
        this.sectionBop = sectionBop;

        init();
    }

    public function init() {}

    public var stepBop:BopData;
    public var beatBop:BopData;
    public var sectionBop:BopData;
    
    public var updateData:JsonBase;
    public var bopData:JsonBase;

    public var curTime:Float = 0;

    public var x(default, set):Float;
    function set_x(value:Float):Float
        return strum.x = x = value;

    public var y(default, set):Float;
    function set_y(value:Float):Float
        return strum.y = y = value;

    public var angle(default, set):Float;
    function set_angle(value:Float):Float
    {
        angle = value;

        strum.angle = strum.strumLine.downScroll ? -angle : angle;

        return value;
    }

    public var direction(default, set):Float;
    function set_direction(value:Float):Float
    {
        direction = value;

        strum.direction = strum.strumLine.downScroll ? -direction : direction;

        return direction;
    }

    public function update(elapsed:Float)
        curTime += elapsed;
    
    public function bop() {}

    public function destroy() {}
}