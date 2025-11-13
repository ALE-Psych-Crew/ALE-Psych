package options;

import options.LabelOption;

class StringOption extends LabelOption
{
    public var options:Array<String> = [];
    
    public var curValue:String;

    public var selInt:Int = 0;

    override public function new(data:OptionsOption)
    {
        super(data);

        for (opt in data.strings)
            if (!options.contains(opt))
                options.push(opt);

        curValue = getVarVal();

        step(null);
    }

    function step(back:Bool)
    {
        if (back == null)
        {
            if (!options.contains(curValue))
                curValue = options[0];
            
            selInt = options.indexOf(curValue);
        } else {
            if (back)
            {
                if (selInt <= 0)
                    selInt = options.length - 1;
                else
                    selInt--;
            } else {
                if (selInt >= options.length - 1)
                    selInt = 0;
                else
                    selInt++;
            }

            curValue = options[selInt];
        }

        setVarVal(curValue);

        labelString = curValue;
    }
}