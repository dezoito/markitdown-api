#!/bin/bash

# Script to build and push markitdown-api to GitHub Container Registry

set -e  # Exit on error

GITHUB_USERNAME="dezoito"
IMAGE_NAME="markitdown-api"

# Get MarkItDown version from requirements.txt
echo "Reading MarkItDown version from requirements.txt..."
MARKITDOWN_VERSION=$(grep "^markitdown" requirements.txt | sed 's/.*==\([0-9.]*\).*/\1/')

if [ -z "$MARKITDOWN_VERSION" ]; then
    echo "Error: Could not extract MarkItDown version from requirements.txt"
    exit 1
fi

echo "MarkItDown version: $MARKITDOWN_VERSION"
echo ""

# Prompt for GitHub credentials
echo "GitHub Container Registry Login"
read -p "GitHub Username: " GH_USER
read -sp "GitHub Personal Access Token (with write:packages scope): " GH_TOKEN
echo ""
echo ""

# Login to GitHub Container Registry
echo "Logging in to ghcr.io..."
echo "$GH_TOKEN" | docker login ghcr.io -u "$GH_USER" --password-stdin

if [ $? -ne 0 ]; then
    echo "Login failed"
    exit 1
fi

echo "Login successful"
echo ""

# Build and tag the image
echo "Building Docker image..."
docker build -t ghcr.io/$GITHUB_USERNAME/$IMAGE_NAME:latest \
             -t ghcr.io/$GITHUB_USERNAME/$IMAGE_NAME:$MARKITDOWN_VERSION .

if [ $? -ne 0 ]; then
    echo "Build failed"
    exit 1
fi

echo "Build successful"
echo ""

# Push both tags
echo "Pushing images to ghcr.io..."
echo "   - ghcr.io/$GITHUB_USERNAME/$IMAGE_NAME:latest"
echo "   - ghcr.io/$GITHUB_USERNAME/$IMAGE_NAME:$MARKITDOWN_VERSION"
docker push ghcr.io/$GITHUB_USERNAME/$IMAGE_NAME:latest
docker push ghcr.io/$GITHUB_USERNAME/$IMAGE_NAME:$MARKITDOWN_VERSION

if [ $? -ne 0 ]; then
    echo "Push failed"
    exit 1
fi

echo ""
echo "Successfully pushed images!"
echo ""
echo "Images available at:"
echo "   ghcr.io/$GITHUB_USERNAME/$IMAGE_NAME:latest"
echo "   ghcr.io/$GITHUB_USERNAME/$IMAGE_NAME:$MARKITDOWN_VERSION"
echo ""
echo "To make the package public, visit:"
echo "   https://github.com/users/$GITHUB_USERNAME/packages/container/$IMAGE_NAME/settings"
