#!/bin/bash

# Loop through each batch
while IFS=',' read -r batch bcstart bcend; do
    if [ "$batch" != "Batch" ]; then  # Skip the header
        bcstart=$(echo "$bcstart" | xargs)  # Trim spaces
        bcend=$(echo "$bcend" | xargs)      # Trim spaces

        echo "Processing batch: $batch, barcode range: $bcstart - $bcend"
        echo ""

        dataDir="data/f5s/$batch"
        srcDir="/arc/bag/mmmbackup/microbio/Nanopore/$batch/f5s"

        # Ensure destination directory exists
        mkdir -p "$dataDir"

        # Loop through barcodes in the range
        for ((bcnum=bcstart; bcnum<=bcend; bcnum++)); do
            bcnum=$(printf "%02d" "$bcnum")  # Format bcnum with leading zeros

            echo "Looking for files with barcode$bcnum"
            cp "$srcDir"/barcode"$bcnum"* "$dataDir/" 2>/dev/null
            echo "Copied files with barcode$bcnum"
            echo ""
        done
    fi
done < data/metadata/collect_all_reads_meta.csv
