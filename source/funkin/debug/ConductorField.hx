package funkin.debug;

class ConductorField extends DebugField
{
    public function new()
    {
        super(
            [
                {
                    lines: [
                        {
                            type: TEXT,
                            value: 'Conductor'
                        }
                    ]
                },
                {
                    lines: [
                        for (i in 0...6)
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
            'Song Position: ' + Math.floor(Conductor.songPosition) +
            '\nBPM: ' + Conductor.bpm +
            '\nStep: ' + Conductor.curStep +
            '\nBeat: ' + Conductor.curBeat +
            '\nSection: ' + Conductor.curSection +
            '\nTime Signature: ' + Conductor.beatsPerSection + ' / ' + Conductor.stepsPerBeat;
    }
}