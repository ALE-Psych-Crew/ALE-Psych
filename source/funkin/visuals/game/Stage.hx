package funkin.visuals.game;

import utils.Formatter;

import flixel.FlxCamera;
import flixel.FlxBasic;

import funkin.visuals.objects.Bopper;

import core.structures.JsonBopper;
import core.structures.StageArray;
import core.structures.JsonStage;

import haxe.ds.StringMap;

class Stage
{
    var game:PlayState;

    public var config:JsonStage;

    public function new(game:PlayState, ?config:JsonStage)
    {
        this.game = game;

        this.config = config;
    }

    public var id:String;

    var current:StageArray;

    var cached:StringMap<StageArray> = new StringMap();

    var alreadyCached:Array<String> = [];

    public function change(id:String)
    {
        if (current != null && current.id == id)
            return;

        cache(id);
        
        if (!cached.exists(id))
            return;

        if (current != null)
        {
            for (obj in current.objects)
                obj.object.exists = false;

            cached.set(current.id, current);

            current = null;
        }

        current = cached.get(id);

        cached.remove(id);

        for (obj in current.objects)
            obj.object.exists = switch (obj.quality)
                {
                    case ANY:
                        true;
                    case LOW:
                        ClientPrefs.data.lowQuality;
                    case HIGH:
                        !ClientPrefs.data.lowQuality;
                };

        this.id = id;
        
        config = current.config;

        @:privateAccess {
            if (game.characters != null)
                for (char in game.characters)
                    game.resetCharacterPosition(char);
        }

        if (game.camGame is FXCamera)
        {
            final camGame:FXCamera = cast game.camGame;

            camGame.zoom = camGame.targetZoom = config.zoom;
        }
    }

    public function cache(id:String)
    {
        if (alreadyCached.contains(id))
            return;

        final json:JsonStage = Formatter.getStage(id);

        if (json == null)
            return;

        var result:StageArray = {
            config: json,
            objects: new StringMap(),
            id: id
        }

        if (json.spritesConfig != null)
        {
            for (object in json.spritesConfig.sprites)
            {
                final obj:FlxSprite = CoolUtil.spriteFromJson(Type.createInstance(Type.resolveClass(object.classPath ?? Type.getClassName(Bopper)), object.classArguments ?? []), object, 'stages/' + json.spritesConfig.directory + '/');

                if (obj is Bopper)
                {
                    final bop:Bopper = cast obj;
                    final config:JsonBopper = cast bop.config;

                    if (config.bopAnimations != null)
                    {
                        bop.safeBeatHit = (curBeat) -> bop.playAnim(config.bopAnimations[curBeat % config.bopAnimations.length]);

                        bop.safeBeatHit(0);
                    }
                }

                CoolUtil.setProperties(obj, json.spritesConfig.properties);

                CoolUtil.setProperties(obj, object.properties);

                obj.updateHitbox();

                if (object.cameras != null)
                {
                    obj.cameras = [];

                    for (camera in object.cameras)
                    {
                        final result:Dynamic = Reflect.getProperty(game, camera);

                        if (result != null && result is FlxCamera)
                            obj.cameras.push(result);
                    }
                }

                obj.exists = false;

                final addMethod:FlxBasic -> Dynamic = Reflect.getProperty(game, object.addMethod ?? 'addBehindExtras');

                if (addMethod != null)
                    Reflect.callMethod(game, addMethod, [obj]);

                result.objects.set(object.id, {object: obj, quality: object.quality ?? ANY});
            }
        }

        cached.set(id, result);

        alreadyCached.push(id);
    }

    public function get(id:String):FlxSprite
        return current == null ? null : current.objects.get(id).object;

    public function destroy():Void
    {
        if (current != null)
            current = null;

        for (stage in cached)
            if (stage != current)
                for (obj in stage.objects)
                    if (obj.object != null)
                        obj.object.destroy();

        cached.clear();
        alreadyCached.resize(0);

        game = null;
        config = null;
        id = null;
    }
}