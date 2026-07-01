package core.structures;

typedef ConductorEvent = {
    bpm:Float,

    time:Float,

    step:Int,
    beat:Int,
    section:Int,

    stepsPerBeat:Int,
    beatsPerSection:Int,

    crochet:Float,
    stepCrochet:Float,
    sectionCrochet:Float
}