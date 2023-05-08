#!/bin/sh


xmodmap ~/.config/.Xmodmap &
xrdb ~/.config/.Xresources &
xset r rate 200 20 &
nm-applet &
picom &
/usr/bin/lxpolkit &
/usr/lib/kdeconnectd &
mpd &
sxhkd &
#dunst &
flameshot &
udiskie &
~/.fehbg &

#xrandr --setprovideroutputsource modesetting NVIDIA-0
#xrandr --auto
#exec awesome # awesomewm
#exec gnome-session

