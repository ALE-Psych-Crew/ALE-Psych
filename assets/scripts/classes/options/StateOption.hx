package options;

import options.LabelOption;

class StateOption extends LabelOption
{
    public function new(data:OptionsOption)
    {
        super(data);

        allowInputs = false;

        labelString = data.type.toLowerCase() == 'state' ? 'Enter State' : 'Open SubState';
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (selected && Controls.ACCEPT)
            if (data.type.toLowerCase() == 'state')
                CoolUtil.switchState(data.scripted ? new CustomState(data.path) : Type.createInstance(data.path, []));
            else
                CoolUtil.openSubState(data.scripted ? new CustomSubState(data.path) : Type.createInstance(data.path, []));
    }
}