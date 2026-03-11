#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ----------------------------------------------------------------------
# Resolve symlinks to find true script directory
# ----------------------------------------------------------------------
resolve_link() {
    local target="$1"
    while [ -L "$target" ]; do
        local target_dir
        target_dir="$(cd "$(dirname "$target")" && pwd)"
        target="$(readlink "$target")"
        [[ "$target" != /* ]] && target="$target_dir/$target"
    done
    printf '%s\n' "$target"
}
script_path="$(resolve_link "${BASH_SOURCE[0]}")"
script_dir="$(cd "$(dirname "$script_path")" && pwd)"

resolve_datadir() {
    local candidate
    if [[ -n "${MD2PDF_DATADIR:-}" ]]; then
        printf '%s\n' "$MD2PDF_DATADIR"
        return
    fi

    for candidate in "$script_dir/../share/md2pdf" "$script_dir/../lib"; do
        if [[ -d "$candidate/templates" && -d "$candidate/filters" ]]; then
            printf '%s\n' "$candidate"
            return
        fi
    done

    # Fallback used for a deterministic error message in validate_datadir().
    printf '%s\n' "$script_dir/../share/md2pdf"
}

datadir="$(resolve_datadir)"

# ----------------------------------------------------------------------
# Version information
# ----------------------------------------------------------------------
VERSION="0.1.1"
COPYRIGHT_YEAR="2026"
AUTHOR="nemron"

print_version() {
    echo "md2pdf, v${VERSION}, (C) ${COPYRIGHT_YEAR} ${AUTHOR}"
}

# ----------------------------------------------------------------------
# Usage info
# ----------------------------------------------------------------------
print_usage() {
    cat <<EOF
Usage: $0 [options] -- <input.md> [pandoc args...]

Options:
  -o, --output <file>     Output PDF (default: <input>.pdf)
  --template <name|path>  Template name from templates/ or explicit .tex path
  --no-crossref           Disable pandoc-crossref filter
  --list-templates        List available template names and exit
  --asset-link <dir>      Symlink asset directory into input folder (repeatable)
  --debug                 Enable debug output
  --version               Show version and exit
EOF
}

if [ "$#" -lt 1 ]; then
    print_usage
    exit 1
fi

# ----------------------------------------------------------------------
# Defaults
# ----------------------------------------------------------------------
debug_mode=false
crossref_enabled=true
input=""
output=""
template_selector="default"
template=""
header_includes=""
templates_dir="$datadir/templates"
filters_dir="$datadir/filters"
filters_manifest="$filters_dir/manifest.sh"
list_templates_mode=false
extra_args=()
asset_links=()
asset_symlinks=()
pandoc_filter_args=()

log_msg() {
    local level="$1"; shift
    echo "[md2pdf|$level] $*"
}

log_info() { log_msg info "$@"; }
log_warn() { log_msg warn "$@"; }
log_error() { log_msg error "$@"; }

validate_datadir() {
    if [[ ! -d "$templates_dir" || ! -d "$filters_dir" ]]; then
        log_error "Missing md2pdf data dir: $datadir (expected templates/ and filters/)."
        exit 1
    fi
    if [[ ! -f "$templates_dir/default.tex" ]]; then
        log_error "Missing default template at '$templates_dir/default.tex'."
        exit 1
    fi
    if [[ ! -f "$templates_dir/default.icl" ]]; then
        log_error "Missing default header includes at '$templates_dir/default.icl'."
        exit 1
    fi
    if [[ ! -f "$filters_manifest" ]]; then
        log_error "Missing filter manifest at '$filters_manifest'."
        exit 1
    fi
}

build_filter_args() {
    # shellcheck source=/dev/null
    source "$filters_manifest"

    if [[ -z "${MD2PDF_FILTER_FILES+x}" || "${#MD2PDF_FILTER_FILES[@]}" -eq 0 ]]; then
        log_error "Filter manifest '$filters_manifest' does not define MD2PDF_FILTER_FILES."
        exit 1
    fi

    pandoc_filter_args=()
    local filter_file
    local filter_path
    for filter_file in "${MD2PDF_FILTER_FILES[@]}"; do
        filter_path="$filters_dir/$filter_file"
        if [[ ! -f "$filter_path" ]]; then
            log_error "Filter '$filter_file' declared in manifest but missing at '$filter_path'."
            exit 1
        fi
        pandoc_filter_args+=(-L "$filter_path")
    done
}

check_dependencies() {
    local missing=()
    local required=(pandoc pdflatex)
    local dep

    if $crossref_enabled; then
        required+=(pandoc-crossref)
    fi

    if [[ "${#asset_links[@]}" -gt 0 ]]; then
        required+=(python3)
    fi

    for dep in "${required[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done

    if [[ "${#missing[@]}" -gt 0 ]]; then
        log_error "Missing required command(s): ${missing[*]}"
        exit 1
    fi
}

cleanup_symlinks() {
    if [[ "${#asset_symlinks[@]}" -eq 0 ]]; then
        return
    fi

    for link in "${asset_symlinks[@]}"; do
        if [[ -L "$link" ]]; then
            rm -f "$link"
            log_info "Removed temporary asset link $(basename "$link")."
        fi
    done
}

trap 'cleanup_symlinks' EXIT

resolve_user_path() {
    local raw="$1"
    if [[ "$raw" == "~"* ]]; then
        raw="${raw/#\~/$HOME}"
    fi
    if [[ "$raw" == /* ]]; then
        printf '%s\n' "$raw"
    else
        printf '%s\n' "$PWD/$raw"
    fi
}

is_template_path_selector() {
    local selector="$1"
    [[ "$selector" == */* || "$selector" == .* || "$selector" == "~"* ]]
}

