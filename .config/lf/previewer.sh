#!/bin/sh
draw() {
  kitty +kitten icat --silent --stdin no --transfer-mode memory --place "${w}x${h}@${x}x${y}" "$1" </dev/null >/dev/tty
  exit 1
}

file="$1"
w="$2"
h="$3"
x="$4"
y="$5"

case "$(file -Lb --mime-type "$file")" in 
  image/*)
    draw "$file"
    ;;
  video/*)
    # Generate (or reuse) an ffmpegthumbnailer preview, then display it with kitty.
    thumbnail="$HOME/.config/lf/vidthumb.sh"
    image=$("$thumbnail" "$file")
    if [ -n "$image" ] && [ -f "$image" ]; then
      draw "$image"
    fi
    ;;
  *.mp4)
    # Some systems report MP4 as application/octet-stream instead of video/mp4.
    thumbnail="$HOME/.config/lf/vidthumb.sh"
    image=$("$thumbnail" "$file")
    if [ -n "$image" ] && [ -f "$image" ]; then
      draw "$image"
    fi
    ;;
esac

pistol "$file"
