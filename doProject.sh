#!/usr/bin/env bash
SCRIPT_DIR="$( cd "$( dirname "${0}" )" && pwd )"

ACTION="$1"
case "${ACTION}" in
"delete") APP=./app/remove.rb
  ;;
"fetch") APP=./app/fetch.rb
  ;;
"upload") APP=./app/upload.rb
  ;;
*) echo 'Arg 1 must be one of "delete" or "fetch" or "upload".'
  exit 1
esac

ENV=$2
if [[ -z $ENV ]]; then
  echo "Missing arg 2: (environment)"
  exit 1
fi

PROJECT="$3"
case "${PROJECT}" in
"wwverticals") FILE_TYPES=(article author collection destination-guide external json module navigation option pbcampaign pbcomponents pbpage pbtheme partner tag trackers)
  ;;
"gnlvideoproject") FILE_TYPES=(about contributor festival home home-promo playlist playlists tester topic video)
  ;;
"gnflagpoles") FILE_TYPES=(bbcdotcom gn-flagpolesqatest gnlops maruflagpole marulayout newsappandroid newsappios ngas sportsappandroid sportsappios ugasfeeds ugasflagpoles wwhomepage)
  ;;
*) echo 'Arg 3 must be one of "wwverticals", "gnlvideoproject" or "gnflagpoles".'
  exit 1
esac

for FILE_TYPE in "${FILE_TYPES[@]}"
do
    ruby "${APP}" -e "${ENV}" -p "${PROJECT}" -f "${FILE_TYPE}"
done

