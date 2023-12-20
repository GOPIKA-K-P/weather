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

# Generate dynamic content (current date and time in Indian Standard Time)
indian_time=$(date +'%Y-%m-%d %H:%M:%S %Z')

# Get weather details for a specific city (e.g., Mumbai)
city="Coimbatore"
weather_info=$(curl -s "http://api.openweathermap.org/data/2.5/forecast?q=${city}&appid=${OPENWEATHERMAP_API_KEY}")

# Extract relevant information from the weather response (customize as needed)
hourly_data=$(echo $weather_info | jq -r '.list[] | {dt_txt, main: .main, weather: .weather[0]}')

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

# Format hourly weather information
formatted_weather=""
while read -r line; do
    timestamp=$(echo $line | jq -r '.dt_txt')
    temperature_kelvin=$(echo $line | jq -r '.main.temp')
    temperature_celsius=$(kelvin_to_celsius $temperature_kelvin)
    condition=$(echo $line | jq -r '.weather.description')

    # Get weather icon based on weather condition
    weather_icon=$(get_weather_icon "$condition")

    # Add formatted information
    formatted_weather+="| $timestamp | $weather_icon $temperature_celsius °C | $condition |\n"
done <<< "$hourly_data"

# Update README file with the formatted weather information
echo "# Hourly Weather Forecast" > README.md
echo -e "\nThis content is dynamically generated in Indian Time (IST): $indian_time\n" >> README.md
echo -e "| Time | Temperature | Condition |\n| --- | --- | --- |\n$formatted_weather" >> README.md

# Configure Git
git config --global user.email "action@github.com"
git config --global user.name "GitHub Action"

# Commit changes
git add README.md
git commit -m "Update README with hourly weather forecast"

# Pull latest changes from the remote repository
git pull origin main

# Push changes
git push origin main
