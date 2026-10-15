#!/usr/bin/env bash
# Lists the images in a wallpaper folder for the shell's wallpaper picker,
# making a thumbnail for any that don't have one yet.
#
#   wallpaper-index.sh FOLDER RECURSIVE CACHE_DIR
#
# RECURSIVE is 1 to include subfolders. Hidden files and folders are skipped.
# Prints "#total N" first, then a tab-separated line per image as soon as its
# thumbnail is ready:
#
#   path  mtime  bytes  width  height  thumbnail
#
# Thumbnails are 896x504 JPEGs, cropped to 16:9 like the picker's cards. They
# are named after the image's path, size and modification time, so an edited
# image gets a new one. Images ffmpeg can't read are left out.

set -u

folder=$1
recursive=$2
export cache=$3

mkdir -p "$cache" || exit 1

depth=(-maxdepth 1)
[ "$recursive" = 1 ] && depth=()

mapfile -d '' files < <(
    find -L "$folder" -mindepth 1 "${depth[@]}" \
        -name '.*' -prune -o \
        -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \
            -o -iname '*.gif' -o -iname '*.bmp' \) -print0 2>/dev/null
)

echo "#total ${#files[@]}"
[ "${#files[@]}" -eq 0 ] && exit 0

index_one() {
    local file=$1 mtime bytes key thumb size width height
    read -r mtime bytes < <(stat -L -c '%Y %s' -- "$file") || return
    key=$(printf '%s|%s|%s' "$file" "$mtime" "$bytes" | md5sum | cut -c1-32)
    thumb="$cache/$key.jpg"

    if [ ! -s "$thumb" ] || [ ! -s "$cache/$key.size" ]; then
        size=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height \
            -of csv=p=0:s=x -- "$file" 2>/dev/null | head -n 1)
        # Written under a temporary name, so a cancelled run leaves no half thumbnail.
        if ! ffmpeg -nostdin -v error -y -i "$file" -frames:v 1 \
            -vf 'scale=896:504:force_original_aspect_ratio=increase:flags=lanczos,crop=896:504' \
            -q:v 3 "$thumb.part.jpg" 2>/dev/null; then
            rm -f -- "$thumb.part.jpg"
            echo "wallpaper-index: can't read $file" >&2
            return
        fi
        mv -f -- "$thumb.part.jpg" "$thumb"
        printf '%s\n' "${size:-0x0}" > "$cache/$key.size"
    fi

    IFS=x read -r width height < "$cache/$key.size"
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$file" "$mtime" "$bytes" "${width:-0}" "${height:-0}" "$thumb"
}
export -f index_one

# A few at a time: a large PNG takes a few hundred MB to decode.
printf '%s\0' "${files[@]}" | xargs -0 -n 1 -P 4 bash -c 'index_one "$1"' _
