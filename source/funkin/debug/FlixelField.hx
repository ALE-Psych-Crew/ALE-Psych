package funkin.debug;

class FlixelField extends DebugField
{
    public function new()
    {
        super(
            [
                {
                    lines: [
                        {
                            type: TEXT,
                            value: 'Flixel'
                        }
                    ]
                },
                {
                    lines: [
                        for (i in 0...5)
                        {
                            {
                                type: TEXT,
                                value: (i > 0 ? '\n' : '') + 'Text'
                            }
                        }
                    ],
                    size: 10,
                    offset: 0
                }
            ]
        );

        labels[1].valueFunction = () -> 
            getState() +
            '\n' + getSubState() +
            '\nObjects: ' + getObjects() +
            '\nCameras: ' + FlxG.cameras.list.length +
            '\nChilds: ' + FlxG.game.numChildren;
    }

    function getState():String
    {
        /*
        if (FlxG.state is CustomState)
            return 'Custom State: ' + cast(FlxG.state, CustomState).scriptName;
        */
        
        return 'State: ' +  Type.getClassName(Type.getClass(FlxG.state));
    }

    function getSubState():String
    {
        /*
        if (FlxG.state.subState is CustomSubState)
            return 'Custom SubState: ' + cast(FlxG.state.subState, CustomSubState).scriptName;
        */
        
        return 'SubState: ' + Type.getClassName(Type.getClass(FlxG.state.subState));
    }

    function getObjects():Int
    {
        var res:Int = FlxG.state.members.length;

        if (FlxG.state.subState != null)
            res += FlxG.state.subState.members.length;

        return res;
    }
}