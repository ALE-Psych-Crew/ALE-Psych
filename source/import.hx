#if !macro
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxColor;

import flixel.math.FlxPoint;
import flixel.math.FlxMath;

import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxG;

import utils.CoolUtil;
import utils.CoolVars;
import utils.Defines;

import core.debug.Logs.debugTrace;
import core.debug.Logs.benchmark;
import core.debug.Logs;

import core.graphics.Camera;

import core.enums.PrintType;

import core.assets.Paths;

import core.states.ScriptedState;
import core.states.State;

import core.substates.ScriptedSubState;
import core.substates.SubState;

import funkin.states.CustomState;

using StringTools;
#end