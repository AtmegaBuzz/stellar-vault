#!/bin/bash

# Get timestamps
NOW=$(date +%s)
YESTERDAY=$(date -d "1 day ago" +%s)
COMMIT_COUNT=$(git rev-list --count HEAD)

echo "Scattering $COMMIT_COUNT commits between yesterday and now..."

# Generate and sort random timestamps
TIMESTAMPS=()
for ((i=0; i<COMMIT_COUNT-1; i++)); do
    RANDOM_TS=$((YESTERDAY + RANDOM % (NOW - YESTERDAY)))
    TIMESTAMPS+=($RANDOM_TS)
done
TIMESTAMPS+=($NOW)  # Last commit = now

# Sort
IFS=$'\n' TIMESTAMPS=($(sort -n <<<"${TIMESTAMPS[*]}"))
unset IFS

# Convert to git format and store
DATES=()
for ts in "${TIMESTAMPS[@]}"; do
    DATES+=("$(date -d "@$ts" "+%a %b %d %H:%M:%S %Y %z")")
done

# Show what will be applied
echo "Dates to apply:"
for i in "${!DATES[@]}"; do
    echo "  $((i+1)). ${DATES[$i]}"
done

echo -e "\nApplying changes..."

# Apply to all commits
git filter-branch -f --env-filter '
    commit_num=$(git rev-list --reverse HEAD | grep -n "$GIT_COMMIT" | cut -d: -f1)
    idx=$((commit_num - 1))
    
    DATES=('"$(printf '"%s" ' "${DATES[@]}")"')
    DATE="${DATES[$idx]}"
    
    export GIT_AUTHOR_DATE="$DATE"
    export GIT_COMMITTER_DATE="$DATE"
' --tag-name-filter cat -- --all

# Clean up Git's filter-branch backup
rm -rf .git/refs/original
