#!/bin/zsh -e

FIRST_YEAR="$(git log --reverse --date="format:%Y" --format="format:%ad" | head -n 1)"
YEAR=`date +'%Y'`
if [[ "$YEAR" == "$FIRST_YEAR" ]]; then
YEAR_HEADER="$YEAR"
else
YEAR_HEADER="$FIRST_YEAR-$YEAR"
fi
git grep -l -E "(\/\/  Copyright © )([0-9]*(\s*-\s*[0-9]+){0,1})( L(e|é)o\ Natan(\ \(Wix\))*\. All rights reserved\.)" | while read -r FILE ; do
	echo $FILE
	FILE_DATE="$(git log --diff-filter=A --follow --format=%as -- $FILE | tail -1)"
	gsed -i -re "s/(\/\/  Copyright © )([0-9]*(\s*-\s*[0-9]+){0,1})\ (L(e|é)o\ Natan)(\. All rights reserved\.)/\1$YEAR_HEADER\ Léo\ Natan\6/" "${FILE}" -e "s/L(e|é)o\ Natan(\ \(Wix\))*/Léo\ Natan/" -e "s/(\/\/  Created by L(e|é)o\ Natan(\ \(Wix\))*\ on\ ).*/\1$FILE_DATE\./"
#	
done