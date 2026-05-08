package funkin.states;

import ale.ui.UIUtils;

class CustomState extends ScriptedState
{
    public final scriptName:String;

    var haxeArguments:Array<Dynamic>;

    public function new(scriptName:String, ?haxeArguments:Array<Dynamic>)
    {
        super();

        this.scriptName = scriptName;

        this.haxeArguments = haxeArguments;
    }

    override function create()
    {
        super.create();

        loadScript('scripts/states/' + scriptName, haxeArguments);
        
        loadScript('scripts/states/global', haxeArguments);
        
        scriptCallbackCall(ON, 'Create');
        
        scriptCallbackCall(POST, 'Create');
    }
    
    override public function update(elapsed:Float)
    {
        if (scriptCallbackCall(ON, 'Update', [elapsed]))
            super.update(elapsed);

        if (FlxG.keys.justPressed.R && CoolVars.data.developerMode && !UIUtils.usingInputs)
            reset();

        scriptCallbackCall(POST, 'Update', [elapsed]);
    }

    override public function destroy()
    {
        scriptCallbackCall(ON, 'Destroy');

        super.destroy();

        scriptCallbackCall(POST, 'Destroy');

        destroyScripts();
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
        if (scriptCallbackCall(ON, 'OpenSubState', null, [substate]))
            super.openSubState(substate);

        scriptCallbackCall(POST, 'OpenSubState', null, [substate]);
    }

    override public function closeSubState():Void
    {
        if (scriptCallbackCall(ON, 'CloseSubState'))
            super.closeSubState();

        scriptCallbackCall(POST, 'CloseSubState');
    }

    override public function reset()
    {
        allowMemoryCleaning = false;

        CoolUtil.switchState(new CustomState(scriptName, haxeArguments));

        debugTrace('Current State: ' + scriptName, RESET_STATE);
    }
}