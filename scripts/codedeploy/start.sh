#!/bin/bash

# Start the Spring Boot application detached from the script
nohup java -jar /tmp/oltp-0.0.1-SNAPSHOT.jar > /tmp/output.txt 2>&1 &

# Capture the process ID
APP_PID=$!

# Wait a few seconds for the application to start
sleep 5

# Verify the process is still running
if ps -p $APP_PID > /dev/null; then
    echo "Application started successfully with PID: $APP_PID"
    echo $APP_PID > /tmp/oltp.pid
    exit 0
else
    echo "Application failed to start"
    exit 1
fi
