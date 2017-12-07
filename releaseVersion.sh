#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
	echo >&2 "Illegal number of parameters"
	echo >&2 "releaseVersion.sh <version>"
	exit -1
fi

if [[ -n $(git status --porcelain) ]]; then
	echo >&2 "Cannot release version because there are unstaged changes:"
	git status --short
	exit -2
fi

if [[ -n $(git tag --contains $(git rev-parse --verify HEAD)) ]]; then
	echo >&2 "The latest commit is already contained in the following releases:"
	git tag --contains $(git rev-parse --verify HEAD)
	exit -3
fi

if [[ -n $(git log --branches --not --remotes) ]]; then
	echo "Pushing commits to git"
	git push
fi

echo "Updating CHANGELOG"

github_changelog_generator --future-release "$1" --no-verbose

git add -A
git commit -m "$1"
git tag "$1"

git push
git push --tags