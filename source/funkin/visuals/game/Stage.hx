package funkin.visuals.game;

import utils.ALEFormatter;

import flixel.FlxCamera;
import flixel.FlxBasic;

import core.structures.StageArray;
import core.structures.ALEStage;

import haxe.ds.StringMap;

class Stage
{
    var game:PlayState;

    public var data:ALEStage;

    public function new(game:PlayState, ?data:ALEStage)
    {
        this.game = game;

        this.data = data;
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
            obj.object.exists = obj.highQuality ? !ClientPrefs.data.lowQuality : true;

        this.id = id;
        
        data = current.data;

        @:privateAccess {
            if (game.characters != null)
                for (char in game.characters)
                    game.resetCharacterPosition(char);
        }

        if (game.camGame is FXCamera)
        {
            final camGame:FXCamera = cast game.camGame;

            camGame.zoom = camGame.targetZoom = data.zoom;
        }
    }

    public function cache(id:String)
    {
        if (alreadyCached.contains(id))
            return;

        final json:ALEStage = ALEFormatter.getStage(id);

        if (json == null)
            return;

        var result:StageArray = {
            data: json,
            objects: new StringMap(),
            id: id
        }

        if (json.objectsConfig != null)
        {
            for (object in json.objectsConfig.objects)
            {
                final obj:FlxSprite = Type.createInstance(Type.resolveClass(object.classPath ?? 'flixel.FlxSprite'), object.classArguments ?? []);
                
                obj.loadGraphic(Paths.image('stages/' + json.objectsConfig.directory + '/' + (object.path ?? object.id)));

                for (props in [json.objectsConfig.properties, object.properties])
                    if (props != null)
                        CoolUtil.setMultiProperty(obj, props);

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

                obj.updateHitbox();

                final addMethod:FlxBasic -> Dynamic = Reflect.getProperty(game, object.addMethod ?? 'addBehindExtras');

                if (addMethod != null)
                    Reflect.callMethod(game, addMethod, [obj]);

                result.objects.set(object.id, {object: obj, highQuality: object.highQuality ?? false});
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

        cached.clear();
        alreadyCached.resize(0);

        game = null;
        data = null;
        id = null;
    }
}