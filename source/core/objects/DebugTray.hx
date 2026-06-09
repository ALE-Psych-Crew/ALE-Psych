package core.objects;

import flixel.util.FlxStringUtil;

import core.structures.JsonDebugLine;

import api.DesktopAPI;

#if cpp
import cpp.vm.Gc;
#end

/**
 * This is the primary source of information for debugging, including:
 * 
 * 1. Frames per Second
 * 2. Memory Usage
 * 
 * 3. Current Engine Version
 * 4. Online Engine Version
 * 5. Current Engine Commit
 * 6. Compilation Date
 * 
 * 7. Song Position
 * 8. Song BPM
 * 9. Song Step
 * 10. Song Beat
 * 11. Song Section
 * 12. Time Signature
 * 
 * 13. Current State
 * 14. Current Substate
 * 15. Number of Objects
 * 16. Number of Cameras
 * 17. Number of Flixel Children
 */
class DebugTray extends GameObject
{
    /**
     * A special category for FPS games, as they behave slightly differently from other games
     */
    public final fpsField:DebugField;

    /**
     * This creates the tray with the information
     */
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

            #if cpp
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
            #end

            return 'FPS: ' + Math.floor(fps) #if cpp + ' | GC: ' + memoryString + ' / ' + memoryPeakString #end +
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

        final assetsRootsText:String = 'Asset Search Paths\n' + [for (root in Paths.library.roots) '- ' + root + '/'].join('\n');

        addField(() -> assetsRootsText);

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

    /**
     * Tray fields
     */
    public var fields:Array<DebugField> = [];

    /**
     * Current tray mode
     * 
     * 0. Show only FPS without background
     * 1. Show all fields with their backgrounds
     * 2. Hide all fields
     */
    var currentMode:Int = -1;

    /**
     * Set the current mode by making the necessary adjustments
     * 
     * @param mode If the target mode is not specified, the system will simply proceed to the next mode
     */
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

    @:dox(hide)
    var currentHeight:Float = 0;

    /**
     * Just create a field and add it to the tray
     * 
     * @param func Function that determines how the text in the new field should be displayed
     * @return `DebugField` created
     */
    public function addField(func:Void -> String):DebugField
    {
        final field:DebugField = new DebugField(func);
        field.y += currentHeight;

        add(field);

        fields.push(field);

        currentHeight += field.height + 5;

        return field;
    }

    @:dox(hide)
    function getFunction(daClass:String, daVar:String):Void -> String
    {
        if (daClass.length <= 0)
            return () -> '';

        var obj:Dynamic = Type.resolveClass(daClass);

        if (obj == null)
            return () -> daClass + '.' + daVar;
        
        return () -> getRecursiveProperty(obj, daVar.split('.'));
    }

    @:dox(hide)
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