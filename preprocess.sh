#!/bin/bash

# If categories go more than one subdirectory deep, what
# character should be used in place of the / ?
categorySubdirSeparator='/'

for fullfile in $(find [^_]* -type f) ; do  # foo/bar.sh
   dir=$(dirname "$fullfile")               # foo
   dir_base="${fullfile%.*}"                # foo/bar
   base_ext=$(basename "$fullfile")         # bar.sh
   base="${base_ext%.*}"                    # bar
   ext="${base_ext##*.}"                    # sh

   filetype=''
   case "$ext" in
      txt)
         filetype='text'
         target=$dir_base.html
         ;;
      md)
         filetype='markdown'
         target=$dir_base.md
         ;;
      *)
         continue
         ;;
   esac

   title=${dir_base//\// :: }
   categories=${dir/\//$categorySubdirSeparator}

   echo "PROCESSING $filetype FILE ($dir / $base . $ext)"

   echo '---'                       > $fullfile.tmp
   echo "layout: $filetype"         >> $fullfile.tmp
   echo "title: \"$title\""         >> $fullfile.tmp
   echo "resource: true"            >> $fullfile.tmp
   echo "categories: [$categories]" >> $fullfile.tmp
   echo '---'                       >> $fullfile.tmp
   cat $fullfile                    >> $fullfile.tmp
   rm $fullfile
   mv $fullfile.tmp $target

done

allCategories=$(find [^_]* -type d | tr '/' "$categorySubdirSeparator" | tr '\n' ',' | sed -e 's/,$//g')
echo "CATEGORIES: $allCategories"
sed -i -e "s@^categoryList:.*\$@categoryList: [$allCategories]@g" _config.yml


