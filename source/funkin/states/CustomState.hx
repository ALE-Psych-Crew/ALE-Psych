package funkin.states;

import haxe.ds.StringMap;

#if cpp
import sys.FileSystem;
#end

class CustomState extends ScriptState
{
    public static var instance:CustomState;

    public var scriptName:String = '';

    private var arguments:Array<Dynamic>;
    
    private var hsVariables:StringMap<Dynamic>;
    private var luaVariables:StringMap<Dynamic>;

    #if cpp
    @:unreflective private var reloadThread:Bool = CoolVars.data.developerMode && CoolVars.data.scriptsHotReloading;
    #end

    override public function new(script:String, ?arguments:Array<Dynamic>, ?hsVariables:StringMap<Dynamic>, ?luaVariables:StringMap<Dynamic>)
    {
        super();

        scriptName = script;

        this.arguments = arguments;

        this.hsVariables = hsVariables;
        this.luaVariables = luaVariables;
    }

    override public function create()
    {        
        super.create();

        #if cpp
        FlxG.autoPause = !CoolVars.data.developerMode || !CoolVars.data.scriptsHotReloading;

        if (CoolVars.data.scriptsHotReloading && CoolVars.data.developerMode)
        {
            var watchFiles = [];

            for (ext in ['.hx', '.lua'])
                for (file in [scriptName, 'global'])
                    if (Paths.exists('scripts/states/' + file + ext))
                        watchFiles.push(Paths.getPath('scripts/states/' + file + ext));

            CoolUtil.createSafeThread(() -> {
                var lastTimes:Map<String, Float> = [];

                for (f in watchFiles)
                    lastTimes.set(f, FileSystem.stat(f).mtime.getTime());

                while (reloadThread)
                {
                    for (f in watchFiles)
                    {
                        var newTime = FileSystem.stat(f).mtime.getTime();

                        if (lastTimes.exists(f) && newTime != lastTimes.get(f))
                        {
                            lastTimes.set(f, newTime);

                            resetCustomState();
                        }
                    }

                    Sys.sleep(0.1);
                }
            });
        }
        #end

        instance = this;

        loadScripts();

        setOnScripts('arguments', arguments);

        for (map in [hsVariables, luaVariables])
            if (map != null)
                for (key in map.keys())
                    if (map == hsVariables)
                        setOnHScripts(key, map.get(key));
                    else
                        setOnLuaScripts(key, map.get(key));

        setOnScripts('resetCustomState', resetCustomState);
        
        callOnScripts('onCreate');

        callOnScripts('postCreate');
    }

    public function loadScripts()
    {
        loadScript(scriptName);
        loadScript('global');
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        callOnScripts('onUpdate', [elapsed]);

        callOnScripts('postUpdate', [elapsed]);
    }

    override public function destroy()
    {
        #if cpp
        if (CoolVars.data.scriptsHotReloading && CoolVars.data.developerMode)
            reloadThread = false;
        #end

        super.destroy();

        callOnScripts('onDestroy');

        instance = null;

        callOnScripts('postDestroy');

        destroyScripts();

        FlxG.autoPause = true;
    }

    override public function stepHit()
    {
        super.stepHit();

        callOnScripts('onStepHit', [curStep]);

        callOnScripts('postStepHit', [curStep]);
    }

    override public function beatHit()
    {
        super.beatHit();

        callOnScripts('onBeatHit', [curBeat]);

        callOnScripts('postBeatHit', [curBeat]);
    }

    override public function sectionHit()
    {
        super.sectionHit();

        callOnScripts('onSectionHit', [curSection]);

        callOnScripts('postSectionHit', [curSection]);
    }

    override public function onFocus()
    {
        super.onFocus();

        callOnScripts('onOnFocus');

        callOnScripts('postOnFocus');
    }

    override public function onFocusLost()
    {
        super.onFocusLost();

        callOnScripts('onOnFocusLost');

        callOnScripts('postOnFocusLost');
    }

    override public function openSubState(substate:flixel.FlxSubState):Void
    {
        super.openSubState(substate);

        callOnHScripts('onOpenSubState', [substate]);
        callOnLuaScripts('onOpenSubState', [Type.getClassName(Type.getClass(substate))]);

        callOnHScripts('postOpenSubState', [substate]);
        callOnLuaScripts('postOpenSubState', [Type.getClassName(Type.getClass(substate))]);
    }

    override public function closeSubState():Void
    {
        super.closeSubState();

        callOnScripts('onCloseSubState');

        callOnScripts('postCloseSubState');
    }

    public function resetCustomState()
    {
        shouldClearMemory = false;

        CoolUtil.switchState(new CustomState(scriptName, arguments, hsVariables, luaVariables), true, true);

        #if cpp
        if (CoolVars.data.scriptsHotReloading && CoolVars.data.developerMode)
            reloadThread = false;
        #end
    }
}