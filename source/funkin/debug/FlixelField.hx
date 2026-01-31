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
            (FlxG.state is CustomState ? 'Custom State: ' + cast(FlxG.state, CustomState).scriptName : 'State: ' +  Type.getClassName(Type.getClass(FlxG.state))) +
            '\n' + (FlxG.state.subState is CustomSubState ? 'Custom SubState: ' + cast(FlxG.state.subState, CustomSubState).scriptName : 'SubState: ' + Type.getClassName(Type.getClass(FlxG.state.subState))) +
            '\nObjects: ' + (FlxG.state.members.length + (FlxG.state.subState == null ? 0 : FlxG.state.subState.members.length)) +
            '\nCameras: ' + FlxG.cameras.list.length +
            '\nChilds: ' + FlxG.game.numChildren;
    }
}