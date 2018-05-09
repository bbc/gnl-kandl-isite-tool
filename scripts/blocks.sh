#!/bin/bash

if [[ $1 =~ ^(test|live)$ ]]; then
    ENVIRONMENT=$1
else
    echo "Environment must be 'test' or 'live', not ${1}"
    exit
fi

if [ -d "$HOME/workspace/blocks/isite2/forms/$ENVIRONMENT/documenttype/$2" ]; then
    # Control will enter here if $DIRECTORY exists.
    FILETYPE=$2
else
    echo "Could not find the specified filetype with the iSite project files."
    echo "$HOME/workspace/blocks/isite2/forms/$ENVIRONMENT/documenttype/$2"
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
        ruby ./transform.rb -e ${ENVIRONMENT} -p ${project} -f ${FILETYPE} -t 001

        cp -r "${BASE_DIRECTORY}/transformed/" "${BASE_DIRECTORY}/upload/"
        if [ ! -d "${BASE_DIRECTORY}/upload/" ]; then
            echo "${BASE_DIRECTORY}/upload/ not created"
        fi

        ruby ./upload.rb -e ${ENVIRONMENT} -p ${project} -f ${FILETYPE}
    fi
done
