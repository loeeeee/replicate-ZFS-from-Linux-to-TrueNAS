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

parse_array_from_env() {
    local var_name="$1"
    local array_name="$2"

    # Check if the variable is set
    if [[ -z "${!var_name}" ]]; then
        echo "Warning: Environment variable '$var_name' is not set." >&2
        return 1 # Indicate failure
    fi

    local value="${!var_name}"

    # Use IFS to split the string into an array (colon is the *only* delimiter)
    IFS=":" read -r -a "$array_name" <<< "$value"

    return 0 # Indicate success
}

if parse_array_from_env zettarepl_config_paths zettarepl_config_path_array; then
  echo "Parsed array:"
  for i in "${zettarepl_config_path_array[@]}"; do
    echo "Replication Config File: $i"
    zettarepl run --once $i
  done
fi


exit 0