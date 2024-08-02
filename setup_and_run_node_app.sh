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

# Function to create a service user
create_service_user() {
    local user="myapp"
    
    echo "Creating service user $user..."
    
    if id "$user" &>/dev/null; then
        echo "User $user already exists."
    else
        sudo useradd -m -s /bin/bash "$user"
        echo "User $user created."
    fi
}

# Function to set environment variables and run the Node.js application as the service user
run_node_app() {
    local dir="bootcamp-node-envvars-project-1.0.0"  # Directory name after extraction
    local user="myapp"
    
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
    sudo -u "$user" npm install

    echo "Starting Node.js application..."
    # Run the Node.js application in the background as the service user
    sudo -u "$user" nohup node server.js > app.log 2>&1 &

    echo "Node.js application started in the background as user $user."
}

# Function to check the application status
check_app_status() {
    echo "Checking if Node.js application is running..."
    
    # Check if the Node.js process is running
    if sudo -u myapp pgrep -f "node server.js" >/dev/null 2>&1; then
        echo "Node.js application is running."

        # Find the port where the application is listening
        # This assumes the app listens on port 3000, adjust as necessary
        local port=$(sudo netstat -tuln | grep -E "3000" | awk '{print $4}' | awk -F: '{print $2}')
        
        if [ -n "$port" ]; then
            echo "The application is listening on port $port."
        else
            echo "Could not determine the port where the application is listening."
        fi

        echo "Running process details:"
        sudo -u myapp ps aux | grep "node server.js" | grep -v grep
    else
        echo "Node.js application is not running."
    fi
}

# Main script execution
install_node
download_and_unzip
create_service_user
run_node_app
check_app_status

