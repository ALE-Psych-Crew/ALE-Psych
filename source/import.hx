#if !macro
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.sound.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;

import funkin.visuals.objects.FunkinSprite;
import funkin.visuals.objects.Bopper;
import funkin.visuals.ALECamera;
import funkin.states.PlayState;

import core.config.ClientPrefs;

import utils.CoolUtil;
import utils.CoolVars;
import utils.Paths;
import utils.ALEJson as Json;
import utils.Conductor;
import utils.Controls;

import utils.cool.LogUtil.debugTrace;

import core.backend.MusicBeatState;

using StringTools;
#end