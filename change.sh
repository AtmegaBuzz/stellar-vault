#!/bin/bash

# Set your new author information
NEW_NAME="AtmegaBuzz"
NEW_EMAIL="swapnilshinde9382@gmail.com"

echo "Changing all commits to author: $NEW_NAME <$NEW_EMAIL>"

git filter-branch -f --env-filter "
    export GIT_AUTHOR_NAME='$NEW_NAME'
    export GIT_AUTHOR_EMAIL='$NEW_EMAIL'
    export GIT_COMMITTER_NAME='$NEW_NAME'
    export GIT_COMMITTER_EMAIL='$NEW_EMAIL'
" --tag-name-filter cat -- --branches --tags

echo "Done! All commits now have author: $NEW_NAME <$NEW_EMAIL>"
