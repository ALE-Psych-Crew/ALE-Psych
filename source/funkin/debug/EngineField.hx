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
                            value: 'Version: ' + CoolVars.engineVersion + '\nCommit: ' + CoolVars.GITHUB_COMMIT
                        }
                    ],
                    size: 10,
                    offset: 0
                }
            ]
        );
    }
}