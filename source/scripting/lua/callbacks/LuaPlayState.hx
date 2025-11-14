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
        
		set('inChartEditor', false);
        
		set('curBpm', Conductor.bpm);
		set('bpm', PlayState.SONG.bpm);
		set('scrollSpeed', PlayState.SONG.speed);
		set('crochet', Conductor.crochet);
		set('stepCrochet', Conductor.stepCrochet);
		set('songLength', FlxG.sound.music.length);
		set('songName', PlayState.SONG.song);
        
		set('songPath', PlayState.songRoute);

		set('startedCountdown', false);
		set('curStage', PlayState.SONG.stage);

		set('isStoryMode', PlayState.isStoryMode);
		set('difficulty', PlayState.difficulty);
		set('week', PlayState.week);
		set('seenCutscene', PlayState.seenCutscene);
		set('hasVocals', PlayState.SONG.needsVoices);
        
		set('cameraX', 0);
		set('cameraY', 0);

		set('score', 0);
		set('misses', 0);
		set('hits', 0);
		set('combo', 0);

		set('rating', 0);
		set('ratingName', '');
		set('ratingFC', '');

		set('inplayStateOver', false);
		set('mustHitSection', false);
		set('altAnim', false);
		set('gfSection', false);
        
		set('healthGainMult', playState.healthGain);
		set('healthLossMult', playState.healthLoss);

		#if FLX_PITCH
		set('playbackRate', playState.playbackRate);
		#else
		set('playbackRate', 1);
		#end

		set('guitarHeroSustains', playState.guitarHeroSustains);
		set('botPlay', playState.cpuControlled);
		set('practice', playState.practiceMode);

		for (i in 0...4)
		{
			set('defaultPlayerStrumX' + i, 0);
			set('defaultPlayerStrumY' + i, 0);
			set('defaultOpponentStrumX' + i, 0);
			set('defaultOpponentStrumY' + i, 0);
		}
		
		set('defaultBoyfriendX', playState.BF_X);
		set('defaultBoyfriendY', playState.BF_Y);
		set('defaultOpponentX', playState.DAD_X);
		set('defaultOpponentY', playState.DAD_Y);
		set('defaultGirlfriendX', playState.GF_X);
		set('defaultGirlfriendY', playState.GF_Y);
		
		set('boyfriendName', PlayState.SONG.player1);
		set('dadName', PlayState.SONG.player2);
		set('gfName', PlayState.SONG.gfVersion);
		
		set('splashAlpha', ClientPrefs.data.splashAlpha);
		
		set('buildTarget', CoolUtil.getBuildTarget());

        set('startCountdown', playState.startCountdown);

        /**
         * Ends the song
         */
        set('endSong', function()
        {
            playState.KillNotes();

            playState.endSong();
        });

        /**
         * Restarts the song
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
         * Exits the song to the corresponding menu
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
         * Sets the game camera target
         * 
         * @param target Camera target. Can be `gf`/`girlfriend`, `dad`/`opponent` or `bf`/`boyfriend`
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
         * Triggers an event in the song
         * 
         * @param name Event name
         * @param arg1 First event argument
         * @param arg2 Second event argument
         */
        set('triggerEvent', function(name:String, arg1:Dynamic, arg2:Dynamic)
        {
			playState.triggerEvent(name, arg1, arg2, Conductor.songPosition);
        });

        /**
         * Executes dance logic on a character
         * 
         * @param character Character to use. Can be `gf`/`girlfriend`, `dad`/`opponent` or `bf`/`boyfriend`
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
         * Performs a tween on a note
         * 
         * @param tag Tween ID
         * @param note Note position in the strumLine
         * @param props Table of variables to modify
         * @param time Tween duration
         * @param options Tween options. See [TweenOptions](https://api.haxeflixel.com/flixel/tweens/TweenOptions.html)
         */
        set('noteTween', function(tag:String, note:Int, props:Dynamic, ?time:Float, ?options:Dynamic)
        {
            setTag(tag, LuaPresetUtils.complexTween(lua, tag, playState.strumLineNotes.members[note], props, time, options));
        });

        /**
         * Performs a tween on the `x` variable of a note
         * 
         * @param tag Tween ID
         * @param note Note position in the strumLine
         * @param value Variable value
         * @param duration Tween duration
         * @param ease Tween ease
         * 
         * @deprecated Use `noteTween` instead
         */
        set('noteTweenX', function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)
        {
            deprecatedPrint('Use "noteTween" instead of "noteTweenX"');

            setTag(tag, LuaPresetUtils.complexTween(lua, tag, playState.strumLineNotes.members[note], {x: value}, duration, {ease: ease}));
        });

        /**
         * Performs a tween on the `y` variable of a note
         * 
         * @param tag Tween ID
         * @param note Note position in the strumLine
         * @param value Variable value
         * @param duration Tween duration
         * @param ease Tween ease
         * 
         * @deprecated Use `noteTween` instead
         */
        set('noteTweenY', function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)
        {
            deprecatedPrint('Use "noteTween" instead of "noteTweenY"');

            setTag(tag, LuaPresetUtils.complexTween(lua, tag, playState.strumLineNotes.members[note], {y: value}, duration, {ease: ease}));
        });

        /**
         * Performs a tween on the `angle` variable of a note
         * 
         * @param tag Tween ID
         * @param note Note position in the strumLine
         * @param value Variable value
         * @param duration Tween duration
         * @param ease Tween ease
         * 
         * @deprecated Use `noteTween` instead
         */
        set('noteTweenAngle', function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)
        {
            deprecatedPrint('Use "noteTween" instead of "noteTweenAngle"');

            setTag(tag, LuaPresetUtils.complexTween(lua, tag, playState.strumLineNotes.members[note], {angle: value}, duration, {ease: ease}));
        });

        /**
         * Performs a tween on the `direction` variable of a note
         * 
         * @param tag Tween ID
         * @param note Note position in the strumLine
         * @param value Variable value
         * @param duration Tween duration
         * @param ease Tween ease
         * 
         * @deprecated Use `noteTween` instead
         */
        set('noteTweenDirection', function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)
        {
            deprecatedPrint('Use "noteTween" instead of "noteTweenDirection"');

            setTag(tag, LuaPresetUtils.complexTween(lua, tag, playState.strumLineNotes.members[note], {direction: value}, duration, {ease: ease}));
        });

        /**
         * Performs a tween on the `alpha` variable of a note
         * 
         * @param tag Tween ID
         * @param note Note position in the strumLine
         * @param value Variable value
         * @param duration Tween duration
         * @param ease Tween ease
         * 
         * @deprecated Use `noteTween` instead
         */
        set('noteTweenAlpha', function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)
        {
            deprecatedPrint('Use "noteTween" instead of "noteTweenAlpha"');

            setTag(tag, LuaPresetUtils.complexTween(lua, tag, playState.strumLineNotes.members[note], {alpha: value}, duration, {ease: ease}));
        });
		
        /**
         * Adds an object to the game behind the Girlfriend entity
         * 
         * @param obj Object ID
         */
        set('addBehindGF', function(obj:String)
        {
            playState.insert(playState.members.indexOf(playState.gfGroup), getTag(obj));
        });
        
        /**
         * Adds an object to the game behind the Boyfriend entity
         * 
         * @param obj Object ID
         */
        set('addBehindBF', function(obj:String)
        {
            playState.insert(playState.members.indexOf(playState.boyfriendGroup), getTag(obj));
        });
        
        /**
         * Adds an object to the game behind the Dad entity
         * 
         * @param obj Object ID
         */
        set('addBehindDad', function(obj:String)
        {
            playState.insert(playState.members.indexOf(playState.dadGroup), getTag(obj));
        });

        /**
         * 
         */
        set('adjustMobileControls', function()
        {
            playState.adjustMobileControls();
        });
    }
}
