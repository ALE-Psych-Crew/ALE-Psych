package core.debug;

import sys.thread.Thread;

class HotReloading
{
    static var files:Array<String> = null;

    @:unreflective static var thread:Thread;

    static var times:Map<String, Float> = null;

    public static function init()
    {
        files = [];

        times = [];

        thread ??= CoolUtil.createSafeThread(() -> {
            while (true)
            {
                if (CoolVars.data != null && CoolVars.data.hotReloading && CoolVars.data.developerMode && FlxG.state is ScriptedState)
                {
                    for (file in files)
                    {
                        final lastTime:Float = Paths.stat(file).mtime.getTime();

                        if (times.exists(file) && times[file] != lastTime)
                        {
                            times[file] = lastTime;

                            if (FlxG.state.subState == null)
                                cast(FlxG.state, ScriptedState).reset();
                        } else {
                            times[file] = lastTime;
                        }
                    }
                }

                Sys.sleep(0.1);
            }
        });

        FlxG.signals.preStateSwitch.add(reset);
    }

    public static function destroy()
        FlxG.signals.preStateSwitch.remove(reset);

    public static function add(file:String)
        if (Paths.exists(file))
            files.push(file);

    public static function remove(file:String)
        files.remove(file);

    static function reset()
        files = [];
}