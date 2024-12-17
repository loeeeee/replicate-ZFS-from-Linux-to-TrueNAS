#!/bin/bash

set -xeuo pipefail # Make people's life easier

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
# Create env file if it does not exists
# -------------------

source .env/bin/activate

zettarepl run --once $zettarepl_config_path

exit 0