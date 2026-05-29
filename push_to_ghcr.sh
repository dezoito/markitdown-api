#!/bin/bash

# Script to build and push markitdown-api to GitHub Container Registry

set -e  # Exit on error

GITHUB_USERNAME="dezoito"
IMAGE_NAME="markitdown-api"

# Determine the release version used for the image tags.
# Default to the exact git tag on the current commit (e.g. 0.1.5-1);
# press Enter to accept it, or type a different value to override.
DEFAULT_VERSION=$(git describe --tags --exact-match HEAD 2>/dev/null)

if [ -n "$DEFAULT_VERSION" ]; then
    echo "Found git tag on current commit: $DEFAULT_VERSION"
else
    echo "No git tag found on the current commit."
fi

read -p "Version to tag [${DEFAULT_VERSION}]: " VERSION
VERSION="${VERSION:-$DEFAULT_VERSION}"

if [ -z "$VERSION" ]; then
    echo "Error: No version provided."
    exit 1
fi

echo "Release version: $VERSION"
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
             -t ghcr.io/$GITHUB_USERNAME/$IMAGE_NAME:$VERSION .

if [ $? -ne 0 ]; then
    echo "Build failed"
    exit 1
fi

echo "Build successful"
echo ""

# Push both tags
echo "Pushing images to ghcr.io..."
echo "   - ghcr.io/$GITHUB_USERNAME/$IMAGE_NAME:latest"
echo "   - ghcr.io/$GITHUB_USERNAME/$IMAGE_NAME:$VERSION"
docker push ghcr.io/$GITHUB_USERNAME/$IMAGE_NAME:latest
docker push ghcr.io/$GITHUB_USERNAME/$IMAGE_NAME:$VERSION

if [ $? -ne 0 ]; then
    echo "Push failed"
    exit 1
fi

echo ""
echo "Successfully pushed images!"
echo ""
echo "Images available at:"
echo "   ghcr.io/$GITHUB_USERNAME/$IMAGE_NAME:latest"
echo "   ghcr.io/$GITHUB_USERNAME/$IMAGE_NAME:$VERSION"
echo ""
echo "To make the package public, visit:"
echo "   https://github.com/users/$GITHUB_USERNAME/packages/container/$IMAGE_NAME/settings"
