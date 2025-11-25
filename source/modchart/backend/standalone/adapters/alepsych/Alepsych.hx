package modchart.backend.standalone.adapters.alepsych;

import core.config.ClientPrefs;
import core.backend.Conductor;

import funkin.visuals.game.Note;
import funkin.visuals.game.NoteSplash;
import funkin.visuals.game.StrumNote;

import funkin.states.PlayState;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import modchart.Manager;
import modchart.backend.standalone.IAdapter;

class Alepsych implements IAdapter
{
	private var __fCrochet:Float = 0;

	public function new() {}

	public function onModchartingInitialization()
	{
		__fCrochet = (Conductor.crochet + 8) / 4;
	}

	public function isTapNote(sprite:FlxSprite)
		return sprite is Note;

	public function getSongPosition():Float
		return Conductor.songPosition;

	public function getCurrentBeat():Float
	{
		@:privateAccess
		return PlayState.instance.curDecBeat;
	}

	public function getCurrentCrochet():Float
		return Conductor.crochet;

	public function getBeatFromStep(step:Float)
		return step * .25;

	public function arrowHit(arrow:FlxSprite)
	{
		if (arrow is Note)
			return cast(arrow, Note).wasGoodHit;

		return false;
	}

	public function isHoldEnd(arrow:FlxSprite)
	{
		if (arrow is Note)
		{
			final castedNote = cast(arrow, Note);

			if (castedNote.nextNote != null)
				return !castedNote.nextNote.isSustainNote;
		}

		return false;
	}

	public function getLaneFromArrow(arrow:FlxSprite)
	{
		if (arrow is Note)
			return cast(arrow, Note).noteData;
		else if (arrow is StrumNote) @:privateAccess
			return cast(arrow, StrumNote).noteData;

		return 0;
	}

	public function getPlayerFromArrow(arrow:FlxSprite)
	{
		if (arrow is Note)
			return cast(arrow, Note).mustPress ? 1 : 0;

		if (arrow is StrumNote) @:privateAccess
			return cast(arrow, StrumNote).player;

		return 0;
	}

	public function getKeyCount(?player:Int = 0):Int
		return 4;

	public function getPlayerCount():Int
		return 2;

	public function getTimeFromArrow(arrow:FlxSprite)
	{
		if (arrow is Note)
			return cast(arrow, Note).strumTime;

		return 0;
	}

	public function getHoldSubdivisions(hold:FlxSprite):Int
		return 4;

	public function getHoldLength(item:FlxSprite):Float
		return __fCrochet;

	public function getHoldParentTime(arrow:FlxSprite)
	{
		final note:Note = cast arrow;

		return note.parent.strumTime;
	}

	public function getDownscroll():Bool
		return ClientPrefs.data.downScroll;

	inline function getStrumFromInfo(lane:Int, player:Int)
	{
		var group = player == 0 ? PlayState.instance.opponentStrums : PlayState.instance.playerStrums;

		var strum = null;

		group.forEach(str -> {
			@:privateAccess
			if (str.noteData == lane)
				strum = str;
		});

		return strum;
	}

	public function getDefaultReceptorX(lane:Int, player:Int):Float
		return getStrumFromInfo(lane, player).x;

	public function getDefaultReceptorY(lane:Int, player:Int):Float
		return getDownscroll() ? FlxG.height - getStrumFromInfo(lane, player).y - Note.swagWidth : getStrumFromInfo(lane, player).y;

	public function getArrowCamera():Array<FlxCamera>
		return [PlayState.instance.camHUD];

	public function getCurrentScrollSpeed():Float
		return PlayState.instance.songSpeed * .45;

	public function getArrowItems()
	{
		var pspr:Array<Array<Array<FlxSprite>>> = [[[], [], [], []], [[], [], [], []]];

		@:privateAccess
		PlayState.instance.strumLineNotes.forEachAlive(strumNote -> {
			if (pspr[strumNote.player] == null)
				pspr[strumNote.player] = [];

			pspr[strumNote.player][0].push(strumNote);
		});

		PlayState.instance.notes.forEachAlive(strumNote -> {
			final player = Adapter.instance.getPlayerFromArrow(strumNote);

			if (pspr[player] == null)
				pspr[player] = [];

			pspr[player][strumNote.isSustainNote ? 2 : 1].push(strumNote);
		});

		return pspr;
	}
}
