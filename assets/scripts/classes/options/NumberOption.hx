package options;

import options.LabelOption;

class NumberOption extends LabelOption
{
    public var curValue:Float;

    override public function new(data:OptionsOption)
    {
        super(data);

        curValue = FlxMath.bound(getVarVal(), data.min, data.max);

        step(null);
    }

    override function step(back:Null<Bool>)
    {
        if (back != null)
        {
            curValue = FlxMath.bound(curValue + data.change * (back ? -1 : 1), data.min, data.max);

            if (data.type.toLowerCase() == 'float')
                curValue = CoolUtil.floorDecimal(curValue, data.decimals);
        }

        setVarVal(curValue);

        labelString = Std.string(curValue);
    }
}