package funkin.states;

import haxe.ds.StringMap;

import ale.ui.ALEUIUtils;

#if cpp
import sys.FileSystem;
#end

class CustomState extends ScriptState
{
    public static var instance:CustomState;

    public var scriptName:String = '';

    #if cpp
    @:unreflective private var reloadThread:Bool = CoolVars.data.developerMode && CoolVars.data.scriptsHotReloading;
    #end

    public var hsArguments:Array<Dynamic>;
    public var luaArguments:Array<Dynamic>;
    
    public var hsVariables:StringMap<Dynamic>;
    public var luaVariables:StringMap<Dynamic>;

    override public function new(script:String, ?hsArguments:Array<Dynamic>, ?luaArguments:Array<Dynamic>, ?hsVariables:StringMap<Dynamic>, ?luaVariables:StringMap<Dynamic>)
    {
        super();

        scriptName = script;

        this.hsArguments = hsArguments;
        this.luaArguments = luaArguments;

        this.hsVariables = hsVariables;
        this.luaVariables = luaVariables;
    }

    @:unreflective var watchFiles:Array<String> = [];

    override public function create()
    {        
        super.create();

        instance = this;

        loadScript('scripts/states/' + scriptName, hsArguments, luaArguments);
        
        loadScript('scripts/states/global', hsArguments, luaArguments);

        for (map in [hsVariables, luaVariables])
            if (map != null)
                for (key in map.keys())
                    if (map == hsVariables)
                        setOnHScripts(key, map.get(key));
                    else
                        setOnLuaScripts(key, map.get(key));

        #if cpp
        FlxG.autoPause = !CoolVars.data.developerMode || !CoolVars.data.scriptsHotReloading;

        if (CoolVars.data.scriptsHotReloading && CoolVars.data.developerMode)
        {
            for (ext in ['.hx', '.lua'])
                for (file in [scriptName, 'global'])
                    addHotReloadingFile('scripts/states/' + file + ext);

            callOnScripts('onHotReloadingConfig');

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

        callOnScripts('onCreate');

        callOnScripts('postCreate');
    }

    public function addHotReloadingFile(path:String)
        if (Paths.exists(path))
            watchFiles.push(Paths.getPath(path));

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        callOnScripts('onUpdate', [elapsed]);

        if (Controls.RESET && CoolVars.data.developerMode && !ALEUIUtils.usingInputs)
            resetCustomState();
        
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

    override public function safeStepHit(safeStep:Int)
    {
        super.safeStepHit(safeStep);

        callOnScripts('onSafeStepHit', [safeStep]);

        callOnScripts('postSafeStepHit', [safeStep]);
    }

    override public function safeBeatHit(safeBeat:Int)
    {
        super.safeBeatHit(safeBeat);

        callOnScripts('onSafeBeatHit', [safeBeat]);

        callOnScripts('postSafeBeatHit', [safeBeat]);
    }

    override public function safeSectionHit(safeSection:Int)
    {
        super.safeSectionHit(safeSection);

        callOnScripts('onSafeSectionHit', [safeSection]);

        callOnScripts('postSafeSectionHit', [safeSection]);
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

        CoolUtil.switchState(new CustomState(scriptName, hsArguments, luaArguments, hsVariables, luaVariables), true, true);

        #if cpp
        if (CoolVars.data.scriptsHotReloading && CoolVars.data.developerMode)
            reloadThread = false;
        #end

        debugTrace('Current State: ' + scriptName, RESET_STATE);
    }
}