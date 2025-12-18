function noteHitPre(note:Note, isPlayer:Bool)
{
    if (note.noteType == 'Alt Animation')
        note.animSuffix = '-alt';
}