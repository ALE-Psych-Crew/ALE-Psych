using StringTools;

function onEvent(name:String, v1:String, v2:String)
{
    if (name == 'Change Character')
    {
        switch (v1.toLowerCase().trim())
        {
            case 'dad', 'opponent':
                if (game.dad.curCharacter != v2)
                {
                    if (!game.dadMap.exists(v2))
                        game.addCharacterToList(v2, 1);

                    var wasGF:Bool = game.dad.curCharacter.startsWith('gf-') || game.dad.curCharacter == 'gf';

                    var lastAlpha:Float = game.dad.alpha;

                    game.dad.alpha = 0.00001;
                    game.dad = game.dadMap.get(v2);

                    if (!game.dad.curCharacter.startsWith('gf-') && game.dad.curCharacter != 'gf')
                    {
                        if (wasGF && game.gf != null)
                            game.gf.visible = true;
                    } else if (game.gf != null) {
                        game.gf.visible = false;
                    }

                    game.dad.alpha = lastAlpha;

                    game.iconP2.changeIcon(game.dad.healthIcon);
                }

                game.setOnScripts('dadName', game.dad.curCharacter);

            case 'gf', 'girlfriend':
                if (game.gf != null)
                {
                    if (game.gf.curCharacter != v2)
                    {
                        if (!game.gfMap.exists(v2))
                            game.addCharacterToList(v2, 2);

                        var lastAlpha:Float = game.gf.alpha;

                        game.gf.alpha = 0.00001;
                        game.gf = game.gfMap.get(v2);

                        game.gf.alpha = lastAlpha;
                    }

                    game.setOnScripts('gfName', game.gf.curCharacter);
                }

            default:
                if (game.boyfriend.curCharacter != v2)
                {
                    if (!game.boyfriendMap.exists(v2))
                        game.addCharacterToList(v2, 0);

                    var lastAlpha:Float = game.boyfriend.alpha;

                    game.boyfriend.alpha = 0.00001;
                    game.boyfriend = game.boyfriendMap.get(v2);

                    game.boyfriend.alpha = lastAlpha;

                    game.iconP1.changeIcon(game.boyfriend.healthIcon);
                }

                game.setOnScripts('boyfriendName', game.boyfriend.curCharacter);
        }

        game.reloadHealthBarColors();
    }
}