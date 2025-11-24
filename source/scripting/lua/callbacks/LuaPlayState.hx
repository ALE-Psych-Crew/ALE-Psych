package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import scripting.lua.LuaPresetUtils;

import sys.FileSystem;

class LuaPlayState extends LuaPresetBase
{
    public var playState:PlayState = PlayState.instance;

    override public function new(lua:LuaScript)
    {
        super(lua);

        /**
         * Whether the current PlayState was launched from the Chart Editor.
         */
        set('inChartEditor', false);

		set('difficulty', PlayState.difficulty);
        /**
         * Current Conductor BPM value.
         */
        set('curBpm', Conductor.bpm);

        /**
         * Song BPM defined in the loaded chart.
         */
        set('bpm', PlayState.SONG.bpm);

        /**
         * Scroll speed defined by the chart.
         */
        set('scrollSpeed', PlayState.SONG.speed);

        /**
         * Duration of a crochet (quarter note), in milliseconds.
         */
        set('crochet', Conductor.crochet);

        /**
         * Duration of a step, in milliseconds.
         */
        set('stepCrochet', Conductor.stepCrochet);

        /**
         * Length of the current song, in milliseconds.
         */
        set('songLength', FlxG.sound.music.length);

        /**
         * Name of the current song.
         */
        set('songName', PlayState.SONG.song);

        /**
         * File system path to the current song.
         */
        set('songPath', PlayState.songRoute);

        /**
         * Whether the song countdown has already started.
         */
        set('startedCountdown', false);

        /**
         * Name of the stage currently in use.
         */
        set('curStage', PlayState.SONG.stage);

        /**
         * Whether the game is currently in Story Mode.
         */
        set('isStoryMode', PlayState.isStoryMode);

        /**
         * Numeric difficulty of the current chart.
         */
        set('difficulty', PlayState.difficulty);

        /**
         * Current week identifier.
         */
        set('week', PlayState.week);

        /**
         * Whether the cutscene for the song has already been seen.
         */
        set('seenCutscene', PlayState.seenCutscene);

        /**
         * Whether the song uses vocal tracks.
         */
        set('hasVocals', PlayState.SONG.needsVoices);

        /**
         * Camera X coordinate override.
         */
        set('cameraX', 0);

        /**
         * Camera Y coordinate override.
         */
        set('cameraY', 0);

        /**
         * Player score value.
         */
        set('score', 0);

        /**
         * Amount of missed notes in the current song.
         */
        set('misses', 0);

        /**
         * Amount of successful note hits.
         */
        set('hits', 0);

        /**
         * Current note combo value.
         */
        set('combo', 0);

        /**
         * Current accuracy rating value.
         */
        set('rating', 0);

        /**
         * Rating name string for the current accuracy.
         */
        set('ratingName', '');

        /**
         * Rating FC label for the run.
         */
        set('ratingFC', '');

        /**
         * Whether the PlayState has already reached game over.
         */
        set('inplayStateOver', false);

        /**
         * Whether the current section belongs to the player (must-hit section).
         */
        set('mustHitSection', false);

        /**
         * Whether alt animations are active for the opponent section.
         */
        set('altAnim', false);

        /**
         * Whether the current section is dedicated to the girlfriend character.
         */
        set('gfSection', false);

        /**
         * Multiplier applied to health gained on successful hits.
         */
        set('healthGainMult', playState.healthGain);

        /**
         * Multiplier applied to health lost on misses.
         */
        set('healthLossMult', playState.healthLoss);

        #if FLX_PITCH
        /**
         * Current playback rate affecting song speed.
         */
        set('playbackRate', playState.playbackRate);
        #else
        /**
         * Current playback rate affecting song speed.
         */
        set('playbackRate', 1);
        #end

        /**
         * Whether sustains use Guitar Hero-style behavior.
         */
        set('guitarHeroSustains', playState.guitarHeroSustains);

        /**
         * Whether BotPlay is enabled.
         */
        set('botPlay', playState.cpuControlled);

        /**
         * Whether Practice mode is enabled.
         */
        set('practice', playState.practiceMode);

        for (i in 0...4)
        {
            /**
             * Default X position for player strum note ${i}.
             */
            set('defaultPlayerStrumX' + i, 0);

            /**
             * Default Y position for player strum note ${i}.
             */
            set('defaultPlayerStrumY' + i, 0);

            /**
             * Default X position for opponent strum note ${i}.
             */
            set('defaultOpponentStrumX' + i, 0);

            /**
             * Default Y position for opponent strum note ${i}.
             */
            set('defaultOpponentStrumY' + i, 0);
        }

        /**
         * Default X position for the boyfriend character.
         */
        set('defaultBoyfriendX', playState.BF_X);

        /**
         * Default Y position for the boyfriend character.
         */
        set('defaultBoyfriendY', playState.BF_Y);

        /**
         * Default X position for the dad/opponent character.
         */
        set('defaultOpponentX', playState.DAD_X);

        /**
         * Default Y position for the dad/opponent character.
         */
        set('defaultOpponentY', playState.DAD_Y);

        /**
         * Default X position for the girlfriend character.
         */
        set('defaultGirlfriendX', playState.GF_X);

        /**
         * Default Y position for the girlfriend character.
         */
        set('defaultGirlfriendY', playState.GF_Y);

        /**
         * Name of the boyfriend character being used.
         */
        set('boyfriendName', PlayState.SONG.player1);

        /**
         * Name of the dad/opponent character being used.
         */
        set('dadName', PlayState.SONG.player2);

        /**
         * Name of the girlfriend character being used.
         */
        set('gfName', PlayState.SONG.gfVersion);

        /**
         * Alpha multiplier applied to note splashes.
         */
        set('splashAlpha', ClientPrefs.data.splashAlpha);

        /**
         * Build target the engine was compiled for.
         */
        set('buildTarget', CoolUtil.getBuildTarget());

        /**
         * Starts the song countdown sequence.
         */
        set('startCountdown', playState.startCountdown);

        /**
         * Ends the song.
         */
        set('endSong', function()
        {
            playState.KillNotes();

            playState.endSong();
        });

        /**
         * Restarts the song.
         *
         * @note Resets volumes and state, then reloads the PlayState.
         */
        set('restartSong', function()
        {
            playState.paused = true;
            playState.vocals.volume = 0;

            playState.shouldClearMemory = false;

            FlxG.sound.music.volume = 0;
            
            CoolUtil.resetState();
        });

        /**
         * Exits the song to the corresponding menu.
         *
         * @note Chooses Story Menu or Freeplay based on isStoryMode.
         */
        set('exitSong', function()
        {
            playState.vocals.volume = 0;

            PlayState.deathCounter = 0;
            PlayState.seenCutscene = false;

            PlayState.changedDifficulty = false;
            PlayState.chartingMode = false;
            
            playState.paused = true;

            FlxG.sound.playMusic(Paths.music('freakyMenu'));

            CoolUtil.switchState(new CustomState(PlayState.isStoryMode ? CoolVars.data.storyMenuState : CoolVars.data.freeplayState));
        });

        /**
         * Sets the game camera target.
         *
         * @param target Camera target. Can be `gf`/`girlfriend`, `dad`/`opponent`, or `bf`/`boyfriend`.
         */
        set('cameraSetTarget', function(target:String)
        {
			switch(target.trim().toLowerCase())
			{
				case 'gf', 'girlfriend':
					playState.moveCameraToGirlfriend();
				case 'dad', 'opponent':
					playState.moveCamera(true);
				default:
					playState.moveCamera(false);
			}
        });

        /**
         * Triggers an event in the song.
         *
         * @param name Event name.
         * @param arg1 First event argument.
         * @param arg2 Second event argument.
         *
         * @note The event is fired at the current song position.
         */
        set('triggerEvent', function(name:String, arg1:Dynamic, arg2:Dynamic)
        {
			playState.triggerEvent(name, arg1, arg2, Conductor.songPosition);
        });

        /**
         * Executes dance logic on a character.
         *
         * @param character Character to use. Can be `gf`/`girlfriend`, `dad`/`opponent`, or `bf`/`boyfriend`.
         */
        set('characterDance', function(character:String)
        {
			switch (character.toLowerCase())
            {
				case 'dad', 'opponent':
                    playState.dad.dance();
				case 'gf' | 'girlfriend':
                    if (playState.gf != null)
                        playState.gf.dance();
				default:
                    playState.boyfriend.dance();
			}
        });

        /**
         * Performs a tween on a note.
         *
         * @param tag   Tween ID.
         * @param note  Note position in the strumLine.
         * @param props Table of variables to modify.
         * @param time  Tween duration. (optional)
         * @param options Tween options. See https://api.haxeflixel.com/flixel/tweens/TweenOptions.html (optional)
         *
         * @note Stores the tween handle under the provided tag.
         */
        set('noteTween', function(tag:String, note:Int, props:Dynamic, ?time:Float, ?options:Dynamic)
        {
            setTag(tag, LuaPresetUtils.complexTween(lua, tag, playState.strumLineNotes.members[note], props, time, options));
        });

        /**
         * Performs a tween on the `x` variable of a note.
         *
         * @param tag      Tween ID.
         * @param note     Note position in the strumLine.
         * @param value    Variable value.
         * @param duration Tween duration.
         * @param ease     Tween ease.
         *
         * @deprecated Use `noteTween` instead.
         */
        set('noteTweenX', function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)
        {
            deprecatedPrint('Use "noteTween" instead of "noteTweenX"');

            setTag(tag, LuaPresetUtils.complexTween(lua, tag, playState.strumLineNotes.members[note], {x: value}, duration, {ease: ease}));
        });

