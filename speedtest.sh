#!/bin/bash
output_file="/your/path/speed.csv" #where your results shall be saved
iperf_path="/usr/bin/iperf3" #path to you iperf binary
server="your.server.com" #provided by the hoster of you speedtest server
downloadport="1234" #provided by the hoster of you speedtest server
uploadport="1234" #provided by the hoster of you speedtest server
parallel_streams="10" #10 should be sufficient. Some hosters limit this value to a low number.
ip_version="4" #choose either 4 or 6 here
sleep="30" #wait time between down- and upload test (in seconds). Some servers refuse new connections for a certain amount of time.


if [ ! -f $output_file ]; then
    echo "Time,Download,Upload" > "$output_file"
fi

timestamp=$(date "+%Y-%m-%d %H:%M:%S")
echo "Starting download speed test"
while true; do
    result=$($iperf_path -c $server -p $downloadport -P $parallel_streams -$ip_version -R 2>&1)
    if [[ "$result" == *"the server is busy"* ]]; then
        echo "Server busy, retrying in 5 seconds..."
        sleep 5
    else
        download_speed=$(echo "$result" | grep "\[SUM\].*receiver" | awk '{print $6}')
        if [[ -n "$download_speed" ]]; then
            echo "Download test complete."
            break
        else
            echo "Download test completed but couldn't parse speed, retrying in 5 seconds..."
            sleep 5
        fi
    fi
done
sleep $sleep
echo "Starting upload speed test"
while true; do
    result=$($iperf_path -c $server -p $uploadport -P $parallel_streams -$ip_version 2>&1)
    if [[ "$result" == *"the server is busy"* ]]; then
        echo "Server busy, retrying in 5 seconds..."
        sleep 5
    else
        upload_speed=$(echo "$result" | grep "\[SUM\].*sender" | awk '{print $6}')
        if [[ -n "$upload_speed" ]]; then
            echo "Upload test complete."
            break
        else
            echo "Upload test completed but couldn't parse speed, retrying in 5 seconds..."
            sleep 5
        fi
    fi
done
echo "$timestamp,$download_speed,$upload_speed" >> "$output_file"
