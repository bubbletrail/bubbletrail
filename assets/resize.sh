INPUT="$1"
PREFIX="${2:-icon-iOS-Default}"
OUTDIR="${3:-.}"

if [ -z "$INPUT" ]; then
    echo "Usage: $0 <input-1024px.png> [output-prefix] [output-dir]"
    exit 1
fi

mkdir -p "$OUTDIR"

# Format: "base_size scale"
sizes=(
    "16 1"
    "16 2"
    "20 1"
    "20 2"
    "20 3"
    "29 1"
    "29 2"
    "29 3"
    "32 1"
    "32 2"
    "38 2"
    "38 3"
    "40 1"
    "40 2"
    "40 3"
    "60 2"
    "60 3"
    "64 2"
    "64 3"
    "68 2"
    "76 1"
    "76 2"
    "83.5 2"
    "128 1"
    "128 2"
    "256 1"
    "256 2"
    "512 1"
    "1024 1"
)

for entry in "${sizes[@]}"; do
    read -r base scale <<< "$entry"
    pixels=$(echo "$base * $scale" | bc)
    pixels=${pixels%.*}  # truncate decimal
    outfile="$OUTDIR/${PREFIX}-${base}x${base}@${scale}x.png"
    echo "Creating $outfile (${pixels}px)"
    magick "$INPUT" -resize "${pixels}x${pixels}" -density 72 "$outfile"
done
