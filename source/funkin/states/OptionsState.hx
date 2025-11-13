package funkin.states;

class OptionsState extends CustomState
{
    override function new(isPlayState:Bool = false)
    {
        super('OptionsState', null, ['isPlayState' => isPlayState]);

        debugTrace('"OptionsState" is no longer hard-coded', DEPRECATED);
    }
}