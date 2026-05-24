package core.enums;

enum abstract FormatterType(String) from String to String
{
    var CHARACTER = 'character';
    var STAGE = 'stage';
    var STRUMLINE = 'strumline';
    var ICON = 'icon';
    var HUD = 'hud';
    var WEEK = 'week';

    public function format():String
    {
        switch (this) {}

        return 'ale-' + this.toString() + '-v0.1';
    }
}