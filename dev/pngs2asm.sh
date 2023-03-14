#!/bin/bash

prog="$(basename $0)"
tmpdir="$prog-tmp"
dims="12x12"
dir="$(dirname $0)"
trim=0

usage_msg() {
    echo "Usage: $prog [OPTIONS] FILE"
}

help_msg() {
    usage_msg
    echo "Convert a spritesheet into AVR assembly directives. Skips blank sprites."
    echo ""
    echo "  -d, --dimensions WxH     sprite dimensions (default 12x12)"
    echo "  -h, --help               display this help and exit"
    echo "  -t, --trim               remove transparent edge pixels"
}

if [[ $# == 0 ]]; then
    usage_msg
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--dimensions)
            dims="$2"
            shift
            shift
            ;;
        -h|--help)
            help_msg
            exit 0
            ;;
        -t|--trim)
            trim=1
            shift
            ;;
        -*)
            echo "$prog: Invalid option \`$1'"
            echo "See options with \`$prog --help'"
            exit 1
            ;;
        *)
            if [[ -z "$input" ]]; then
                input="$1"
                shift
            else
                echo "$prog: Unexpected file \`$1'"
                exit 1
            fi
    esac
done

if [[ -z "$input" ]]; then
    echo "$prog: Must provide an input file"
    exit 1
fi

if [[ ! -e "$input" ]]; then
    echo "$prog: File \`$input' does not exist"
    exit 1
fi

if ! command -v convert &> /dev/null; then
    echo "$prog: ImageMagick must be installed"
    exit 1
fi

if [[ -d "$tmpdir" ]]; then
    rm -rf "$tmpdir"
fi

mkdir $tmpdir
convert "$input" -crop "$dims" +repage "$tmpdir/section-%03d.png"
for f in "$tmpdir"/section-*.png; do
    if [ $(convert "$f" -alpha on -channel A -scale 1x1! -format "%[fx:mean]" info:) != "0" ]; then
        if [[ $trim == 1 ]]; then
            page="$(magick $f -trim -format "%O " -write info: +repage -format "%wx%h" -write info: $f)"
            offset="$(echo $page | cut -d ' ' -f1)"
            dims="$(echo $page | cut -d ' ' -f2)"
            x="$(echo $offset | cut -d '+' -f2)"
            y="$(echo $offset | cut -d '+' -f3)"
            w="$(echo $dims | cut -d 'x' -f1)"
            h="$(echo $dims | cut -d 'x' -f2)"
            ruby "$dir/png2asm.rb" "$f"
            f2="${f%.png}.asm"
            echo ".db $x, $y, $w, $h" > tmp
            cat $f2 >> tmp
            mv tmp $f2
        else
            ruby "$dir/png2asm.rb" "$f"
        fi

    else
        echo "skipping $(basename $f)"
    fi
done
cat "$tmpdir"/section-*.asm
rm -rf "$tmpdir"
