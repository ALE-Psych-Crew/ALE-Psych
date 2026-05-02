package funkin.modchart;

import flixel.FlxBasic;

import core.structures.BopData;

import funkin.visuals.game.StrumLine;
import funkin.visuals.game.Strum;

import utils.cool.ReflectUtil;

class ModchartManager extends FlxBasic
{
    public final strumLines:FlxTypedGroup<StrumLine>;

    public var strums:Array<Strum> = [];
    
    public function new(strls:FlxTypedGroup<StrumLine>)
    {
        super();
        
        strumLines = strls;

        for (strl in strumLines)
            for (strum in strl.strums)
                if (strum != null)
                    strums.push(strum);

        Conductor.safeStepHit.add(stepHit);
        Conductor.safeBeatHit.add(beatHit);
        Conductor.safeSectionHit.add(sectionHit);
    }

    public function setModifier(id:Null<String>, strlIndex:Int, strumIndex:Int, ?config:Dynamic)
    {
        final strum:Strum = getStrum(strlIndex, strumIndex);

        if (strum == null)
            return;

        if (id == null)
        {
            strum.modifier = null;

            return;
        }

        final mod:Strum -> ModchartModifier = ModchartUtil.modifiers[id];

        if (mod != null)
        {
            strum.modifier = mod(strum);

            if (config != null)
                ReflectUtil.setProperties(strum.modifier, config);
        }
    }

    public function setStrumLineModifier(id:Null<String>, strlIndex:Int, ?config:Dynamic)
    {
        final strl:StrumLine = strumLines.members[strlIndex];

        if (strl != null)
            for (i in 0...strl.strums.members.length)
                setModifier(id, strlIndex, i, config);
    }

    public function setGlobalModifier(id:Null<String>, ?config:Dynamic)
        for (i in 0...strumLines.length)
            setStrumLineModifier(id, i, config);

    public function configModifier(strlIndex:Int, strumIndex:Int, config:Dynamic)
    {
        final strum:Strum = getStrum(strlIndex, strumIndex);

        if (strum != null && strum.modifier != null)
            ReflectUtil.setProperties(strum.modifier, config);
    }
    
    public function configStrumLineModifier(strlIndex:Int, config:Dynamic)
    {
        final strl:StrumLine = strumLines.members[strlIndex];

        if (strl != null)
            for (i in 0...strl.strums.members.length)
                configModifier(strlIndex, i, config);
    }

    public function configGlobalModifier(config:Dynamic)
        for (i in 0...strumLines.length)
            configStrumLineModifier(i, config);

    public function getStrum(strlIndex:Int, strumIndex:Int):Strum
        return strumLines.members[strlIndex].strums.members[strumIndex];

    function _processBop(curTime:Int, getBop:ModchartModifier -> BopData)
    {
        for (strum in strums)
        {
            if (strum.modifier == null)
                continue;

            final bop = getBop(strum.modifier);

            if (bop != null && (bop.config ?? [0]).contains((curTime - (bop.offset ?? 0)) % bop.modulo ?? 1))
                strum.modifier.bop();
        }
    }

    public function stepHit(curStep:Int)
        _processBop(curStep, m -> m.stepBop);

    public function beatHit(curBeat:Int)
        _processBop(curBeat, m -> m.beatBop);

    public function sectionHit(curSection:Int)
        _processBop(curSection, m -> m.sectionBop);

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        
        for (strum in strums)
            strum.modifier?.update(elapsed);
    }

    override public function destroy()
    {
        super.destroy();
        
        Conductor.safeStepHit.remove(stepHit);
        Conductor.safeBeatHit.remove(beatHit);
        Conductor.safeSectionHit.remove(sectionHit);
    }
}