#!/bin/bash

set -e  # Exit script on error

# Function to read user input
read_input() {
    local prompt_message=$1
    local user_input
    read -p "$prompt_message: " user_input
    echo "$user_input"
}

# Ask user if they have a GitHub repository
HAS_GIT_REPO=$(read_input "Do you have a GitHub repository? (yes/no)")

if [[ "$HAS_GIT_REPO" == "yes" ]]; then
    GIT_REPO=$(read_input "Enter your GitHub repository URL (e.g., https://github.com/user/repo.git)")
    BRANCH=$(read_input "Enter the branch name to clone (default: main)")
    APP_DIR=$(read_input "Enter the directory name to store your app (e.g., /var/www/myapp)")
    
    BRANCH=${BRANCH:-main}  # Default to 'main' if empty
    
    echo "Cloning repository..."
    if [ ! -d "$APP_DIR" ]; then
        git clone -b "$BRANCH" "$GIT_REPO" "$APP_DIR"
    else
        echo "Directory already exists. Pulling latest changes..."
        cd "$APP_DIR"
        git pull origin "$BRANCH"
    fi
else
    APP_DIR=$(read_input "Enter the absolute path of your existing project directory")
fi

echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "Installing required dependencies..."
sudo apt install -y curl git build-essential 

# Install NVM if not installed
echo "Checking for NVM installation..."
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
    source "$HOME/.bashrc"
    source "$HOME/.profile"
    source "$HOME/.nvm/nvm.sh"
else
    echo "NVM is already installed."
fi

# Install Node.js
echo "Installing Node.js version $NODE_VERSION..."
source "$HOME/.nvm/nvm.sh"
nvm install "$NODE_VERSION"
nvm use "$NODE_VERSION"
nvm alias default "$NODE_VERSION"

# Navigate to project directory
cd "$APP_DIR"

# Detect frontend/backend structure
if [ -d "client" ] && [ -d "server" ]; then
    echo "Frontend and backend detected."

    # Backend setup
    echo "Setting up backend..."
    cd server
    if [ -f "package.json" ]; then
        npm install
        echo "Starting backend server..."
        npm start &
    fi
    cd ..

    # Frontend setup
    echo "Setting up frontend..."
    cd client
    if [ -f "package.json" ]; then
        npm install
        npm run build
        echo "Frontend build completed."
    fi
    cd ..

elif [ -d "server" ]; then
    echo "Only backend detected."
    cd server
    if [ -f "package.json" ]; then
        npm install
        echo "Starting backend server..."
        npm start &
    fi
    cd ..

elif [ -d "client" ]; then
    echo "Only frontend detected."
    cd client
    if [ -f "package.json" ]; then
        npm install
        npm run build
        echo "Frontend build completed."
    fi
    cd ..

else
    echo "No structured frontend/backend found, checking for package.json..."
    
    if [ -f "package.json" ]; then
        echo "package.json found in root directory."
        npm install
        npm run build || echo "Skipping build step."
        npm start &
    else
        echo "No package.json found, skipping setup."
    fi
fi

echo "Setup complete! 🚀"

