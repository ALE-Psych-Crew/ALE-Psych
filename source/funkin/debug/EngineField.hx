package funkin.debug;

class EngineField extends DebugField
{
    public function new()
    {
        super(
            [
                {
                    lines: [
                        {
                            type: TEXT,
                            value: 'ALE Psych'
                        }
                    ]
                },
                {
                    lines: [
                        {
                            type: TEXT,
                            value: 'Current Version: ' + CoolVars.engineVersion + '\nOnline Version: ' + CoolVars.onlineVersion + '\nCommit: ' + CoolVars.GITHUB_COMMIT
                        }
                    ],
                    size: 10,
                    offset: 0
                }
            ]
        );
    }
}