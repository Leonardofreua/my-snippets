#!/usr/bin/env bash

set -euox pipefail

DEFAULT_LABEL=TASK

declare -A TAGS=(
	[ADDED]="Added"
	[FIXED]="Fixed"
  	[CHORE]="Chore"
)

is_valid_tag() {
	local value="$1"
	for key in "${!TAGS[@]}"; do
		if [[ "${TAGS[$key]}" == "$value" ]]; then
			return 0
		fi
	done
	return 1
}

# Basic argument validation
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <target_dir> <range|branch> [git log args...] <any other optional argument...>"
  exit 1
fi

target_dir="$1"
if ! git -C "$target_dir" rev-parse --git-dir >/dev/null 2>&1; then
	echo "Error: '$target_dir' is not a valid git repository." >&2
	exit 1
fi
shift

# Detect optional branching range (e.g. main..feature/task) and prefix
range="HEAD"
prefix_label="$DEFAULT_LABEL"
if [[ $# -gt 0 && ! "$1" =~ ^-- ]]; then
	range="$1"
	shift

	if [[ "$range" =~ \.\. ]]; then
		# Example: TASK-157..TASK-333 -> prefix = [TASK-333]
		prefix_label="${range##*..}"
	else
		# Example: TASK-157 -> prefix = [TASK-157]
		prefix_label="$range"
	fi
else
	# No branch/range -> detect the current branch
	prefix_label=$(git -C "$target_dir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "$DEFAULT_LABEL")
fi

if ! git -C "$target_dir" rev-parse --verify --quiet "${range%%..*}" >/dev/null 2>&1; then
	echo "Error: '$range' is not a valid branch or commit range." >&2
	exit 1
fi

# Parse arguments
output_file=""
prepend_mode=false
tag="Added"
git_args=()
while [[ $# -gt 0 ]]; do
	case "$1" in
		--output)
			shift
			output_file="${1:-}"
			if [[ -z "$output_file" ]]; then
				echo "Error: --output requires a file path argument." >&2
				exit 1
			fi
			;;
		--prepend)
			prepend_mode=true
			;;
		--tag)
			shift
			tag="${1:-}"
			if [[ -z "$tag" ]] ; then
				echo "Error: --tag requires a value (Added|Fixed|Chore)." >&2
				exit 1
			fi

			if ! is_valid_tag "$tag"; then
				echo "Error: Invalid tag '$tag'. Must be one of: Added, Fixed, Chore" >&2
				exit 1
			fi
			;;
		*)
			git_args+=("$1")
			;;
	esac
	shift
done

normalized_prefix=$(echo "$prefix_label" | grep -oE '[A-Za-z]+-[0-9]+' | tr '[:lower:]' '[:upper:]' || echo  "$DEFAULT_PREFIX")
log_output=$(
	git -C "$target_dir" log "$range" --oneline "${git_args[@]}" | \
	awk -v prefix="[$normalized_prefix]" -v tag="$tag" '
	{
		$1 = ""; 					# remove hash
		sub(/ *\(.*\) */, "");  	# remove parentheses
		message = substr($0, 2); 	# trim leading space

		# Remove any existing prefix from the commit message
		gsub(/^\[[A-Za-z]+-[0-9]+\] */, "", message);

		if (length(message) > 0)
			print "- " prefix " " message      
	}'
)

# Try to extract version from pom.xml
version=""
pom_file="$target_dir"/pom.xml
if [[ -s "$pom_file" ]]; then
	version=$(awk '
		/<version>/ && !found && !inside_parent {
			gsub(/.*<version>|<\/version>.*/, "", $0);
			print $0
			found=1;
		}
		/<parent>/ { inside_parent=1 }
		/<\/parent>/ { inside_parent=0 }
	' "$pom_file" | grep -oE '[0-9]+(\.[0-9]+){2,3}')
fi

version_segment=""
if [[ -n "$version" ]]; then
	version_segment=" [$version]"
fi

# Formatting final output
current_date=$(date +%Y-%m-%d)
formatted_output=$(cat <<EOF
##$version_segment $current_date

### $tag

$log_output
EOF
)

# Output handling
if [[ -n "$output_file" ]]; then
	if [[ "$prepend_mode" == true && -f "$output_file" ]]; then
		tmp_file="$(mktemp)"
		{
			echo "$formatted_output"
			echo
			cat "$output_file"
		} > "$tmp_file"
		mv "$tmp_file" "$output_file"
		echo "Changelog prepended to: $output_file"
	else
		echo "$formatted_output" > "$output_file"
		echo "Changelog saved to: $output_file"
	fi
else
	echo "$formatted_output"
fi