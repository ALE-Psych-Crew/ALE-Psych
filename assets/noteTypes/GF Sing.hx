function noteHitPre(note:Note, isPlayer:Bool)
{
    if (note.noteType == 'GF Sing')
        note.gfNote = true;
}