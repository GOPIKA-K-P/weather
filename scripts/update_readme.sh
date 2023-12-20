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

city="Coimbatore"
weather_info=$(curl -s "http://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${OPENWEATHERMAP_API_KEY}")

# Extract relevant information from the weather response (customize as needed)
temperature_kelvin=$(echo $weather_info | jq -r '.main.temp')
temperature_celsius=$(kelvin_to_celsius $temperature_kelvin)
condition=$(echo $weather_info | jq -r '.weather[0].description')

# Update README file
echo "# My Project" > README.md
echo -e "\nThis content is dynamically generated in Indian Time (IST): $indian_time\n" >> README.md
echo -e "Current Weather in $city:\nTemperature: $temperature_celsius °C\nCondition: $condition" >> README.md

# Configure Git
git config --global user.email "action@github.com"
git config --global user.name "GitHub Action"

# Commit changes
git add README.md
git commit -m "Update README with dynamic content"

# Pull latest changes from the remote repository
git pull origin main

# Push changes
git push origin main
