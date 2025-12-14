package funkin.substates;

import haxe.ds.StringMap;

import ale.ui.ALEUIUtils;

class CustomSubState extends ScriptSubState
{
    public static var instance:CustomSubState;

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

        instance = this;

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
        super.update(elapsed);

        callOnScripts('onUpdate', [elapsed]);

        if (Controls.BACK && CoolVars.data.developerMode && !ALEUIUtils.usingInputs)
            close();

        callOnScripts('postUpdate', [elapsed]);
    }

    override public function destroy()
    {
        super.destroy();

        callOnScripts('onDestroy');

        instance = null;

        callOnScripts('postDestroy');

        destroyScripts();
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
}