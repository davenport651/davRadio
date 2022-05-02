#!/bin/bash
#This script will retrieve the latest newscast from NPR
#requires jq, xq (availalbe through yq with pip or pip3), and wget

#References the NPR top of the hour podcast XML feed: https://www.npr.org/rss/podcast.php?id=500005

newscast=$(curl -s https://feeds.npr.org/500005/podcast.xml | xq -r '.rss.channel.item.enclosure[]' | head -n 1)

#Now do something with it...
#cvlc $newscast
wget -O $HOME/newscast.mp3 $newscast
