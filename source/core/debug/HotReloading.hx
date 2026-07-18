package core.debug;

import sys.thread.Thread;
import sys.thread.Mutex;

/**
 * Utility that detects whether any of the specified files have been modified; if so, it will reset the current state
 */
class HotReloading
{
    static var files:Array<String> = null;

    @:unreflective static var mutex:Mutex;

    @:unreflective static var thread:Thread;

    static var times:Map<String, Float> = null;

    @:dox(hide)
    public static function init()
    {
        files = [];

        times = [];

        mutex ??= new Mutex();

        thread ??= CoolUtil.createSafeThread(() -> {
            while (true)
            {
                if (CoolVars.meta != null && CoolVars.meta.hotReloading && CoolVars.meta.developerMode && FlxG.state is ScriptedState)
                {
                    for (file in files)
                    {
                        final lastTime:Float = Paths.exists(file) ? Paths.stat(file).mtime.getTime() : -1;

                        if (times.exists(file) && times[file] != lastTime)
                        {
                            times[file] = lastTime;

                            mutex.acquire();

                            if (FlxG.state.subState == null)
                                cast(FlxG.state, ScriptedState).reset();
                            else if (FlxG.state.subState is ScriptedSubState)
                                cast(FlxG.state.subState, ScriptedSubState).reset();

                            mutex.release();
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

    @:dox(hide)
    public static function destroy()
        FlxG.signals.preStateSwitch.remove(reset);

    /**
     * This adds a file so that it can be detected
     * 
     * @param file 
     */
    public static function add(file:String):Void
        if (CoolVars.meta != null && CoolVars.meta.developerMode && Paths.exists(file))
            files.push(file);

    /**
     * This removes a file so that it is no longer detected
     * 
     * @param file 
     */
    public static function remove(file:String):Void
        files.remove(file);

    /**
     * This removes all files to be detected
     */
    static function reset():Void
        files = [];
}