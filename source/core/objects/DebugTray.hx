package core.objects;

import flixel.util.FlxStringUtil;

import core.structures.JsonDebugLine;

import api.DesktopAPI;

import cpp.vm.Gc;

class DebugTray extends GameObject
{
    public final fpsField:DebugField;

    public function new()
    {
        super();

        final extraFields:Array<Array<JsonDebugLine>> = Paths.exists('data/debug.json') ? cast Paths.json('data/debug').fields : [];

        x = 10;
        y = 10;

        var fps:Float = 0;

        var memory:Float = 0;
        var memoryString:String = '';

        var memoryPeak:Float = 0;
        var memoryPeakString:String = '';

        fpsField = addField(() -> {
            fps = CoolUtil.fpsLerp(fps, FlxG.elapsed <= 0 ? 0 : 1 / FlxG.elapsed, 0.1);

            final curMemory:Null<Float> = Gc.memInfo64(Gc.MEM_INFO_USAGE);

            if (memory != curMemory && curMemory != null)
            {
                memory = curMemory;

                memoryString = FlxStringUtil.formatBytes(memory);
                    
                if (memory > memoryPeak)
                {
                    memoryPeak = memory;

                    memoryPeakString = memoryString;
                }
            }

            return 'FPS: ' + Math.floor(fps) + ' | GC: ' + memoryString + ' / ' + memoryPeakString +
                '\n' + (Paths.mod == null ? 'ALE Psych' : Paths.mod) + (CoolVars.meta.developerMode ? ' - Developer Mode' : '');
        });

        addField(() -> {
            return 'Current Version: ' + CoolVars.engineVersion +
                (CoolVars.onlineVersion == null ? '' : '\nOnline Version: ' + CoolVars.onlineVersion) +
                (CoolVars.GITHUB_NAME == null ? '' : ('\nCommit: ' + CoolVars.GITHUB_NAME + (CoolVars.GITHUB_COMMIT == null ? '' : ' (' + CoolVars.GITHUB_COMMIT + ')'))) +
                '\nTimestamp: ' + CoolVars.BUILD_TIMESTAMP;
        });

        addField(() -> {
            return 'Song Position: ' + Math.floor(Conductor.songPosition) + 
                '\nBPM: ' + Conductor.bpm +
                '\nStep: ' + Conductor.curStep +
                '\nBeat: ' + Conductor.curBeat +
                '\nSection: ' + Conductor.curSection +
                '\nTime Signature: ' + Conductor.beatsPerSection + ' | ' + Conductor.stepsPerBeat;
        });

        addField(() -> {
            return (FlxG.state is CustomState ? 'Custom State: ' + cast(FlxG.state, CustomState).scriptName : 'State: ' +  Type.getClassName(Type.getClass(FlxG.state))) +
                '\n' + (FlxG.state.subState is CustomSubState ? 'Custom SubState: ' + cast(FlxG.state.subState, CustomSubState).scriptName : 'SubState: ' + Type.getClassName(Type.getClass(FlxG.state.subState))) +
                '\nObjects: ' + (FlxG.state.members.length + (FlxG.state.subState == null ? 0 : FlxG.state.subState.members.length)) +
                '\nCameras: ' + FlxG.cameras.list.length +
                '\nChilds: ' + FlxG.game.numChildren;
        });

        for (field in extraFields)
        {
            var funcs:Array<Void -> String> = [];

            for (line in field)
            {
                switch (line.type)
                {
                    case 'text':
                        final val = line.value;
                        
                        funcs.push(() -> val);
                    case 'variable':
                        funcs.push(getFunction(line.path, line.variable));
                }
            }

            addField(() -> {
                var str:String = '';

                for (func in funcs)
                    str += func();

                return str;
            });
        }

        setMode();
    }

    public var fields:Array<DebugField> = [];

    var currentMode:Int = -1;

    public function setMode(?mode:Int)
    {
        currentMode = mode ?? (currentMode + 1);

        currentMode %= 3;

        switch (currentMode)
        {
            case 0:
                fpsField.showBG = false;

                for (field in fields)
                    field.visible = field == fpsField;
            case 1:
                fpsField.showBG = true;

                for (field in fields)
                    field.visible = true;
            case 2:
                for (field in fields)
                    field.visible = false;
            default:
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (Controls.FPS_COUNTER)
            setMode();
    }

    var currentHeight:Float = 0;

    public function addField(func:Void -> String):DebugField
    {
        final field:DebugField = new DebugField(func);
        field.y += currentHeight;

        add(field);

        fields.push(field);

        currentHeight += field.height + 5;

        return field;
    }

    function getFunction(daClass:String, daVar:String):Void -> String
    {
        if (daClass.length <= 0)
            return () -> '';

        var obj:Dynamic = Type.resolveClass(daClass);

        if (obj == null)
            return () -> daClass + '.' + daVar;
        
        return () -> getRecursiveProperty(obj, daVar.split('.'));
    }

    function getRecursiveProperty(instance:Dynamic, split:Array<String>):Dynamic
    {
        var result:Dynamic = instance;

        for (part in split)
        {
            result = Reflect.getProperty(result, part);

            if (result == null)
                return null;
        }

        return result;
    }
}