list_available_templates() {
    local found=0

    if [[ -d "$templates_dir" ]]; then
        local template_path
        for template_path in "$templates_dir"/*.tex; do
            [[ -f "$template_path" ]] || continue
            basename "$template_path" .tex
            found=1
        done
    fi

    if [[ "$found" -eq 0 ]]; then
        log_error "No templates found."
        exit 1
    fi
}

resolve_template_config() {
    local selector="$1"
    local name
    local candidate
    local header_candidate

    if is_template_path_selector "$selector"; then
        candidate="$(resolve_user_path "$selector")"
        if [[ ! -f "$candidate" ]]; then
            log_error "Template path '$selector' (resolved to '$candidate') does not exist."
            exit 1
        fi
        template="$candidate"

        header_candidate="${candidate%.*}.icl"
        if [[ -f "$header_candidate" ]]; then
            header_includes="$header_candidate"
            return
        fi
    else
        name="${selector%.tex}"
        candidate="$templates_dir/$name.tex"
        if [[ -f "$candidate" ]]; then
            template="$candidate"
            header_candidate="$templates_dir/$name.icl"
            if [[ -f "$header_candidate" ]]; then
                header_includes="$header_candidate"
                return
            fi
        else
            log_error "Unknown template '$selector'. Use --list-templates to inspect available templates."
            exit 1
        fi
    fi

    if [[ -f "$templates_dir/default.icl" ]]; then
        header_includes="$templates_dir/default.icl"
    else
        log_error "No header include file found for template '$selector'."
        exit 1
    fi
}

resolve_asset_path() {
    local base="$1"
    local raw="$2"
    python3 - "$base" "$raw" <<'PY'
import os
import sys

base = sys.argv[1]
raw = os.path.expanduser(sys.argv[2])

if os.path.isabs(raw):
    path = raw
else:
    path = os.path.join(base, raw)

print(os.path.abspath(path))
PY
}

prepare_asset_links() {
    if [[ "${#asset_links[@]}" -eq 0 ]]; then
        return
    fi

    log_info "Preparing ${#asset_links[@]} asset link(s)..."
    for raw_path in "${asset_links[@]}"; do
        local resolved
        resolved="$(resolve_asset_path "$input_path" "$raw_path")"

        if [[ ! -d "$resolved" ]]; then
            log_error "Asset path '$raw_path' (resolved to '$resolved') does not exist or is not a directory."
            exit 1
        fi

        local trimmed="${resolved%/}"
        [[ -z "$trimmed" ]] && trimmed="$resolved"
        local link_name
        link_name="$(basename "$trimmed")"
        if [[ -z "$link_name" || "$link_name" == "." ]]; then
            log_error "Unable to derive a link name from asset path '$raw_path'."
            exit 1
        fi

        local link_path="$input_path/$link_name"
        if [[ -L "$link_path" ]]; then
            log_warn "Asset link '$link_name' already exists and will be replaced."
            rm -f "$link_path"
        elif [[ -e "$link_path" ]]; then
            log_error "Cannot create asset link '$link_name' because a file or directory already exists at '$link_path'."
            exit 1
        fi

        ln -s "$resolved" "$link_path"
        log_info "Linked '$link_name' -> '$resolved'."
        asset_symlinks+=("$link_path")
    done
}

# ----------------------------------------------------------------------
# Parse command line arguments
# ----------------------------------------------------------------------
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --)
            shift
            if [[ "$#" -lt 1 ]]; then
                echo "[md2pdf|error] '--' requires an <input.md> argument."
                exit 1
            fi
            input="$1"
            shift
            if [[ "$#" -gt 0 ]]; then
                extra_args+=("$@")
            fi
            break
            ;;
        -o|--output)
            shift
            if [[ "$#" -lt 1 ]]; then
                echo "[md2pdf|error] '-o/--output' requires a file argument."
                exit 1
            fi
            output="$1"
            ;;
        --template)
            shift
            if [[ "$#" -lt 1 ]]; then
                echo "[md2pdf|error] '--template' requires a template name or path."
                exit 1
            fi
            template_selector="$1"
            ;;
        --no-crossref)
            crossref_enabled=false
            ;;
        --list-templates)
            list_templates_mode=true
            ;;
        --asset-link)
            if [[ "$#" -lt 2 ]]; then
                echo "[md2pdf|error] '--asset-link' requires a path argument."
                exit 1
            fi
            shift
            asset_links+=("$1")
            ;;
        --debug)
            debug_mode=true
            ;;
        --version)
            print_version
            exit 0
            ;;
        -*|--*)
            echo "[md2pdf|error] Unknown option '$1'. Pass Pandoc arguments after '--'."
            exit 1
            ;;
        *)
            echo "[md2pdf|error] Unexpected argument '$1'. Provide <input.md> after '--'."
            exit 1
            ;;
    esac
    shift
done

# ----------------------------------------------------------------------
# Validate input files and dependencies
# ----------------------------------------------------------------------
validate_datadir

if $list_templates_mode; then
    list_available_templates | sort -u
    exit 0
fi

resolve_template_config "$template_selector"
build_filter_args

if [[ -z "$input" ]]; then
    print_usage
    exit 1
fi

if [[ ! -f "$input" ]]; then
    echo "[md2pdf|error] Input file '$input' does not exist."
    exit 1
fi

check_dependencies

# ----------------------------------------------------------------------
# Prepare paths
# ----------------------------------------------------------------------
input_path="$(cd "$(dirname "$input")" && pwd)"
input_file="$(basename "$input")"
input_base="${input_file%.md}"
input_yaml="${input_path}/${input_base}.yaml"

# Convert output to absolute path if provided or set default
if [[ -z "$output" ]]; then
    output="$input_path/$input_base.pdf"
fi

if [[ "$output" != /* ]]; then
    output="$PWD/$output"
fi

output_dir="$(dirname "$output")"
if [[ ! -d "$output_dir" ]]; then
    if ! mkdir -p "$output_dir"; then
        log_error "Cannot create output directory '$output_dir'."
        exit 1
    fi
fi
output="$(cd "$output_dir" && pwd)/$(basename "$output")"

# ----------------------------------------------------------------------
# Debug information
# ----------------------------------------------------------------------
if $debug_mode; then
    echo "[md2pdf|debug] script_dir:       $script_dir"
    echo "[md2pdf|debug] template_select:  $template_selector"
    echo "[md2pdf|debug] template:         $template"
    echo "[md2pdf|debug] header_includes:  $header_includes"
    echo "[md2pdf|debug] crossref_enabled: $crossref_enabled"
    echo "[md2pdf|debug] input_path:       $input_path"
    echo "[md2pdf|debug] input_file:       $input_file"
    echo "[md2pdf|debug] input_yaml:       $input_yaml"
    echo "[md2pdf|debug] output:           $output"
    if [[ "${#extra_args[@]:-0}" -gt 0 ]]; then
        echo "[md2pdf|debug] extra arguments:"
        printf '  %q\n' "${extra_args[@]}"
    fi
fi

# ----------------------------------------------------------------------
# Build Pandoc command (executed inside input path)
# ----------------------------------------------------------------------
prepare_asset_links

cd "$input_path"

pandoc_cmd=(pandoc
    --from markdown-smart+raw_tex+tex_math_dollars+footnotes+fenced_code_attributes
    --to pdf
    -H "$header_includes"
    --template "$template"
    --pdf-engine pdflatex
    --toc --number-sections
    --syntax-highlighting=idiomatic
    --resource-path="$input_path"
    "$input_file" -o "$output"
)

pandoc_cmd+=("${pandoc_filter_args[@]}")

if $crossref_enabled; then
    pandoc_cmd+=(-F pandoc-crossref)
fi

if [[ -f "$input_yaml" ]]; then
    pandoc_cmd+=(--metadata-file "$input_yaml")
fi

if [[ "${#extra_args[@]}" -gt 0 ]]; then
    pandoc_cmd+=("${extra_args[@]}")
fi

if $debug_mode; then
    printf -v pandoc_cmd_str '%q ' "${pandoc_cmd[@]}"
    echo "[md2pdf|debug] pandoc command:   $pandoc_cmd_str"
fi

# ----------------------------------------------------------------------
# Execute Pandoc (twice for TOC and cross-references)
# ----------------------------------------------------------------------
log_info "Running Pandoc (pass 1/2)..."
"${pandoc_cmd[@]}"
log_info "Running Pandoc (pass 2/2)..."
"${pandoc_cmd[@]}"
status=$?

# ----------------------------------------------------------------------
# Exit status and success message
# ----------------------------------------------------------------------
if [[ $status -ne 0 ]]; then
    echo "[md2pdf|error] Error creating the PDF file."
    exit $status
else
    echo "[md2pdf|success] PDF created: $output"
fi
