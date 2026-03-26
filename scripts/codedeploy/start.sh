#!/bin/bash
pwd
ls -ltr


# CHANGE: Define the deployment directory where CodeDeploy extracts artifacts
DEPLOYMENT_DIR="/opt/codedeploy-agent/deployment-root/${DEPLOYMENT_GROUP_ID}/${DEPLOYMENT_ID}/deployment-archive"

# CHANGE: Use absolute path to JAR file from deployment directory
JAR_FILE="${DEPLOYMENT_DIR}/oltp-0.0.1-SNAPSHOT.jar"

# CHANGE: Verify JAR file exists before attempting to start
if [ ! -f "$JAR_FILE" ]; then
    echo "ERROR: JAR file not found at $JAR_FILE"
    echo "Contents of deployment directory:"
    ls -ltr "$DEPLOYMENT_DIR"
    exit 1
fi

# Start the Spring Boot application detached from the script
chmod +x "$JAR_FILE"
nohup java -jar "$JAR_FILE" > /tmp/output.txt 2>&1 &

# Capture the process ID
APP_PID=$!

# Wait a few seconds for the application to start
sleep 10

# Verify the process is still running
if ps -p $APP_PID > /dev/null; then
    echo "Application started successfully with PID: $APP_PID"
    echo $APP_PID > /tmp/oltp.pid
    exit 0
else
    echo "Application failed to start"
    echo "Check /tmp/output.txt for errors"
    cat /tmp/output.txt
    exit 1
fi
