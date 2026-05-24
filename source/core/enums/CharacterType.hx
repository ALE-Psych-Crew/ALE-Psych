package core.enums;

enum abstract CharacterType(String) from String to String
{
    var OPPONENT = 'opponent';
    var PLAYER = 'player';
    var EXTRA = 'extra';
}