package funkin.visuals.game;

import core.structures.StageArrayObject;
import core.structures.StageArray;
import core.structures.JsonStage;
import core.structures.JsonStageSprite;
import core.structures.JsonStageGroup;

import utils.Formatter;

import flixel.FlxBasic;

class Stage
{
    var parent:Dynamic;

    public var id:String;
    
    public var config:JsonStage;

    public function new(initial:JsonStage, ?parent:Dynamic)
    {
        config = initial;

        this.parent = parent ?? FlxG.state;
    }

    var current:StageArray;

    var cached:Map<String, StageArray> = new Map<String, StageArray>();

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
        }

        current = cached.get(id);

        cached.remove(id);

        for (obj in current.objects)
            obj.object.exists = switch (obj.quality)
            {
                case 'any':
                    true;

                case 'low':
                    ClientPrefs.data.lowQuality;

                case 'high':
                    !ClientPrefs.data.lowQuality;
            }
        
        this.id = id;

        config = current.config;
    }

    public function cache(id:String)
    {
        if (alreadyCached.contains(id))
            return;

        final json = Formatter.getStage(id);

        if (json == null)
            return;

        final result:StageArray = {
            config: json,
            objects: new Map<String, StageArrayObject>(),
            id: id
        };

        if (json.spritesConfig != null)
        {
            for (object in json.spritesConfig.sprites ?? [])
            {
                final obj:FlxSprite = createSprite(json, object);

                obj.exists = false;

                final addMethod:FlxBasic -> Dynamic = Reflect.getProperty(parent, object.addMethod ?? 'addBehindExtras');

                if (addMethod != null)
                    Reflect.callMethod(parent, addMethod, [obj]);

                result.objects.set(object.id, {
                    object: obj,
                    quality: object.quality ?? ANY
                });
            }

            for (object in json.spritesConfig.groups ?? [])
            {
                final obj:FlxSpriteGroup = createGroup(json, object);

                obj.exists = false;

                final addMethod:FlxBasic -> Dynamic = Reflect.getProperty(parent, object.addMethod ?? 'addBehindExtras');

                if (addMethod != null)
                    Reflect.callMethod(parent, addMethod, [obj]);

                result.objects.set(object.id, {
                    object: obj,
                    quality: object.quality ?? ANY
                });
            }
        }

        cached.set(id, result);

        alreadyCached.push(id);
    }

    function createSprite(json:JsonStage, object:JsonStageSprite):FlxSprite
    {
        object.images ??= [object.id];
        object.type ??= IMAGE;

        final obj:FlxSprite = CoolUtil.spriteFromJson(Type.createInstance(Type.resolveClass(object.classPath ?? Type.getClassName(Bopper)), object.classArguments ?? []), object, 'stages/' + json.spritesConfig.directory + '/');

        if (obj is Bopper)
            cast(obj, Bopper).configBeatHitAnimations();

        CoolUtil.setProperties(obj, json.spritesConfig.properties);

        CoolUtil.setProperties(obj, object.properties);

        obj.updateHitbox();

        if (object.cameras != null)
        {
            obj.cameras = [];

            for (camera in object.cameras)
            {
                final result:Dynamic = Reflect.getProperty(parent, camera);

                if (result != null && result is FlxCamera)
                    obj.cameras.push(result);
            }
        }

        return obj;
    }

    function createGroup(json:JsonStage, object:JsonStageGroup):FlxSpriteGroup
    {
        final obj:FlxSpriteGroup = Type.createInstance(Type.resolveClass(object.classPath ?? Type.getClassName(FlxSpriteGroup)), object.classArguments ?? []);
        
        CoolUtil.setProperties(obj, json.spritesConfig.properties);

        CoolUtil.setProperties(obj, object.properties);

        for (sprite in object.sprites)
            obj.add(createSprite(json, sprite));

        if (object.cameras != null)
        {
            obj.cameras = [];

            for (camera in object.cameras)
            {
                final result:Dynamic = Reflect.getProperty(parent, camera);

                if (result != null && result is FlxCamera)
                    obj.cameras.push(result);
            }
        }

        return obj;
    }

    public function get(id:String):FlxSprite
        return current == null ? null : current.objects.get(id).object;

    public function destroy()
    {
        for (stage in cached)
            if (stage != current)
                for (obj in stage.objects)
                    obj?.object?.destroy();

        cached.clear();

        alreadyCached.resize(0);
    }
}