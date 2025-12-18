function noteHitPre(note:Note, isPlayer:Bool)
{
    if (note.noteType == 'Hey!')
        note.animToPlay = 'hey';
}