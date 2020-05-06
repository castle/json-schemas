#!/bin/bash

# Copies all tagged revisions + HEAD to individual directories

# Base directory
RELEASE_DIR="release"
# File name pattern to include in the release directories
PATTERN="*.json"

# Add wildcard options for GNU tar
if [[ "$(tar --version | head -n 1)" == *GNU* ]];then
  taropt="--wildcards"
fi

tags="HEAD $(git tag | xargs)"
for tag in $tags; do
  dir="$RELEASE_DIR/$(echo -n "$tag" | sed s/HEAD/latest/g)"
  echo "Creating release $tag in $dir"
  mkdir -p "$dir"
  git archive "$tag" | tar -x -C "$dir" ${taropt-} "$PATTERN"
done