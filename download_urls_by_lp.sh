#!/user/bin/env bash

# For a list of LPs, gets download links of Dueto HTML files for (cancer) DNA,
# TERT files for DNA, and Dueto HTML files for RNA.
# Run from top level in project

lp_ids=$1
output_file=$2

get_file_id() {
	#Find the file with the matching ID.extension, and cut out the file ID
	parent_dir=$1
	lp_id=$2
	extension=$3
        file_path=$(dx ls -l --full "$parent_dir" | grep "${lp_id}"."${extension}")
	echo "$file_path" | cut -d "(" -f2 | cut -d ")" -f1
}

make_append_urls() {
	file_id=$1
	extension=$2
	lp_id=$3
	output_file=$4
	url=$(dx make_download_url --duration 1w "${file_id}")
	echo "${lp_id}" "${extension}" "${file_id}" "${url}" >> "${output_file}"
}

while IFS='' read -r i; do
	if [[ $i == *"DNA"* ]]; then
		echo "Processing sample: "
		echo $i
		#get Dueto report; convoluted path-finding because dx ls doesn't expand * even in terminal directly
		first_path=$(dx ls -l $i | grep "_Cancer")
		html_path="${i}/${first_path}DuetoSummary"
		html_id=$(get_file_id "$html_path" "$i" "html")
		make_append_urls "${html_id}" "html" "$i" "$output_file"
		#get TERT pileup
		bam_tert_txt_id=$(get_file_id "$i" "$i" "bam.tert.txt")
		make_append_urls "${bam_tert_txt_id}" "bam.tert.txt" "$i" "$output_file"
		#get TERT variants
		bam_tert_var_id=$(get_file_id "$i" "$i" "somatic.vcf.tert.txt")
		make_append_urls "${bam_tert_var_id}" "somatic.vcf.tert.txt" "$i" "$output_file"
	fi
	if [[ $i == *"RNA"* ]]; then
		#get Dueto report
                html_path=${i}/DuetoSummary
		html_id=$(get_file_id "${html_path}" "$i" "html")
		make_append_urls "$html_id" "html" "$i" "$output_file"
	fi
done < "${lp_ids}"
