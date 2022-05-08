#!/bin/bash

urlencode () {
    python -c "import urllib.parse as ul; print(ul.quote(\"$1\", safe=''))"
}

PLAYLIST="$1"

PLAYLIST_ENC="https://genmp3.net/tracks.php?u=$(urlencode $PLAYLIST)"

HTML_FILENAME=${PLAYLIST##*/}.html
SONG_FILENAME=${HTML_FILENAME/html/names.txt}

google-chrome-stable --headless --dump-dom "$PLAYLIST_ENC" > $HTML_FILENAME \
    2>/dev/null || exit 1

grep "<a href=\"#\" title=\"Download " $HTML_FILENAME \
    | cut -d '>' -f 3 | cut -d '<' -f 1 | sed '/^[[:space:]]*$/d' \
    > $SONG_FILENAME

echo -e "HTML file :\t\t./$HTML_FILENAME"
echo -e "Extracted titles file :\t./$SONG_FILENAME"

TOTAL=$(wc -l < $SONG_FILENAME)
CURRENT=1

while read -r name
do
    echo "($CURRENT/$TOTAL) Copying '$name' to clipboard..."
    echo "$name" | xclip -selection clipboard
    read -p "Press enter to continue" < /dev/tty

    CURRENT=$((CURRENT+1))
done < $SONG_FILENAME