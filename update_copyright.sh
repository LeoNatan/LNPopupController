#!/bin/zsh

# Parse arguments
STAGED_ONLY=0
stashed=0  # Initialize stashed variable
if [[ $# -gt 0 && $1 -eq 1 ]]; then
  STAGED_ONLY=1
  echo "Processing only files staged for commit and auto-staging header changes"
fi

# Configuration - Change this value to your preferred range separator
# Options: "-" (hyphen), "–" (en dash), "—" (em dash), etc.
RANGE_SEPARATOR="-"

# Author configuration
STANDARDIZED_AUTHOR="Léo Natan"
# This regex matches "Leo" or "Léo" followed by "Natan", optionally followed by anything in parentheses
AUTHOR_REGEX="L[eé]o Natan(\s*\([^)]*\))?"

# Get the earliest commit year and current year for the copyright range
earliest_year=$(git log --reverse --format=%ad --date=format:%Y 2>/dev/null | head -1)
if [[ -z "$earliest_year" ]]; then
  # Fallback if git history isn't available
  earliest_year=$(date +%Y)
fi
current_year=$(date +%Y)

# Use single year if project started in current year
if [[ "$earliest_year" == "$current_year" ]]; then
  copyright_range="${current_year}"
else
  copyright_range="${earliest_year}${RANGE_SEPARATOR}${current_year}"
fi

echo "Using copyright year(s): $copyright_range"
echo "Standardizing author name to: $STANDARDIZED_AUTHOR"

# Get list of files to process
if [[ $STAGED_ONLY -eq 1 ]]; then
  # Only process files staged for commit
  files_to_process=$(git diff --cached --name-only)
else
  # Process all files in the repository
  files_to_process=$(git ls-files)
fi

# Track modified files
modified_files=()

# Process each file in the list
echo "$files_to_process" | while read -r file; do
    # Skip empty lines or non-existent files
    [[ -z "$file" || ! -e "$file" ]] && continue
    
    # Skip symbolic links
    [[ -L "$file" ]] && continue
    
    # Skip binary files and empty files
    if [[ -z "$(file -b --mime-type "$file" 2>/dev/null | grep -E '^text/')" ]] || [[ ! -s "$file" ]]; then
        continue
    fi
    
    # Check if file has a "Created by" line with the author regex
    if ! grep -q -E "Created by.*${AUTHOR_REGEX}" "$file"; then
        continue
    fi
    
    echo "Processing $file..."
    
    # If we're in staged mode, we need to save the current state of the rest of the file
    if [[ $STAGED_ONLY -eq 1 ]]; then
        # Stash the current changes so we can work with a clean file
        git stash push -m "Temporary stash for copyright update" --keep-index >/dev/null 2>&1
        stashed=1
    fi
    
    # Create a temp directory for our operations
    temp_dir=$(mktemp -d)
    
    # Make a backup of the original file
    cp "$file" "$file.bak"
    
    # Modify the file in place - we'll only modify the header part
    # 1. Update the author name
    sed -i.tmp -E "s/(Created by )${AUTHOR_REGEX}/\1${STANDARDIZED_AUTHOR}/" "$file"
    
    # 2. Update the date format
    sed -i.tmp -E 's/on ([0-9]{1,2})\/([0-9]{1,2})\/([0-9]{2})$/on 20\3-0\2-0\1/g' "$file"
    sed -i.tmp -E 's/on ([0-9]{1,2})\/([0-9]{1,2})\/([0-9]{4})$/on \3-0\2-0\1/g' "$file"
    sed -i.tmp -E 's/on ([0-9]{4})-0([0-9]{2})-0([0-9]{2})/on \1-\2-\3/g' "$file"
    
    # 3. Check if copyright line exists
    if grep -q "Copyright" "$file"; then
        # Replace existing copyright line
        sed -i.tmp -E 's@//  Copyright © [0-9]{4}(-|–|—)[0-9]{4}.*@//  Copyright © '"$copyright_range"' '"$STANDARDIZED_AUTHOR"'. All rights reserved.@' "$file"
        sed -i.tmp -E 's@//  Copyright © [0-9]{4}.*@//  Copyright © '"$copyright_range"' '"$STANDARDIZED_AUTHOR"'. All rights reserved.@' "$file"
    else
        # Add copyright line after "Created by" line - fix for preserving empty comment lines
        
        # Create temporary files for processing
        grep -n "Created by" "$file" | head -1 > "$temp_dir/created_line"
        if [[ -s "$temp_dir/created_line" ]]; then
            line_num=$(cut -d: -f1 "$temp_dir/created_line")
            
            # Get the file content up to and including the "Created by" line
            head -n "$line_num" "$file" > "$temp_dir/head"
            
            # Get the rest of the file after the "Created by" line
            tail -n "+$(($line_num + 1))" "$file" > "$temp_dir/tail"
            
            # Combine with the copyright line inserted between
            cat "$temp_dir/head" > "$temp_dir/new_file"
            echo "//  Copyright © ${copyright_range} ${STANDARDIZED_AUTHOR}. All rights reserved." >> "$temp_dir/new_file"
            cat "$temp_dir/tail" >> "$temp_dir/new_file"
            
            # Replace the original file
            cp "$temp_dir/new_file" "$file"
        fi
    fi
    
    # Remove temporary files created by sed
    rm -f "$file.tmp"
    
    # Check if the file has actually changed
    if ! cmp -s "$file" "$file.bak"; then
        # File was modified
        modified_files+=("$file")
        
        if [[ $STAGED_ONLY -eq 1 ]]; then
            # Stage the changes
            git add "$file"
        fi
    fi
    
    # Restore the original unstaged changes if needed
    if [[ $STAGED_ONLY -eq 1 && $stashed -eq 1 ]]; then
        git stash pop >/dev/null 2>&1
        stashed=0
    fi
    
    # Remove the backup and temp directory
    rm -f "$file.bak"
    rm -rf "$temp_dir"
done

echo "Copyright headers updated successfully!"
if [[ ${#modified_files[@]} -gt 0 ]]; then
    echo "Updated ${#modified_files[@]} files."
    if [[ $STAGED_ONLY -eq 1 ]]; then
        echo "Changes have been staged for commit."
    fi
else
    echo "No files needed updating."
fi