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

# Sourcing controlfolders
source $controlfolder/control.txt 
#source $controlfolder/device_info.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR=/$directory/ports/emby/
CONFDIR="$GAMEDIR/"
cd $GAMEDIR

# Log the execution of the script, the script overwrites itself on each launch
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"
# Pull the screen dimensions from environment variables
export SCREEN_WIDTH=$DISPLAY_WIDTH
export SCREEN_HEIGHT=$DISPLAY_HEIGHT

mpv $GAMEDIR/emby.webm &> /dev/null

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "mcli" -c ./mcli.gptk &
./mcli -e /roms/ports/emby/emby 

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
if [ -f /tmp/mreader.rom ]; then
    ROM="$(cat /tmp/mreader.rom)"
    rm /tmp/mreader.rom
    /roms/ports/mReader/ext-mreader.sh "Book" "landscape.gptk" "$ROM"
fi
printf "\033c" > /dev/tty0