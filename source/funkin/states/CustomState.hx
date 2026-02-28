package funkin.states;

import haxe.ds.StringMap;

import ale.ui.ALEUIUtils;

#if cpp
import sys.FileSystem;
#end

class CustomState extends ScriptState
{
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

        scriptCallbackCall(ON, 'Create');
        
        scriptCallbackCall(POST, 'Create');
    }

    public function addHotReloadingFile(path:String)
        if (Paths.exists(path))
            watchFiles.push(Paths.getPath(path));

    override public function update(elapsed:Float)
    {
        if (scriptCallbackCall(ON, 'Update', [elapsed]))
        {
            super.update(elapsed);

            if (Controls.RESET && CoolVars.data.developerMode && !ALEUIUtils.usingInputs)
                resetCustomState();
        }

        scriptCallbackCall(POST, 'Update', [elapsed]);
    }

    override public function destroy()
    {
        scriptCallbackCall(ON, 'Destroy');

        super.destroy();

        #if cpp
        if (CoolVars.data.scriptsHotReloading && CoolVars.data.developerMode)
            reloadThread = false;
        #end

        FlxG.autoPause = true;

        scriptCallbackCall(POST, 'Destroy');

        destroyScripts();
    }

    override public function stepHit(curStep:Int)
    {
        if (scriptCallbackCall(ON, 'StepHit', [curStep]))
            super.stepHit(curStep);

        scriptCallbackCall(POST, 'StepHit', [curStep]);
    }

    override public function beatHit(curBeat:Int)
    {
        if (scriptCallbackCall(ON, 'BeatHit', [curBeat]))
            super.beatHit(curBeat);

        scriptCallbackCall(POST, 'BeatHit', [curBeat]);
    }

    override public function sectionHit(curSection:Int)
    {
        if (scriptCallbackCall(ON, 'SectionHit', [curSection]))
            super.sectionHit(curSection);

        scriptCallbackCall(POST, 'SectionHit', [curSection]);
    }

    override public function safeStepHit(safeStep:Int)
    {
        if (scriptCallbackCall(ON, 'SafeStepHit', [safeStep]))
            super.safeStepHit(safeStep);

        scriptCallbackCall(POST, 'SafeStepHit', [safeStep]);
    }

    override public function safeBeatHit(safeBeat:Int)
    {
        if (scriptCallbackCall(ON, 'SafeBeatHit', [safeBeat]))
            super.safeBeatHit(safeBeat);

        scriptCallbackCall(POST, 'SafeBeatHit', [safeBeat]);
    }

    override public function safeSectionHit(safeSection:Int)
    {
        if (scriptCallbackCall(ON, 'SafeSectionHit', [safeSection]))
            super.safeSectionHit(safeSection);

        scriptCallbackCall(POST, 'SafeSectionHit', [safeSection]);
    }

    override public function onFocus()
    {
        if (scriptCallbackCall(ON, 'OnFocus'))
            super.onFocus();

        scriptCallbackCall(POST, 'OnFocus');
    }

    override public function onFocusLost()
    {
        if (scriptCallbackCall(ON, 'OnFocusLost'))
            super.onFocusLost();

        scriptCallbackCall(POST, 'OnFocusLost');
    }

    override public function openSubState(substate:flixel.FlxSubState):Void
    {
        if (scriptCallbackCall(ON, 'OpenSubState', null, [substate], [Type.getClassName(Type.getClass(substate))]))
            super.openSubState(substate);

        scriptCallbackCall(POST, 'OpenSubState', null, [substate], [Type.getClassName(Type.getClass(substate))]);
    }

    override public function closeSubState():Void
    {
        if (scriptCallbackCall(ON, 'CloseSubState'))
            super.closeSubState();

        scriptCallbackCall(POST, 'CloseSubState');
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