#!/bin/bash
output_file="speed.csv"
url="speedtest.wtnet.de"

if [ ! -f $output_file ]; then
    echo "Time,Download,Upload" > "$output_file"
fi

timestamp=$(date "+%Y-%m-%d %H:%M:%S")
echo "Starting download speed test" >&2
while true; do
    result=$(iperf3  -c $url -p 5200 -P 10 -4 -R 2>&1)
    if [[ "$result" == *"the server is busy"* ]]; then
        echo "Server busy, retrying in 5 seconds..." >&2
        sleep 5
    else
        download_speed=$(echo "$result" | grep "\[SUM\].*receiver" | awk '{print $6}')
        if [[ -n "$download_speed" ]]; then
            echo "Download test complete." >&2
            break
        else
            echo "Download test completed but couldn't parse speed, retrying in 5 seconds..." >&2
            sleep 5
        fi
    fi
done
echo "Starting upload speed test" >&2
while true; do
    result=$(iperf3  -c $url -p 5200 -P 10 -4 2>&1)
    if [[ "$result" == *"the server is busy"* ]]; then
        echo "Server busy, retrying in 5 seconds..." >&2
        sleep 5
    else
        upload_speed=$(echo "$result" | grep "\[SUM\].*sender" | awk '{print $6}')
        if [[ -n "$upload_speed" ]]; then
            echo "Upload test complete." >&2
            break
        else
            echo "Upload test completed but couldn't parse speed, retrying in 5 seconds..." >&2
            sleep 5
        fi
    fi
done
echo "$timestamp,$download_speed,$upload_speed" >> "$output_file"
