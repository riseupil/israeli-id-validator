#!/bin/bash -e

TAG_TEXT="$@"

echo "tag message: $TAG_TEXT"

VERSION_PREFIX="$((`date +"%Y"` - 2000)).$(date +"%-m")"
OLD_VERSION=`jq -r ".version" < package.json`

echo current version is $OLD_VERSION 

# get branch name - add it to the tag if we're not on master or main
BRANCH=`git branch --show-current`
if [[ "${BRANCH}" == "master" || "${BRANCH}" == "main" ]]; then
  BRANCH=""
else
  BRANCH="-${BRANCH}"
fi  

if [[ ${OLD_VERSION} =~ ${VERSION_PREFIX}.* ]] ; then 
    OLD_COUNTER=`echo ${OLD_VERSION} | sed "s/${VERSION_PREFIX}\.//g" | sed -e "s/-.*$//" `
    VERSION="${VERSION_PREFIX}.$((OLD_COUNTER + 1))"
else
    VERSION="${VERSION_PREFIX}.0"
fi

TAG="${VERSION}${BRANCH}"
echo git tag and versions are: $TAG

npm version ${TAG} -m "Bumping NPM package version to ${TAG}"

# Delete the tag that npm version creates, we don't like the format
git tag -d v${TAG}
git tag -a "$TAG" -m "$TAG_TEXT"  

echo Done! 

