#!/usr/bin/env bash
set -e

USAGE=$(cat << EOF
Usage:
$0 <save|load> [savename] -- save/load window layout with optional savename
$0 list                   -- list saves available to load
$0 -h|--help              -- show this usage message
EOF
)

if [[ $# -lt 1 ]]; then
  echo "$USAGE"
  exit 1
fi
mode="$1"
shift

savename="default"
if [[ $# -ge 1 ]]; then
  savename="$1"
  shift
fi

SAVEPATH="/tmp/.window-layout-${USER}/"

save_layout () {
  local savename="$1"
  mkdir -p "${SAVEPATH}"
  rm -f "${SAVEPATH}/${savename}"

  wmctrl -p -G -l | awk '($2 != -1)&&($3 != 0)&&($NF != "Desktop")' | while read window_info; do
    # ID Desktop PID X Y Width Height Host? Title
    echo $window_info
    id="$(echo $window_info | awk '{print $1}')"
    title="$(echo $window_info | awk '{print substr($0, index($0, $9))}')"

    # Get desktop, x, y, width, and height info
    desktop="$(echo $window_info | awk '{print $2}')"
    x="$(echo $window_info | awk '{print $4}')"
    y="$(echo $window_info | awk '{print $5}')"
    width="$(echo $window_info | awk '{print $6}')"
    height="$(echo $window_info | awk '{print $7}')"

    # Save info to a line in our save file
    echo "$id $desktop $x $y $width $height '$title'" >> "${SAVEPATH}/${savename}"
  done
}

load_layout () {
  local savename="$1"
  cat "${SAVEPATH}/${savename}" | while read window_info; do
    echo $window_info
    # Read info from a line in our save file
    id="$(echo $window_info | cut --delimiter ' ' --fields 1)"
    desktop="$(echo $window_info | cut --delimiter ' ' --fields 2)"
    x="$(echo $window_info | cut --delimiter ' ' --fields 3)"
    y="$(echo $window_info | cut --delimiter ' ' --fields 4)"
    width="$(echo $window_info | cut --delimiter ' ' --fields 5)"
    height="$(echo $window_info | cut --delimiter ' ' --fields 6)"
    title="$(echo $window_info | awk '{print substr($0, index($0, $7))}')"

    if ! xwininfo -id $id > /dev/null ; then
      echo ""
      echo "WARN: Error getting window properties. It might not exist. Continuing with next item."
      continue
    fi

    # Most programs need x,y adjusted by window decoration amounts.
    # The only relationship I can find is that windows with northwest gravity
    # as reported by xprop (but not by xwininfo) are offset, whereas windows
    # with static gravity are not. I haven't observed other gravities.
    # Some windows (chrome) aren't set at all, and the default is northwest.
    # GTK windows do not give decoration information and do not need adjusted.
    properties="$(xprop WM_NORMAL_HINTS -id $id)"
    # ^ does not exist w/ chrome!?!?
    net_frame_extents="$(xprop _NET_FRAME_EXTENTS -id $id)"
    if [[ ! "${net_frame_extents}" =~ "not found" ]] && \
       ( [[ ! "$properties" =~ "window gravity:" ]] || \
         [[ "$properties" =~ "window gravity: NorthWest" ]] ) ; then
      # Get window decorations
      decoration="$(echo "$net_frame_extents" | cut --delimiter '=' --fields 2 | tr --delete ' ')"
      decor_left="$(echo $decoration | cut --delimiter ',' --fields 1)"
      # decor_right="$(echo $decoration | cut --delimiter ',' --fields 2)"
      decor_top="$(echo $decoration | cut --delimiter ',' --fields 3)"
      # decor_bottom="$(echo $decoration | cut --delimiter ',' --fields 4)"
      x=$(($x - $decor_left))
      y=$(($y - $decor_top))
      echo "New x,y computed: $x, $y"
    fi

    # Set position and desktop for each window ID
    wmctrl -i -r "$id" -e "0,$x,$y,$width,$height"
    wmctrl -i -r "$id" -t "$desktop"
  done
}

list_saves () {
  echo ""
  ls "${SAVEPATH}"
}

mkdir -p "${SAVEPATH}"

case $mode in
  save)
  save_layout "$savename"
  ;;
  load)
  load_layout "$savename"
  ;;
  list)
  list_saves
  ;;
  -h|--help)
  echo "$USAGE"
  ;;
  *)
  echo "ERR: invalid mode '$mode'"
  echo "$USAGE"
  exit 2
  ;;
esac