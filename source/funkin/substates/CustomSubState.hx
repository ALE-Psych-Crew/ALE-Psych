package funkin.substates;

import haxe.ds.StringMap;

import ale.ui.ALEUIUtils;

class CustomSubState extends ScriptSubState
{
    public var scriptName:String = '';

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

    override public function create()
    {        
        super.create();

        loadScript('scripts/substates/' + scriptName, hsArguments, luaArguments);
        
        loadScript('scripts/substates/global', hsArguments, luaArguments);

        for (map in [hsVariables, luaVariables])
            if (map != null)
                for (key in map.keys())
                    if (map == hsVariables)
                        setOnHScripts(key, map.get(key));
                    else
                        setOnLuaScripts(key, map.get(key));

        openCallback = function() {
            scriptCallbackCall(ON, 'Open');

            scriptCallbackCall(POST, 'Open');
        };

        closeCallback = function() {
            scriptCallbackCall(ON, 'Close');

            scriptCallbackCall(POST, 'Close');
        };

        scriptCallbackCall(ON, 'Create');

        scriptCallbackCall(POST, 'Create');
    }

    override public function update(elapsed:Float)
    {
        if (scriptCallbackCall(ON, 'Update', [elapsed]))
        {
            super.update(elapsed);

            if (Controls.BACK && CoolVars.data.developerMode && !ALEUIUtils.usingInputs)
                close();
        }

        scriptCallbackCall(POST, 'Update', [elapsed]);
    }

    override public function destroy()
    {
        super.destroy();

        scriptCallbackCall(ON, 'Destroy');

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
}