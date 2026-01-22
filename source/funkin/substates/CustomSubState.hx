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

        openCallback = function() { callOnScripts('onOpen'); };
        closeCallback = function() { callOnScripts('onClose'); };

        callOnScripts('onCreate');

        callOnScripts('postCreate');
    }

    override public function update(elapsed:Float)
    {
        callOnScripts('onUpdate', [elapsed]);

        super.update(elapsed);
        
        if (Controls.BACK && CoolVars.data.developerMode && !ALEUIUtils.usingInputs)
            close();

        callOnScripts('postUpdate', [elapsed]);
    }

    override public function destroy()
    {
        callOnScripts('onDestroy');

        super.destroy();

        callOnScripts('postDestroy');

        destroyScripts();
    }

    override public function stepHit(curStep:Int)
    {
        callOnScripts('onStepHit', [curStep]);

        super.stepHit(curStep);

        callOnScripts('postStepHit', [curStep]);
    }

    override public function beatHit(curBeat:Int)
    {
        callOnScripts('onBeatHit', [curBeat]);

        super.beatHit(curBeat);

        callOnScripts('postBeatHit', [curBeat]);
    }

    override public function sectionHit(curSection:Int)
    {
        callOnScripts('onSectionHit', [curSection]);

        super.sectionHit(curSection);

        callOnScripts('postSectionHit', [curSection]);
    }

    override public function safeStepHit(safeStep:Int)
    {
        callOnScripts('onSafeStepHit', [safeStep]);

        super.safeStepHit(safeStep);

        callOnScripts('postSafeStepHit', [safeStep]);
    }

    override public function safeBeatHit(safeBeat:Int)
    {
        callOnScripts('onSafeBeatHit', [safeBeat]);

        super.safeBeatHit(safeBeat);

        callOnScripts('postSafeBeatHit', [safeBeat]);
    }

    override public function safeSectionHit(safeSection:Int)
    {
        callOnScripts('onSafeSectionHit', [safeSection]);

        super.safeSectionHit(safeSection);

        callOnScripts('postSafeSectionHit', [safeSection]);
    }

    override public function onFocus()
    {
        callOnScripts('onOnFocus');

        super.onFocus();

        callOnScripts('postOnFocus');
    }

    override public function onFocusLost()
    {
        callOnScripts('onOnFocusLost');

        super.onFocusLost();

        callOnScripts('postOnFocusLost');
    }
}