#!/bin/bash

# Function to check and install Node.js and npm
install_node() {
    echo "Checking for Node.js and npm..."
    
    if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
        echo "Node.js and npm are already installed."
        echo "Node.js version: $(node -v)"
        echo "npm version: $(npm -v)"
    else
        echo "Node.js and npm not found. Installing..."
        # Install Node.js (this example uses NodeSource for Node.js 18.x)
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs

        echo "Node.js version: $(node -v)"
        echo "npm version: $(npm -v)"
    fi
}

# Function to download and unzip the artifact
download_and_unzip() {
    local url="https://node-envvars-artifact.s3.euwest-2.amazonaws.com/bootcamp-node-envvars-project-1.0.0.tgz"
    local filename="bootcamp-node-envvars-project-1.0.0.tgz"
    
    echo "Downloading artifact from $url..."
    curl -O "$url"  # Use curl to download the file

    echo "Unzipping the downloaded file..."
    tar -xzf "$filename"  # Unzip the .tgz file
}

# Function to set environment variables and run the Node.js application
run_node_app() {
    local dir="bootcamp-node-envvars-project-1.0.0"  # Directory name after extraction

    echo "Setting environment variables..."
    export APP_ENV=dev
    export DB_USER=myuser
    export DB_PWD=mysecret

    if [ -z "$APP_ENV" ] || [ -z "$DB_USER" ] || [ -z "$DB_PWD" ]; then
        echo "Environment variables not set properly. Exiting."
        exit 1
    fi

    echo "Changing to project directory..."
    cd "$dir" || { echo "Directory $dir does not exist. Exiting."; exit 1; }

    echo "Installing Node.js dependencies..."
    npm install

    echo "Starting Node.js application..."
    # Run the Node.js application in the background
    nohup node server.js > app.log 2>&1 &

    echo "Node.js application started in the background."
}

# Main script execution
install_node
download_and_unzip
run_node_app

