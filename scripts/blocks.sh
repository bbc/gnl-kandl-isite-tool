#!/bin/bash

while getopts ":e:f:t:" opt; do
    case $opt in
        e  ) ENVIRONMENT=$OPTARG;;
        f  ) FILETYPE=$OPTARG;;
        t  ) TRANSFORM=$OPTARG;;
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done

FILE_TYPE_PATH="$HOME/workspace/blocks/isite2/forms/$ENVIRONMENT/documenttype/$FILETYPE"

if [ -z ${ENVIRONMENT+x} ]; then
    echo "Missing option: -e" >&2
    exit 1
elif [[ ! $ENVIRONMENT =~ ^(test|live)$ ]]; then
    echo "Environment must be 'test' or 'live', not ${ENVIRONMENT}" >&2
    exit 1
fi

if [ -z ${FILETYPE+x} ]; then
    echo "Missing option: -f" >&2
    exit 1
elif [ ! -d "$FILE_TYPE_PATH" ]; then
    echo "Could not find the specified filetype:" >&2
    echo "$FILE_TYPE_PATH" >&2
    exit 1
fi

if [ -z ${TRANSFORM+x} ]; then
    echo "Missing option: -t" >&2
    exit 1
elif [[ $TRANSFORM =~ '..' ]]; then
    FIRST_TRANSFORM=${TRANSFORM%%.*}
    LAST_TRANSFORM=${TRANSFORM##*.}
else
    FIRST_TRANSFORM=$TRANSFORM
    LAST_TRANSFORM=$TRANSFORM
fi

FIRST_TRANSFORM_ID=$(printf "%03d" $FIRST_TRANSFORM)
LAST_TRANSFORM_ID=$(printf "%03d" $LAST_TRANSFORM)

projects=(
    blocks
    blocks-arts
    blocks-bitesize
    blocks-briefings
    blocks-class-clips-audio
    blocks-class-clips-video
    blocks-creative
    blocks-food
    blocks-iwonder
    blocks-live-lessons
    blocks-teach
    blocks-ten-pieces
    blocks-terrific-scientific
    blocks-tomorrows-world
)

for PROJECT in "${projects[@]}"
do
    echo '****************************************'
    echo "* $PROJECT"
    echo '****************************************'

    BASE_DIRECTORY="./data/${ENVIRONMENT}-environment/${PROJECT}/${FILETYPE}"

    ruby ./app/fetch.rb -e ${ENVIRONMENT} -p ${PROJECT} -f ${FILETYPE}

    if [ -d "$BASE_DIRECTORY/extracted" ]; then
        for ((i=$FIRST_TRANSFORM; i<=$LAST_TRANSFORM; i++)); do
            TRANSFORM_ID=$(printf "%03d" $i)
            PREVIOUS_TRANSFORM_ID=$(printf "%03d" $((i-1)))

            if [ -f "$BASE_DIRECTORY/.logs/transforms.log" ]; then
                rm $BASE_DIRECTORY/.logs/transforms.log
            fi

            ruby ./transform.rb -e ${ENVIRONMENT} -p ${PROJECT} -f ${FILETYPE} -t ${TRANSFORM_ID}
            sleep 1

            # Only need to remap the directories if running multiple transforms
            if [ "${FIRST_TRANSFORM}" != "${LAST_TRANSFORM}" ]; then
                if [ "${TRANSFORM_ID}" = "${FIRST_TRANSFORM_ID}" ]; then
                    mv $BASE_DIRECTORY/extracted $BASE_DIRECTORY/extracted-orig
                else
                    mv $BASE_DIRECTORY/extracted $BASE_DIRECTORY/transformed-${PREVIOUS_TRANSFORM_ID}
                fi
                sleep 1

                if [ "${TRANSFORM_ID}" = "${LAST_TRANSFORM_ID}" ]; then
                    mv $BASE_DIRECTORY/extracted-orig $BASE_DIRECTORY/extracted
                else
                    mv $BASE_DIRECTORY/transformed $BASE_DIRECTORY/extracted
                fi
                sleep 1
            fi
        done

        echo 'Prepare documents for upload...'
        echo '================================================='
        ruby ./filter.rb -e ${ENVIRONMENT} -p ${PROJECT} -f ${FILETYPE}
        echo ''
    fi

    # if [ -d "$BASE_DIRECTORY/upload" ]; then
    #     ruby ./upload.rb -e ${ENVIRONMENT} -p ${PROJECT} -f ${FILETYPE}
    # fi
done
