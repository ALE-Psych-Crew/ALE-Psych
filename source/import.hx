#if !macro
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;

import flixel.math.FlxPoint;
import flixel.math.FlxMath;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import flixel.text.FlxText;

import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup;

import flixel.sound.FlxSound;

import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxG;

import utils.CoolUtil;
import utils.CoolVars;
import utils.Controls;
import utils.Defines;
import utils.Json;

import core.audio.Conductor;
import core.audio.Sound;

import core.debug.Logs.debugTrace;
import core.debug.Logs.benchmark;
import core.debug.Logs;

import core.visuals.Camera;

import core.enums.PrintType;

import core.assets.Paths;

import core.states.ScriptedState;
import core.states.State;

import core.substates.ScriptedSubState;
import core.substates.SubState;

import funkin.visuals.objects.FunkinSprite;
import funkin.visuals.objects.Bopper;

import funkin.states.CustomState;
import funkin.states.PlayState;

import funkin.substates.CustomSubState;

import funkin.config.ClientPrefs;
import funkin.config.Save;

using StringTools;
#end