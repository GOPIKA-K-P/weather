#!/bin/bash

export LC_TIME=en_US.UTF-8
export TZ=Asia/Kolkata

kelvin_to_celsius() {
    temperature_kelvin=$1
    temperature_celsius=$(echo "$temperature_kelvin - 273.15" | bc)
    printf "%.2f" "$temperature_celsius"
}

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

indian_time=$(TZ=Asia/Kolkata date +'%Y-%m-%d %H:%M:%S %Z')


city="Coimbatore"
weather_info=$(curl -s "http://api.openweathermap.org/data/2.5/forecast?q=${city}&appid=${OPENWEATHERMAP_API_KEY}")


next_24_hours_data=$(echo "$weather_info" | jq -r '.list[] | select(.dt_txt | strptime("%Y-%m-%d %H:%M:%S") | mktime >= now and strptime("%Y-%m-%d %H:%M:%S") | mktime <= (now + (24*60*60))) | {dt_txt, main: .main, weather: .weather[0]}')

formatted_weather=""
while read -r line; do
    timestamp=$(echo $line | jq -r '.dt_txt')
    temperature_kelvin=$(echo $line | jq -r '.main.temp')
    temperature_celsius=$(kelvin_to_celsius "$temperature_kelvin")
    condition=$(echo $line | jq -r '.weather[0].description')

    weather_icon=$(get_weather_icon "$condition")

    formatted_weather+="| $timestamp | $temperature_celsius °C | $weather_icon $condition |\n"
done <<< "$next_24_hours_data"

echo "# Weather Forecast for the Next 24 Hours" > README.md
echo -e "\nThis content is dynamically generated in Indian Time (IST): $indian_time\n" >> README.md
echo -e "| Time | Temperature | Condition |\n| --- | --- | --- |\n$formatted_weather" >> README.md

git add README.md
git commit -m "Update README with weather forecast for the next 24 hours"
git push
