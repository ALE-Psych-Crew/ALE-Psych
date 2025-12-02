#if !macro

import core.config.DiscordRPC;

import core.backend.Controls;
import core.backend.MusicBeatState;
import core.backend.MusicBeatSubState;
import core.backend.ScriptState;
import core.backend.ScriptSubState;
import core.backend.Conductor;
import core.backend.Mods;

import funkin.states.CustomState;
import funkin.substates.CustomSubState;

import core.config.ClientPrefs;

import utils.CoolUtil;
import utils.CoolVars;
import utils.Paths;
import utils.ALEJson as Json;

import utils.cool.LogUtil.debugTrace;

import funkin.visuals.ALECamera;
import funkin.visuals.objects.Alphabet;

import funkin.states.PlayState;

import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;

import funkin.visuals.mobile.MobileButton;

using StringTools;
#end