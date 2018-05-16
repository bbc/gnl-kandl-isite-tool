#!/bin/bash

if [[ $1 =~ ^(test|live)$ ]]; then
    ENVIRONMENT=$1
else
    echo "Environment must be 'test' or 'live', not ${1}"
    exit
fi

FILE_TYPE_PATH="$HOME/workspace/blocks/isite2/forms/$ENVIRONMENT/documenttype/$2"

if [ -d "$FILE_TYPE_PATH" ]; then
    # Control will enter here if $DIRECTORY exists.
    FILETYPE=$2
else
    echo "Could not find the specified filetype with the iSite project files."
    echo "$FILE_TYPE_PATH"
    exit
fi

projects=(
    blocks
    blocks-food
    blocks-bitesize
    blocks-class-clips-audio
    blocks-class-clips-video
    blocks-iwonder
    blocks-live-lessons
    blocks-ten-pieces
    blocks-terrific-scientific
    blocks-tomorrows-world
)

for project in "${projects[@]}"
do
    echo '****************************************'
    echo "* $project"
    echo '****************************************'

    BASE_DIRECTORY="./data/${ENVIRONMENT}-environment/${project}/${FILETYPE}"

    ruby ./app/fetch.rb -e ${ENVIRONMENT} -p ${project} -f ${FILETYPE}

    if [ -d "$BASE_DIRECTORY/extracted" ]; then
        ruby ./transform.rb -e ${ENVIRONMENT} -p ${project} -f ${FILETYPE} -t 002
        ruby ./filter.rb -e ${ENVIRONMENT} -p ${project} -f ${FILETYPE}
    fi

    # if [ -d "$BASE_DIRECTORY/upload" ]; then
    #     ruby ./upload.rb -e ${ENVIRONMENT} -p ${project} -f ${FILETYPE}
    # fi
done
