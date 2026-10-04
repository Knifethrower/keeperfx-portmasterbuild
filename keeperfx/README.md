## Notes

KeeperFX is an open-source remake and fan expansion of Dungeon Keeper.
The main goal of KeeperFX is to preserve and expand upon the original Dungeon Keeper experience, offering many new features, improvements, and much more while staying true to the original feeling of the game.
You can delve into the original campaign, or enjoy custom content created by the community and shared on the Workshop.

This port is KeeperFX 1.4.0 (shown as "1.4.0.5136 Portmaster"; the same version number as the Windows release).

## About KeeperFX

Official Website: https://keeperfx.net
GitHub Repository: https://github.com/dkfans/keeperfx
Discord (Keeper Klan): https://discord.gg/hE4p7vy2Hb

## Required files from the original Dungeon Keeper

KeeperFX needs some files from the original game (CD, or a digital release):
http://www.gog.com/en/gamecard/dungeon_keeper
https://www.ea.com/games/dungeon-keeper/dungeon-keeper
https://store.steampowered.com/app/1996630/Dungeon_Keeper_Gold/

Copy these into `ports/keeperfx/data/` (upper or lower case names both work):

    bluepal.dat bluepall.dat dogpal.pal hitpall.dat lightng.pal main.pal mapfadeg.dat
    redpal.col redpall.dat slab0-0.dat slab0-1.dat vampal.pal whitepal.col

and these into `ports/keeperfx/sound/`:

    atmos1.sbk atmos2.sbk bullfrog.sbk

GOG: the files are in the `DATA` and `SOUND` folders of the installed game. The GOG music
(`keeper02.ogg` ... `keeper07.ogg`) can be copied into `ports/keeperfx/music/`.

## Controls

| Button | Action |
|--|--|
|Left stick|Move camera|
|Right stick|Move mouse pointer|
|R2|Left mouse button|
|L2|Right mouse button|
|R1 / L1|Next / previous menu tab, spell in possession|
|D-pad|Snap pointer to buttons|
|A|Shift (speed, best room shape); A + D-pad rotates and zooms|
|B|Control (rotate, square room shape)|
|X|Zoom to fight|
|Y|Zoom to Dungeon Heart|
|L3|Map|
|Select|Finish level|
|Start|Pause menu|
|Start + Select|Exit game|
