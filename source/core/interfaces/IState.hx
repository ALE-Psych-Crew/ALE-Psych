package core.interfaces;

import flixel.FlxBasic;

interface IState extends IGroup
{
    public var updating(get, never):Bool;
}