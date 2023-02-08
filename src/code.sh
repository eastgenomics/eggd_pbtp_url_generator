#!/bin/bash
# eggd_pbtp_url_generator 1.0.0

extract_id_from_delivery_report() {
    # Extract DNA Nexus ID(s)
}

main() {
    set -e -x -v -o pipefail
    echo "Path to samples: '$samples'"


    while IFS= read -r local_id; do
        # Get DNANexus ID from the local ID, by searching for the local in delivery reports. Add to associative array.
        deliveries=( $( dx ls "/Delivery_notes" ) )
        declare -A id_dict=()
        for report in "${deliveries[@]}"; do
            result=$(dx cat ${report} | grep ${local_id})
            # TODO add correct handling of multiple results
            if [ ! -z "$result" ]; then id_dict+=(["$local_id"]="$result"); \
            else id_dict+=(["$local_id"]="none"); fi
        done



    done < "$samples"

    dx-jobutil-add-output urls "$urls" --class=file
}
