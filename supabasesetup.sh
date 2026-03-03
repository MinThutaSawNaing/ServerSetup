#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "🚀 Starting Supabase Docker setup..."

# 1. Check for dependencies
for cmd in git docker; do
    if ! command -v $cmd &> /dev/null; then
        echo "❌ Error: $cmd is not installed. Please install it first."
        exit 1
    fi
done

# 2. Define directory names
REPO_DIR="supabase-temp"
PROJECT_DIR="supabase-project"

# 3. Clean up old temp files if they exist
if [ -d "$REPO_DIR" ]; then
    echo "清理: Removing old temporary repo..."
    rm -rf "$REPO_DIR"
fi

# 4. Clone the repository
echo "📥 Cloning Supabase repository (shallow)..."
git clone --depth 1 https://github.com/supabase/supabase "$REPO_DIR"

# 5. Create project directory
echo "📁 Creating project directory: $PROJECT_DIR"
mkdir -p "$PROJECT_DIR"

# 6. Copy Docker and Env files
echo "📦 Copying configuration files..."
cp -rf "$REPO_DIR/docker/"* "$PROJECT_DIR/"
cp "$REPO_DIR/docker/.env.example" "$PROJECT_DIR/.env"

# 7. Cleanup temp repo
echo "🧹 Cleaning up source files..."
rm -rf "$REPO_DIR"

# 8. Pull Docker images
echo "🐳 Moving to $PROJECT_DIR and pulling images..."
cd "$PROJECT_DIR"

# Check if docker-compose (v1) or docker compose (v2) is available
if docker compose version > /dev/null 2>&1; then
    docker compose pull
    echo -e "\n✅ Success! You can now run: \033[0;32mcd $PROJECT_DIR && docker compose up -d\033[0m"
else
    docker-compose pull
    echo -e "\n✅ Success! You can now run: \033[0;32mcd $PROJECT_DIR && docker-compose up -d\033[0m"
fi