        /**
         * Performs a tween on the `y` variable of a note.
         *
         * @param tag      Tween ID.
         * @param note     Note position in the strumLine.
         * @param value    Variable value.
         * @param duration Tween duration.
         * @param ease     Tween ease.
         *
         * @deprecated Use `noteTween` instead.
         */
        set('noteTweenY', function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)
        {
            deprecatedPrint('Use "noteTween" instead of "noteTweenY"');

            setTag(tag, LuaPresetUtils.complexTween(lua, tag, playState.strumLineNotes.members[note], {y: value}, duration, {ease: ease}));
        });

        /**
         * Performs a tween on the `angle` variable of a note.
         *
         * @param tag      Tween ID.
         * @param note     Note position in the strumLine.
         * @param value    Variable value.
         * @param duration Tween duration.
         * @param ease     Tween ease.
         *
         * @deprecated Use `noteTween` instead.
         */
        set('noteTweenAngle', function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)
        {
            deprecatedPrint('Use "noteTween" instead of "noteTweenAngle"');

            setTag(tag, LuaPresetUtils.complexTween(lua, tag, playState.strumLineNotes.members[note], {angle: value}, duration, {ease: ease}));
        });

        /**
         * Performs a tween on the `direction` variable of a note.
         *
         * @param tag      Tween ID.
         * @param note     Note position in the strumLine.
         * @param value    Variable value.
         * @param duration Tween duration.
         * @param ease     Tween ease.
         *
         * @deprecated Use `noteTween` instead.
         */
        set('noteTweenDirection', function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)
        {
            deprecatedPrint('Use "noteTween" instead of "noteTweenDirection"');

            setTag(tag, LuaPresetUtils.complexTween(lua, tag, playState.strumLineNotes.members[note], {direction: value}, duration, {ease: ease}));
        });

        /**
         * Performs a tween on the `alpha` variable of a note.
         *
         * @param tag      Tween ID.
         * @param note     Note position in the strumLine.
         * @param value    Variable value.
         * @param duration Tween duration.
         * @param ease     Tween ease.
         *
         * @deprecated Use `noteTween` instead.
         */
        set('noteTweenAlpha', function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)
        {
            deprecatedPrint('Use "noteTween" instead of "noteTweenAlpha"');

            setTag(tag, LuaPresetUtils.complexTween(lua, tag, playState.strumLineNotes.members[note], {alpha: value}, duration, {ease: ease}));
        });
		
        /**
         * Adds an object to the game behind the Girlfriend entity.
         *
         * @param obj Object ID.
         */
        set('addBehindGF', function(obj:String)
        {
            playState.insert(playState.members.indexOf(playState.gfGroup), getTag(obj));
        });
        
        /**
         * Adds an object to the game behind the Boyfriend entity.
         *
         * @param obj Object ID.
         */
        set('addBehindBF', function(obj:String)
        {
            playState.insert(playState.members.indexOf(playState.boyfriendGroup), getTag(obj));
        });
        
        /**
         * Adds an object to the game behind the Dad entity.
         *
         * @param obj Object ID.
         */
        set('addBehindDad', function(obj:String)
        {
            playState.insert(playState.members.indexOf(playState.dadGroup), getTag(obj));
        });

        /**
         * Adjusts on-screen mobile controls to the current PlayState.
         */
        set('adjustMobileControls', function()
        {
            playState.adjustMobileControls();
        });
    }
}
