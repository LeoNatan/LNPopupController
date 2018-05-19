#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
	echo -e >&2 "\033[1;31mIllegal number of parameters\033[0m"
	echo -e >&2 "\033[1;31mreleaseVersion.sh <version>\033[0m"
	exit -1
fi

if [[ -n $(git status --porcelain) ]]; then
	echo -e >&2 "\033[1;31mCannot release version because there are unstaged changes:\033[0m"
	git status --short
	exit -2
fi

if [[ -n $(git tag --contains $(git rev-parse --verify HEAD)) ]]; then
	echo -e >&2 "\033[1;31mThe latest commit is already contained in the following releases:\033[0m"
	git tag --contains $(git rev-parse --verify HEAD)
	exit -3
fi

if [[ -n $(git log --branches --not --remotes) ]]; then
  echo -e "\033[1;34mPushing pending commits to git\033[0m"
	git push
fi

echo -e "\033[1;34mUpdating CHANGELOG\033[0m"

github_changelog_generator --future-release "$1" --no-verbose
/usr/libexec/PlistBuddy LNPopupController/Info.plist -c "Set CFBundleShortVersionString $1" -c "Set CFBundleVersion 1"

echo -e "\033[1;34mCommitting all changes to Git for release $1\033[0m"

git add -A
git commit -m "$1"
git tag "$1"

git push
git push --tags

echo -e "\033[1;34mCreating a GitHub release\033[0m"

API_JSON=$(printf '{"tag_name": "%s","target_commitish": "master", "name": "v%s", "body": "v%s", "draft": false, "prerelease": false}' "$1" "$1" "$1")
RELEASE_ID=$(curl -s --data "$API_JSON" https://api.github.com/repos/LeoNatan/LNPopupController/releases?access_token=${GITHUB_RELEASES_TOKEN} | jq ".id")