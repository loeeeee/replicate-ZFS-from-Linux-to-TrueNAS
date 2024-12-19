#!/bin/bash

# set -xeuo pipefail # Make people's life easier

# -------------------
# Load env file
# -------------------

# Function to load environment variables from a file
load_env_from_file() {
    local env_file="$1"

    # Check if the file exists and is readable
    if [[ ! -f "$env_file" ]]; then
        echo "Error: Environment file '$env_file' not found." >&2
        return 1
    elif [[ ! -r "$env_file" ]]; then
        echo "Error: Environment file '$env_file' is not readable." >&2
        return 1
    fi
    set -a
    . ./"$env_file"
    set +a
    return 0
}

# Check if an environment file path is provided as an argument
if [[ -z "$1" ]]; then
    echo "Usage: $0 <environment_file_path>" >&2
    exit 1
fi

# Call the function to load the environment variables
if ! load_env_from_file "$1"; then
    exit 1
fi

echo "Environment variables loaded successfully."

# -------------------
# Wake up remote server
# -------------------

wake_on_lan() {
    local mac_address="$1"
    
    # Validate MAC address format
    if [[ ! "$mac_address" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]; then
        echo "Error: Invalid MAC address format. Use XX:XX:XX:XX:XX:XX." >&2
        return 1
    fi

    # Check if wakeonlan is installed
    if ! command -v wakeonlan &> /dev/null; then
        echo "Error: wakeonlan is not installed. Please install it (e.g., 'sudo apt-get install wakeonlan')." >&2
        return 1
    fi

    local i
    for ((i=1; i<=5; i++)); do
        wakeonlan "$mac_address"
        # Spam five times just in case
        sleep 1 # Wait for 1 second before retrying
    done

    return 0
}

# Keep it simple by spamming it
wake_on_lan $wol_mac

wake_server() {
    local attempt=1
    while [[ $attempt -le $ssh_max_attempt_count ]]; do
        echo "Attempt $attempt/$ssh_max_attempt_count: Checking SSH connection to $ssh_user@$ip_address..."

        # Attempt SSH connection with timeout
        timeout "$ssh_timeout" ssh -o StrictHostKeyChecking=no -o ConnectTimeout="$ssh_timeout" "$ssh_user@$ip_address" 'exit 0' > /dev/null 2>&1

        if [[ $? -eq 0 ]]; then
            echo "SSH connection successful! Host $ip_address is up."
            return 0 # Success
        else
            echo "SSH connection failed. Sending Wake-on-LAN packet..."
            wake_on_lan $wol_mac
            sleep 5 # Wait a few seconds before next SSH attempt
        fi
        attempt=$((attempt + 1))
    done

    echo "Failed to establish SSH connection to $ip_address after $max_attempts attempts." >&2
    return 1 # Failure
}

wake_server

# -------------------
# Replication
# -------------------

source .env/bin/activate

zettarepl run --once $zettarepl_config_path

# -------------------
# Shutdown
# -------------------

exit 0