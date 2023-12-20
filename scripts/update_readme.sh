#!/bin/bash

# Set locale and time zone
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_TIME=en_US.UTF-8
export TZ=Asia/Kolkata

# Function to convert Kelvin to Celsius
kelvin_to_celsius() {
    echo "scale=2; $1 - 273.15" | bc
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
city="Mumbai"
weather_info=$(curl -s "http://api.openweathermap.org/data/2.5/forecast?q=${city}&appid=${OPENWEATHERMAP_API_KEY}")

# Extract relevant information for the whole day
whole_day_data=$(echo "$weather_info" | jq -r '.list[] | select(.dt_txt | strptime("%Y-%m-%d %H:%M:%S") | mktime >= now and strptime("%Y-%m-%d %H:%M:%S") | mktime <= (now + (24*60*60))) | {dt_txt, main: .main, weather: .weather[0]}')

# Format hourly weather information
formatted_weather=""
while read -r line; do
    timestamp=$(echo $line | jq -r '.dt_txt')
    temperature_kelvin=$(echo $line | jq -r '.main.temp')
    temperature_celsius=$(kelvin_to_celsius "$temperature_kelvin")
    condition=$(echo $line | jq -r '.weather.description')

    # Get weather icon based on weather condition
    weather_icon=$(get_weather_icon "$condition")

    # Add formatted information
    formatted_weather+="| $timestamp | $temperature_celsius °C | $weather_icon $condition |\n"
done <<< "$whole_day_data"

# Update README file with the formatted weather information
echo "# Weather Forecast for the Whole Day" > README.md
echo -e "\nThis content is dynamically generated in Indian Time (IST): $indian_time\n" >> README.md
echo -e "| Time | Temperature | Condition |\n| --- | --- | --- |\n$formatted_weather" >> README.md

# Configure Git
git config --global user.email "action@github.com"
git config --global user.name "GitHub Action"

# Commit changes
git add README.md
git commit -m "Update README with weather forecast for the whole day"

# Pull latest changes from the remote repository
git pull origin main

# Push changes
git push origin main
