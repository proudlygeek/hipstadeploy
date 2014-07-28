#!/usr/bin/env bash

#
# HipstaDeploy
# ~~~~~~~~~~~~
#
# A Bash script for deploying stuff on Amazon CloudFront.
#
# Copyright: (c) 2014 by Gianluca Bargelli <g.bargelli@gmail.com>
# License: MIT
#

COLOR_GREEN="\e[0;32m"
COLOR_RESET="\e[0m"
CHECKMARK_SYMBOL="✔"
XMARK_SYMBOL="✘"
COLOR_RED="\e[0;33m"
VERSION="v0.1.3"

# Version

function usage {
  echo "HipstaDeploy $VERSION. Static site deployment on Amazon Cloudfront."
  echo ""
  printf "Usage: $0 [-u url] [-p path] [-r remote URL]\n"
  echo ""
  echo "Options:"
  printf "    -h\tShows this screen.\n"
  printf "    -u\tURL of your website [default: http://localhost:2368].\n"
  printf "    -o\tOutput folder of the generated static pages [default: _site].\n"
  printf "    -r\tURL of remote site (used for RSS feed find/replace) [no default].\n"
}

function show_banner {
  printf '
%b______  ______               _____       ________             ______
%b___  / / /__(_)________________  /______ ___  __ \_______________  /__________  __
%b__  /_/ /__  /___  __ \_  ___/  __/  __ `/_  / / /  _ \__  __ \_  /_  __ \_  / / /
%b_  __  / _  / __  /_/ /(__  )/ /_ / /_/ /_  /_/ //  __/_  /_/ /  / / /_/ /  /_/ /
%b/_/ /_/  /_/  _  .___//____/ \__/ \__,_/ /_____/ \___/_  .___//_/  \____/_\__, /
              /_/                                     /_/                /____/' $(tput setaf 164) $(tput setaf 163) $(tput setaf 162) $(tput setaf 161) $(tput setaf 160)
  printf $COLOR_RESET
  echo ""
  echo "                                           The Amazing Static Site Deploy Script™! "
  echo "==================================================================================
  "
}

function display_green_check {
  printf $COLOR_GREEN
  echo "$CHECKMARK_SYMBOL $1"
  printf $COLOR_RESET
}

function display_red_check {
  printf $COLOR_RED
  echo "$XMARK_SYMBOL $1"
  printf $COLOR_RESET
}

function generate_static_site {
  SECTION_NAME="Generate static files"
  CMD="wget --recursive \
       --convert-links \
       --page-requisites \
       --no-parent \
       --directory-prefix $OUTPUT_FOLDER \
       --no-host-directories $SITE_URL"

  if [[ $(eval $CMD "2>&1 > /dev/null") != 0 && $? == 8 ]]; then
    display_red_check "Got some 404 while generating static files."

    echo ""
    printf "Do you want to continue? %b[Y/n]%b: " $(tput setaf 12) ${COLOR_RESET}
    read CHOICE

    if [[ "$CHOICE" = "N" || "$CHOICE" = "n" ]]; then
      echo ""
      display_red_check "$SECTION_NAME"
      show_footer
      exit 0
    fi

  elif [[ $? == 0 ]]; then
    display_red_check "$SECTION_NAME"
    exit 1
  fi

  display_green_check "$SECTION_NAME"
}

function remove_assets_version {
  SECTION_NAME="Rename Assets Version"
  for f in $(find . -type f | grep "?v=" | uniq)
  do
    mv "$f" $(echo "$f" | sed "s/?v=.*//g")
  done

  display_green_check "$SECTION_NAME"
}

function rename_links {

  grep -l -R "" * | xargs sed -i".bak" 's/index\.html//'
  find . -type f | grep "bak$" | xargs rm -rf

  display_green_check "Rename links"
}

function fix_rss {
  if [ -n "$PUBLISH_URL" ]; then
    ruby -e "files = Dir.glob('$OUTPUT_FOLDER' + 'rss/*') << Dir.glob('$OUTPUT_FOLDER' + 'rss*') << Dir.glob('$OUTPUT_FOLDER' + 'feed/*') << Dir.glob('$OUTPUT_FOLDER' + 'feed*'); files.each { |file_name| if file_name.kind_of?(String) then text = File.read(file_name); replace = text.gsub!('$SITE_URL', '$PUBLISH_URL'); File.open(file_name, 'w') { |file| file.puts replace } end }"

    display_green_check "Fixing RSS feed"
  else
    display_red_check "Fixing RSS feed (no publish url; skipping)"
	fi
}


function deploy {
  SECTION_NAME="Deploy to Amazon CloudFront"
  CMD="s3_website push --site=$OUTPUT_FOLDER"

  echo ""
  printf "Do you want to deploy your static site on Amazon CloudFront? %b[Y/n]%b: " $(tput setaf 12) ${COLOR_RESET}
  read DEPLOY

  if [[ "$DEPLOY" = "N" || "$DEPLOY" = "n" ]]; then
    echo ""
    display_red_check "$SECTION_NAME"
    return
  fi

  while IFS= read -r line; do
      echo $line
      if [[ $line == ERROR* ]]
      then
          echo -e "\n\n"
          echo "Exiting on s3_website push error."
          display_red_check "$SECTION_NAME"
          return
          exit 0
      fi
  done < <($CMD 2>&1)

  display_green_check "$SECTION_NAME"
}

function show_footer {
  END=$(date +%s)
  echo ""
  echo "=================================================================================="
  echo ""
  TOTAL_TIME=$(echo $((END-START)) | awk '{printf "%d:%02d:%02d", $1/3600, ($1/60)%60, $1%60}')
  printf $COLOR_RED
  printf "Done!$COLOR_RESET Total time was $TOTAL_TIME\n"
}

function jsonval {
    prop=$1
    temp1=`echo $CONFIG | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | \
            awk '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | \
            sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -iw $prop`
    temp2=`IFS=':' read -r value string <<< "$temp1"; echo $string`
    echo "${temp2##*|}"
}

function read_config {
  CONFIG=$(<Hipstafile)
  SITE_URL=$(jsonval 'SITE_URL')
  OUTPUT_FOLDER=$(jsonval 'OUTPUT_FOLDER')
  PUBLISH_URL=$(jsonval 'PUBLISH_URL')

  echo $SITE_URL
  echo $OUTPUT_FOLDER
  echo $PUBLISH_URL
}

function main {
  START=$(date +%s)
  read_config
  show_banner
  generate_static_site
  remove_assets_version
  rename_links
  fix_rss
  deploy
  show_footer
}

while getopts ":u:o:r:h" OPT; do
  case $OPT in
    h)
      usage
      exit 0
      ;;
    u)
      SITE_URL="$OPTARG"
      ;;
    o)
      OUTPUT_FOLDER="$OPTARG"
      ;;
    r)
    	PUBLISH_URL="$OPTARG"
    	;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      exit 1
      ;;
  esac
done

main

exit 0
