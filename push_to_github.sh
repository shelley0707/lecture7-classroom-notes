#!/bin/bash
set -e

# Configuration
REPO_NAME="lecture7-classroom-notes"
BRANCH="main"

# Check prerequisites
if ! command -v gh &> /dev/null; then
  echo "Error: GitHub CLI (gh) is not installed. Install it from https://cli.github.com/"
  exit 1
fi

if ! gh auth status &> /dev/null; then
  echo "Error: You are not logged in to GitHub CLI. Run: gh auth login"
  exit 1
fi

# Get GitHub username
USERNAME=$(gh api user -q '.login')
echo "Creating repository: $USERNAME/$REPO_NAME"

# Create public repository (ignore error if it already exists)
gh repo create "$REPO_NAME" --public --source=. --remote=origin --push || true

# Set remote origin just in case
gh repo set-default "$USERNAME/$REPO_NAME"

# Configure git user if not already set
git config user.email "you@example.com" || true
git config user.name "Your Name" || true

# Commit and push
git add index.html README.md
git commit -m "Initial commit: Lecture 7 classroom notes" || true
git push -u origin "$BRANCH"

# Enable GitHub Pages
echo "Enabling GitHub Pages..."
gh api "repos/$USERNAME/$REPO_NAME/pages" \
  --method POST \
  --input - <<EOF
{
  "source": {
    "branch": "$BRANCH",
    "path": "/"
  }
}
EOF

PAGES_URL="https://$USERNAME.github.io/$REPO_NAME/"
echo ""
echo "Done! Your GitHub Pages link is:"
echo "$PAGES_URL"
