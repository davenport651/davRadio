#!/bin/bash
# davenport651 - getWeather.sh
# to force an update use "./getWeather.sh force"

# ===== User-configurable variables =====
ENDUSER=$USER
ANNOUNCER="Piper"

TXTWEATHER="/var/www/home.woodchuckhunters.com/weather.txt"
#TXTWEATHER="./weather.txt"
TMPWEATHER="/tmp/weather.txt.tmp"
SNDWEATHER="/var/www/home.woodchuckhunters.com/weather.wav"
#SNDWEATHER="./weather.wav"

# Temp files for JSON data
TMPALERTS="/tmp/alerts.json.tmp"
TMPFORECAST="/tmp/forecast.json.tmp"

# NOAA API endpoints
WEATHERURL="https://api.weather.gov/gridpoints/GRR/79,35/forecast"
ALERTSURL="https://api.weather.gov/alerts/active?point=42.6974,-84.6281"

# ===== Check if update is needed =====
UPDATE_NEEDED=false

if [ "$1" = "force" ]; then
        UPDATE_NEEDED=true
fi

# Check if weather.txt exists and its age
if [ -f "$TXTWEATHER" ]; then
  # Get file age in seconds
  FILE_AGE=$(($(date +%s) - $(stat -c %Y "$TXTWEATHER")))
  FOUR_HOURS=$((2 * 60 * 60))
  
  if [ $FILE_AGE -gt $FOUR_HOURS ]; then
    echo "Weather file is older than 4 hours, updating..."
    UPDATE_NEEDED=true
  fi
else
  echo "Weather file doesn't exist, creating..."
  UPDATE_NEEDED=true
fi

# If file is recent, check for alerts
if [ "$UPDATE_NEEDED" = false ]; then
  #cat ./ALERTS_JSON.txt > "$TMPALERTS"
  curl -s "$ALERTSURL" > "$TMPALERTS"
  ALERT_COUNT=$(jq -r '.features | length' "$TMPALERTS")
  
  if [ "$ALERT_COUNT" -gt 0 ]; then
    echo "Active alerts detected, updating weather..."
    UPDATE_NEEDED=true
  else
    echo "No alerts and weather file is recent. Skipping update."
    exit 0
  fi
fi

# ===== Fetch alerts and forecast =====
# Note: alerts already fetched if checking for updates
if [ ! -f "$TMPALERTS" ]; then
  curl -s "$ALERTSURL" > "$TMPALERTS"
fi
curl -s "$WEATHERURL" > "$TMPFORECAST"

# ===== Process the data with jq =====
jq -r --slurpfile alerts "$TMPALERTS" '
  .properties.periods as $p |
  
  # Check if alerts exist (slurpfile wraps in array, so use $alerts[0])
  ($alerts[0].features // [] | length > 0) as $has_alerts |

  # Intro
  "Here'\''s your forecast from the National Weather Service, compiled by '"$ANNOUNCER"'.",

  # If alerts exist, process ALL of them
  if $has_alerts then
    (
      $alerts[0].features[] | .properties |
      
      # Get NWSheadline
      (.parameters.NWSheadline[0]) as $headline |
      
      # Get description and extract IMPACTS section
      (.description) as $desc |
      (
        if ($desc | contains("IMPACTS...")) then
          ($desc | split("IMPACTS...")[1] | split("\n\n")[0] | gsub("^\\s+|\\s+$"; "") | gsub("\\n"; " "))
        else
          ""
        end
      ) as $impacts |
      
      # Output each alert
      if $impacts != "" then
        "\($headline). \($impacts)"
      else
        "\($headline)."
      end
    ),
    
    # Shortened Today from period 1
    ($p[0] as $today |
    "Today: \($today.shortForecast), with a high near \($today.temperature) degrees.")
  else
    # No alerts - full Today forecast from period 1
    ($p[0] as $today |
    "Today: \($today.detailedForecast)")
  end,

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
' "$TMPFORECAST" > "$TXTWEATHER"

# Broadcast-friendly tweaks
cp "$TXTWEATHER" "$TMPWEATHER"
sed -i "s/mph/miles per hour/g" "$TMPWEATHER"
sed -i "s/Chance of precipitation is/Chance of precipitation/g" "$TMPWEATHER"
sed -i "s/with a/,/g" "$TMPWEATHER"
sed -i "s/ EST//g" "$TMPWEATHER"
cp "$TMPWEATHER" "$TXTWEATHER"

# ===== Convert text to speech using Piper =====
VOICE="/home/$ENDUSER/Downloads/en_US-ryan-medium.onnx"
/home/$ENDUSER/piper/bin/piper -i "$TXTWEATHER" -m "$VOICE" -f "$SNDWEATHER"

# ===== Set ownership =====
chown "$ENDUSER": "$TXTWEATHER"
chown "$ENDUSER": "$SNDWEATHER"

# ===== Cleanup temp files =====
rm -f "$TMPALERTS" "$TMPFORECAST" "$TMPWEATHER"
