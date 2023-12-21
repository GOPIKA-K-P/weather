#!/bin/bash

# Set locale and time zone
export LC_TIME=en_US.UTF-8
export TZ=Asia/Kolkata

# Function to convert Kelvin to Celsius
kelvin_to_celsius() {
    awk "BEGIN {printf \"%.2f\", $1 - 273.15}"
}

# Function to get weather icon based on weather condition
get_weather_icon() {
    case $1 in
        "Clear")
            echo "☀️"
            ;;
        "Clouds")
            echo "☁️"
            ;;
        "Rain")
            echo "🌧️"
            ;;
        "Snow")
            echo "❄️"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Generate dynamic content (current date and time in Indian Standard Time)
indian_time=$(date +'%Y-%m-%d %H:%M:%S %Z')

# Get weather details for a specific city (e.g., Mumbai)
city="Coimbatore"
weather_info=$(curl -s "http://api.openweathermap.org/data/2.5/forecast?q=${city}&appid=${OPENWEATHERMAP_API_KEY}")

# Extract relevant information for the next 24 hours
next_24_hours_data=$(echo "$weather_info" | jq -r '.list[] | select(.dt_txt | strptime("%Y-%m-%d %H:%M:%S") | mktime >= now and strptime("%Y-%m-%d %H:%M:%S") | mktime <= (now + (24*60*60))) | {dt_txt, main: .main, weather: .weather[0]}')

# Format hourly weather information
formatted_weather=""
while read -r line; do
    timestamp=$(echo $line | jq -r '.dt_txt')
    temperature_kelvin=$(echo $line | jq -r '.main.temp')
    temperature_celsius=$(kelvin_to_celsius "$temperature_kelvin")
    condition=$(echo $line | jq -r '.weather[0].description')

    # Get weather icon based on weather condition
    weather_icon=$(get_weather_icon "$condition")

    # Add formatted information
    formatted_weather+="| $timestamp | $temperature_celsius °C | $weather_icon $condition |\n"
done <<< "$next_24_hours_data"

# Update README file with the formatted weather information
echo "# Weather Forecast for the Next 24 Hours" > README.md
echo -e "\nThis content is dynamically generated in Indian Time (IST): $indian_time\n" >> README.md
echo -e "| Time | Temperature | Condition |\n| --- | --- | --- |\n$formatted_weather" >> README.md

# Commit changes
git add README.md
git commit -m "Update README with weather forecast for the next 24 hours"

# Push changes
git push
