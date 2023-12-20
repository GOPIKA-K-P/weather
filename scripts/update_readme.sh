#!/bin/bash

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_TIME=en_US.UTF-8
export TZ=Asia/Kolkata


indian_time=$(date +'%Y-%m-%d %H:%M:%S %Z')

city="Coimbatore"
weather_info=$(curl -s "http://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${OPENWEATHERMAP_API_KEY}")


temperature=$(echo $weather_info | jq -r '.main.temp')
condition=$(echo $weather_info | jq -r '.weather[0].description')


echo "# My Project" > README.md
echo -e "\nThis content is dynamically generated in Indian Time (IST): $indian_time" >> README.md
echo -e "Current Weather in $city:\nTemperature: $temperature °C\nCondition: $condition" >> README.md


git config --local user.email "action@github.com"
git config --local user.name "GitHub Action"
git pull origin main  
git add README.md
git commit -m "Update README with dynamic content"
git push origin main  
