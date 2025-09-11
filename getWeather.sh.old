#!/bin/bash

#Declare the end user's name here!!!
ENDUSER="user"
ANNOUNCER="Tux"

#Declare variables with paths to files...
TXTWEATHER="/home/$ENDUSER/public_html/weather.txt"
TMPWEATHER="/tmp/weather.txt.tmp"
SNDWEATHER="/home/$ENDUSER/public_html/weather.wav"
#SNDWEATHER="/home/$ENDUSER/public_html/weather.mp3"  #<-- swap these if you're using gtts

WEATHERURL="http://forecast.weather.gov/MapClick.php?lat=42.66630&lon=-84.55366779999997&unit=0&lg=english&FcstType=text&TextType=1"

#Get the raw NWS text forecast...
#new plain weather = https://forecast-v3.weather.gov/point/42.6663,-84.5537?view=plain&mode=min
/usr/bin/w3m -dump $WEATHERURL > $TMPWEATHER
#echo $WEATHERURL > $TMPWEATHER

#Fondle text into readable format...
/bin/echo "Here's your forecast from the National Weather Service, compiled by $ANNOUNCER." > $TXTWEATHER
#Trim away the last 24 lines | Trim away the first 5 lines >> append to $TXTWEATHER
/usr/bin/head -n -45 $TMPWEATHER | /usr/bin/tail -n +92 >> $TXTWEATHER
/bin/echo "For more information, visit weather dot gov slash G, R, R." >> $TXTWEATHER

#Make slight text replacement for broadcastability...
/bin/sed -i "s/mph/miles per hour/" $TXTWEATHER
/bin/sed -i "s/Chance of precipitation is/Chance of precipitation/" $TXTWEATHER
/bin/sed -i "s/with a/,/" $TXTWEATHER

#Debug by enabling these lines
#/bin/cat $TXTWEATHER
#/bin/cp $TXTWEATHER $TMPWEATHER

#Read text into an audio file...
espeak -f $TXTWEATHER -w $SNDWEATHER

#If you have mbrola configured...
#espeak -v mb-en1 --pho -f $TXTWEATHER | mbrola /usr/share/mbrola/en1/en1 - $SNDWEATHER

#IF you pip install gTTS...
#gtts-cli -f $TXTWEATHER -o $SNDWEATHER  #NOTE: output is MP3 not WAV

#If you install and configure piper with voices: https://github.com/rhasspy/piper
#PIPERVOICE="/home/$ENDUSER/Downloads/en_US-ryan-medium.onnx"
#cat $TXTWEATHER | piper -m $PIPERVOICE -f $SNDWEATHER

#convert to .mp3
#lame -h -b 128 ${SNDWEATHER}.wav "${SNDWEATHER}.mp3"
#rm -f ${SNDWEATHER}.wav

#Give end user ownership of the files...
/bin/chown $ENDUSER: $TXTWEATHER
/bin/chown $ENDUSER: $SNDWEATHER

#/usr/bin/clear 
