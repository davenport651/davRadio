#!/bin/bash

# ===== User-configurable variables =====
ENDUSER="davenport"
ANNOUNCER="Piper"

#TXTWEATHER="/var/www/home.woodchuckhunters.com/weather.txt"
TXTWEATHER="./weather.txt"
TMPWEATHER="/tmp/weather.txt.tmp"
#SNDWEATHER="/var/www/home.woodchuckhunters.com/weather.wav"
SNDWEATHER="./weather.wav"

# NOAA API endpoint for your location (GRR gridpoint 79,35)
WEATHERURL="https://api.weather.gov/gridpoints/GRR/79,35/forecast"

# ===== Fetch and parse JSON forecast =====
# Requires: jq, curl
curl -s "$WEATHERURL" | jq -r '
  .properties.periods as $p |

  # Intro
  "Here'\''s your forecast from the National Weather Service, compiled by '"$ANNOUNCER"'.",

  # Today: first period whose name matches "Today" (case-insensitive), else first daytime period
  (
    ([$p[] | select(.name | test("Today"; "i"))][0])
    // ([$p[] | select(.isDaytime == true)][0])
  ) as $today
  | "Today: \($today.detailedForecast)",

  # Tonight: first period whose name matches "Tonight", else first nighttime period
  (
    ([$p[] | select(.name | test("Tonight"; "i"))][0])
    // ([$p[] | select(.isDaytime == false)][0])
  ) as $tonight
  | "Tonight: \($tonight.detailedForecast)",

  # 3-day summary: next 3 daytime periods after today
  (
    [$p[] | select(.isDaytime == true)]
    | map("\(.name): \(.shortForecast), highs near \(.temperature) degrees")[1:4]
    | join(". ")
  ) as $summary
  | "Here'\''s the three day outlook: \($summary).",

  # Outro
  "For more information, visit weather dot gov slash G R R."
' > "$TXTWEATHER"

# Broadcast-friendly tweaks
cp "$TXTWEATHER" "$TMPWEATHER"
sed -i "s/mph/miles per hour/g" "$TMPWEATHER"
sed -i "s/Chance of precipitation is/Chance of precipitation/g" "$TMPWEATHER"
sed -i "s/with a/,/g" "$TMPWEATHER"
cp "$TMPWEATHER" "$TXTWEATHER"

# ===== Convert text to speech using Piper =====
/home/marcus/piper/bin/piper -i "$TXTWEATHER" -m /home/marcus/Downloads/en_US-ryan-medium.onnx -f "$SNDWEATHER"

# ===== Set ownership =====
chown "$ENDUSER": "$TXTWEATHER"
chown "$ENDUSER": "$SNDWEATHER"

