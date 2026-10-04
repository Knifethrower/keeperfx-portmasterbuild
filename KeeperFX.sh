#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR=/$directory/ports/keeperfx
BINARY=keeperfx.${DEVICE_ARCH}

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# KeeperFX finds files case-insensitively, so uppercase GOG/CD names work too
if ! ls data | grep -qix 'bluepal.dat' || ! ls sound | grep -qix 'bullfrog.sbk'; then
  pm_message "Original Dungeon Keeper files missing, see README.md (data/*.dat *.pal *.col, sound/*.sbk)"
  sleep 5
  pm_finish
  exit 1
fi

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

pm_platform_helper "$GAMEDIR/$BINARY"

./$BINARY

pm_finish
