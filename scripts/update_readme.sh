#!/bin/bash

# Set locale and time zone
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_TIME=en_US.UTF-8

# Generate dynamic content (current date and time in Indian Standard Time)
indian_time=$(date +'%Y-%m-%d %H:%M:%S %Z')

# Get weather details for a specific city (e.g., Mumbai)
city="Coimbatore"
weather_info=$(curl -s "http://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${OPENWEATHERMAP_API_KEY}")

# Extract relevant information from the weather response (customize as needed)
temperature=$(echo $weather_info | jq -r '.main.temp')
condition=$(echo $weather_info | jq -r '.weather[0].description')

# Update README file
echo "# My Project" > README.md
echo -e "\nThis content is dynamically generated in Indian Time (IST): $indian_time" >> README.md
echo -e "Current Weather in $city:\nTemperature: $temperature °C\nCondition: $condition" >> README.md

# Commit changes
git config --local user.email "action@github.com"
git config --local user.name "GitHub Action"
git pull origin main  # Pull the latest changes from the remote repository
git add README.md
git commit -m "Update README with dynamic content"
git push origin main  # Push changes back to the remote repository
