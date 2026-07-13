#!/bin/bash
set -e

# Usage: ./push_with_token.sh YOUR_GITHUB_TOKEN
# Example: ./push_with_token.sh ghp_xxxxxxxxxxxx

if [ -z "$1" ]; then
  echo "Usage: $0 <github-personal-access-token>"
  echo "Get a token from: https://github.com/settings/tokens"
  exit 1
fi

TOKEN="$1"
REPO_NAME="lecture7-classroom-notes"
BRANCH="main"

# Get GitHub username
USERNAME=$(curl -s -H "Authorization: token $TOKEN" https://api.github.com/user | python3 -c "import sys, json; print(json.load(sys.stdin).get('login', ''))")

if [ -z "$USERNAME" ]; then
  echo "Error: Could not get GitHub username. Please check your token."
  exit 1
fi

echo "GitHub username: $USERNAME"
echo "Creating repository: $REPO_NAME"

# Create public repository
curl -s -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user/repos \
  -d "{\"name\":\"$REPO_NAME\",\"private\":false,\"auto_init\":false}" > /dev/null

# Set remote and push using token
REMOTE_URL="https://$TOKEN@github.com/$USERNAME/$REPO_NAME.git"
git remote remove origin 2>/dev/null || true
git remote add origin "$REMOTE_URL"

# Configure git user if not set
git config user.email "you@example.com" || true
git config user.name "Your Name" || true

git push -u origin "$BRANCH"

# Enable GitHub Pages
echo "Enabling GitHub Pages..."
curl -s -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -X POST \
  https://api.github.com/repos/$USERNAME/$REPO_NAME/pages \
  -d "{\"source\":{\"branch\":\"$BRANCH\",\"path\":\"/\"}}" > /dev/null

PAGES_URL="https://$USERNAME.github.io/$REPO_NAME/"
echo ""
echo "Done! Your GitHub Pages link is:"
echo "$PAGES_URL"
