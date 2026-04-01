#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "🚀 Starting Supabase environment setup..."

# 1. Update system and install dependencies for Homebrew
echo "📦 Updating system and installing dependencies..."
sudo apt-get update
sudo apt-get install -y build-essential curl file git

# 2. Install Homebrew (Non-interactive mode)
if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/null
else
    echo "✅ Homebrew is already installed."
fi

# 3. Add Homebrew to PATH for the current session
# This handles the specific pathing for Ubuntu/Debian (on x86_64)
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Add to .bashrc to make it permanent for future sessions
if ! grep -q "shellenv" "$HOME/.bashrc"; then
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.bashrc"
fi

# 4. Create directory and move into it
echo "📂 Creating directory ~/supabasemain..."
mkdir -p "$HOME/supabasemain"
cd "$HOME/supabasemain"

# 5. Install Supabase CLI via Brew
echo "⚡ Installing Supabase CLI..."
brew install supabase/tap/supabase

# 6. Initialize and Start Supabase
echo "🏁 Initializing Supabase..."
supabase init

echo "🔥 Starting Supabase (Debug Mode)..."
# Using --ignore-health-check as requested
supabase start --debug --ignore-health-check

echo "✨ Setup complete! Your Supabase services are starting up."
