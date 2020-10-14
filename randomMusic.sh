#!/bin/bash
#This script will play a random file from the directory of the first argument passed

BTMHR='F'

dir=$1

#if $BTMHR is TRUE then $dir = /adverts 
#	and for i in {1 .. 3}; do play advert; done; 
# 	then play weather.wav; change $BTMHR = FALSE
if [ "$BTMHR" = "T" ]; then
	dir='/home/$USER/Downloads/adverts'
	for i in {1 .. 3}; do
		file=$(find $dir -iname '*.ogg' -o -iname '*.mp3' -o -iname '.adx' -o -iname '*.wav' | sort --random-sort | head -1)
		cvlc --play-and-exit "$file"  
	done
	cvlc --play-and-exit "http://woodchuckhunters.com/weather.wav"
fi

#case #if certain hours then change dir to reflect hourly shows
#esac

#Better method...
file=$(find $dir -iname '*.ogg' -o -iname '*.mp3' -o -iname '.adx' -o -iname '*.wav' | sort --random-sort | head -1)

echo "The randomly-selected file is: $file"  # Echo full file path for debugging
echo "The script has been running for $SECONDS seconds" 

#if seconds >= 720 then switch to liner
#if date +%H%M then set $BTMHR = TRUE and 


#in final version, this would be a PLAYER function
#echo $file
echo " "
cvlc --play-and-exit "$file"  #plays the selected file
#gnome-mplayer -q "$file"


