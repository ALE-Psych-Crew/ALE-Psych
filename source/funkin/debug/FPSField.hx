package funkin.debug;

import flixel.util.FlxStringUtil;

import cpp.vm.Gc;

class FPSField extends DebugField
{
    public var fps:Float = 0;

    public var memory:Float = 0;
    public var memoryPeak:Float = 0;

    public function new()
    {
        super(    
            [
                {
                    lines: [
                        {
                            type: TEXT,
                            value: 'FPS'
                        }
                    ],
                    size: 25
                },
                {
                    lines: [
                        {
                            type: TEXT,
                            value: 'Memory'
                        }
                    ],
                    color: 0xBFFFFFFF
                },
                {
                    lines: [
                        {
                            type: TEXT,
                            value: 'ALE Psych ' + CoolVars.engineVersion + (Mods.folder.trim() != '' && Mods.folder.trim() != null ? '\n' + Mods.folder : '') + (CoolVars.data.developerMode ? ' - Developer Mode' : '')
                        }
                    ],
                    size: 10,
                    color: 0xBFFFFFFF
                }
            ]
        );

        labels[0].valueFunction = () -> {
            fps = CoolUtil.fpsLerp(fps, FlxG.elapsed <= 0 ? 0 : (1 / FlxG.elapsed), 0.25);

            return 'FPS: ' + Math.floor(fps);
        };

        labels[1].valueFunction = () -> {
            memory = Gc.memInfo64(Gc.MEM_INFO_USAGE);

            if (memoryPeak < memory)
                memoryPeak = memory;

            return 'Memory: ' + FlxStringUtil.formatBytes(memory) + ' / ' + FlxStringUtil.formatBytes(memoryPeak);
        };
    }
}