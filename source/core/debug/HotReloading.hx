package core.debug;

import sys.thread.Thread;
import sys.thread.Mutex;

import haxe.io.Path;

/**
 * Utility that detects whether any of the specified files have been modified; if so, it will reset the current state
 */
class HotReloading
{
    static var files:Array<String> = null;

    @:unreflective static var mutex:Mutex;

    @:unreflective static var thread:Thread;

    @:unreflective static var reload:Bool = false;

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
                    mutex.acquire();

                    final localFiles:Array<String> = files.copy();

                    mutex.release();

                    var changed:Bool = false;

                    for (file in localFiles)
                    {
                        final lastTime:Float = Paths.exists(file) ? Paths.stat(file).mtime.getTime() : -1;

                        mutex.acquire();

                        if (times.exists(file) && times[file] != lastTime)
                            changed = true;

                        times[file] = lastTime;

                        mutex.release();
                    }

                    if (changed)
                        reload = true;
                }

                Sys.sleep(0.1);
            }
        });

        FlxG.signals.preStateSwitch.add(reset);
        FlxG.signals.preUpdate.add(update);
    }

    @:dox(hide)
    static function update()
    {
        if (!reload)
            return;

        reload = false;

        if (FlxG.state.subState == null && FlxG.state is ScriptedState)
            cast(FlxG.state, ScriptedState).reset();
        else if (FlxG.state.subState is ScriptedSubState)
            cast(FlxG.state.subState, ScriptedSubState).reset();
    }

    @:dox(hide)
    public static function destroy()
    {
        FlxG.signals.preStateSwitch.remove(reset);
        FlxG.signals.preUpdate.remove(update);
    }

    /**
     * This adds a file so that it can be detected
     * @param file 
     */
    public static function add(file:String):Void
        if (check(file))
            files.push(file);

    /**
     * This adds all the files in a folder so they can be detected
     * @param folder 
     * @param recursive 
     */
    public static function addFolder(folder:String, ?recursive:Bool = false):Void
    {
        if (!check(folder))
            return;

        for (nextPath in Paths.readDirectory(folder))
        {
            final path:String = Path.join([folder, nextPath]);

            if (Paths.isDirectory(path) && recursive)
                addFolder(path, true);
            else
                add(path);
        }
    }

    /**
     * This removes a file so that it is no longer detected
     * @param file 
     */
    public static function remove(file:String):Void
    {
        mutex.acquire();

        files.remove(file);

        mutex.release();
    }

    /**
     * This removes all files to be detected
     */
    static function reset():Void
    {
        mutex.acquire();

        files = [];

        mutex.release();

        reload = false;
    }

    /**
     * This checks whether the file path, along with other conditions, allows hot reloading to take effect
     * @param path 
     * @return Bool
     */
    static function check(path:String):Bool
        return CoolVars.meta != null && CoolVars.meta.developerMode && Paths.exists(path);
}