#!/bin/bash

# Copies all tagged revisions + HEAD to individual directories

# Base directory
RELEASE_DIR="release"

# tag for HEAD version
HEAD_TAG='HEAD'
HEAD_DIR='master'

# alias for latest version
LATEST_DIR='latest'

# File name pattern to include in the release directories
PATTERN="*.json"

# Replace in-file version with tag
REGEX_PREFIX="castle\.io\/schemas\/"
REGEX_PATTERN="{{version}}"

# Add wildcard options for GNU tar
if [[ "$(tar --version | head -n 1)" == *GNU* ]];then
  taropt="--wildcards"
else
  sedopt=".orig"
fi

tags="${HEAD_TAG} $(git tag)"
latest=$(git tag | tail -1)

for tag in $tags; do
  dir="${RELEASE_DIR}/$(echo -n "$tag" | sed s/${HEAD_TAG}/${HEAD_DIR}/g)"
  ver=$(echo -n "$tag" | sed s/${HEAD_TAG}/${HEAD_DIR}/g)
  echo -n "Building release $tag in $dir... "
  mkdir -p "$dir"
  git archive "$tag" | tar -x -C "$dir" ${taropt-} "$PATTERN"
  find $dir -type f -name '*.json' -exec sed -i${sedopt-} "s/${REGEX_PREFIX}${REGEX_PATTERN}/${REGEX_PREFIX}${ver}/g" {} \;

  # Error if replacement failed
  if grep -qr --include='*.json' "${REGEX_PREFIX}${ver}" $dir; then
    echo "Done"
  else
    echo "Failed!"
    exit 1
  fi
done

if [ -n "$latest" ]; then
  echo "Copying ${latest-} to $RELEASE_DIR/$LATEST_DIR"
  cp -r "${RELEASE_DIR}/${latest}" "${RELEASE_DIR}/${LATEST_DIR}"
fi
