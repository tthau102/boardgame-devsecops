#!/bin/bash

# Get current branch
branch=$(git rev-parse --abbrev-ref HEAD)
datenow=$(date +%d/%m/%y-%H:%M:%S)

# Show current status
echo "=== Git Push Script ==="
echo "Branch: $branch"
echo "Commit message: $datenow"
echo ""
echo "Remote repositories:"
git remote -v | grep push

echo ""
if [[ -n "$1" && "$1" == "-y" ]]; then
  confirm="y"
else 
  read -p "Push to all remotes? (y/n): " confirm
  if [[ $confirm != "y" && $confirm != "Y" ]]; then
      echo "Push cancelled"
      exit 0
  fi
fi

echo "------------------------------------------"
# Perform git operations
git add .
git commit -m "$datenow"

# Push to each remote
for remote in $(git remote); do
    echo "------------------------------------------"
    echo ""
    echo "→ Pushing to $remote/$branch..."
    if git push $remote $branch --force; then
        echo "✓ Successfully pushed to $remote/$branch"
    else
        echo "✗ Failed to push to $remote/$branch"
    fi
done

echo ""
echo "=== Push completed ==="