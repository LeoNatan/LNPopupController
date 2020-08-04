#!/bin/bash
set -e

# if [[ -n $(git status --porcelain) ]]; then
#   echo -e >&2 "\033[1;31mCannot release version because there are unstaged changes:\033[0m"
#   git status --short
#   exit -2
# fi
#
# if [[ -n $(git tag --contains $(git rev-parse --verify HEAD)) ]]; then
#   echo -e >&2 "\033[1;31mThe latest commit is already contained in the following releases:\033[0m"
#   git tag --contains $(git rev-parse --verify HEAD)
#   exit -3
# fi
#
# if [[ -n $(git log --branches --not --remotes) ]]; then
#   echo -e "\033[1;34mPushing pending commits to git\033[0m"
#   git push
# fi

CURRENT_VERSION=$(/usr/libexec/PlistBuddy LNPopupController/Info.plist -c "Print CFBundleShortVersionString")
NEXT_VERSION=$(echo "$CURRENT_VERSION" | perl -pe 's/^((\d+\.)*)(-?\d+)(.*)$/$1.($3+1).$4/e')

echo -e "\033[1;34mUsing $NEXT_VERSION as release version\033[0m"

echo -e "\033[1;34mCreating release notes\033[0m"

RELEASE_NOTES_FILE=_tmp_release_notes.md

touch "${RELEASE_NOTES_FILE}"
open -Wn "${RELEASE_NOTES_FILE}"

if ! [ -s "${RELEASE_NOTES_FILE}" ]; then
  echo >&2 "\033[1;31mNo release notes provided, aborting.\033[0m"
  rm -f "${RELEASE_NOTES_FILE}"
  exit -1
fi

#Escape user input in markdown to valid JSON string using PHP 🤦‍♂️ (https://stackoverflow.com/a/13466143/983912)
RELEASENOTESCONTENTS=$(printf '%s' "$(<"${RELEASE_NOTES_FILE}")" | php -r 'echo json_encode(file_get_contents("php://stdin"));')

rm -f "${RELEASE_NOTES_FILE}"

echo -e "\033[1;34mUpdating framework version\033[0m"

/usr/libexec/PlistBuddy LNPopupController/Info.plist -c "Set CFBundleShortVersionString $NEXT_VERSION" -c "Set CFBundleVersion 1"

echo -e "\033[1;34mCommitting all changes to Git for release $NEXT_VERSION\033[0m"

git add -A
git commit -m "$NEXT_VERSION"
git tag "$NEXT_VERSION"

git push
git push --tags

echo -e "\033[1;34mCreating a GitHub release\033[0m"

API_JSON=$(printf '{"tag_name": "%s","target_commitish": "master", "name": "v%s", "body": %s, "draft": false, "prerelease": false}' "$NEXT_VERSION" "$NEXT_VERSION" "$RELEASENOTESCONTENTS")
curl -H 'Authorization: token ${GITHUB_RELEASES_TOKEN}' -s --data "$API_JSON" https://api.github.com/repos/LeoNatan/LNPopupController/releases