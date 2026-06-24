package funkin.visuals.game;

import core.structures.StageArrayObject;
import core.structures.StageArray;
import core.structures.JsonStage;

import utils.Formatter;

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

        for (obj in current.objects)
        {
            obj.object.exists = switch (obj.quality)
            {
                case 'any':
                    true;

                case 'low':
                    ClientPrefs.data.lowQuality;

                case 'high':
                    !ClientPrefs.data.lowQuality;
            }
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

        cached.set(id, result);

        alreadyCached.push(id);
    }

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