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
# Normalize to a canonical, symlink-free path when the directory already
# exists so identity-sensitive output (e.g. --closure-manifest) is stable
# across equivalent but differently-spelled invocations. Leave the raw
# value untouched when missing so validate_datadir() reports the path the
# user/environment actually specified.
if [[ -d "$datadir" ]]; then
    datadir="$(cd "$datadir" && pwd)"
fi

# ----------------------------------------------------------------------
# Version information
# ----------------------------------------------------------------------
VERSION="0.2.4"
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
  --list-templates        List available template names and exit
  --closure-manifest      Print canonical renderer closure identity (JSON) and exit
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
input=""
output=""
template_selector="default"
template=""
header_includes=""
templates_dir="$datadir/templates"
filters_dir="$datadir/filters"
filters_manifest="$filters_dir/manifest.sh"
list_templates_mode=false
closure_manifest_mode=false
extra_args=()
asset_links=()
asset_symlinks=()
pandoc_filter_args=()

log_msg() {
    local level="$1"; shift
    echo "[md2pdf|$level] $*"
}

log_msg_err() {
    local level="$1"; shift
    echo "[md2pdf|$level] $*" >&2
}

log_info() { log_msg info "$@"; }
# warn/error are diagnostics, not program output: keep stdout reserved for
# actual results (e.g. --closure-manifest JSON, --list-templates names).
log_warn() { log_msg_err warn "$@"; }
log_error() { log_msg_err error "$@"; }

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
    # The manifest is a sourced shell script; guard against it polluting
    # stdout so --closure-manifest output stays pure JSON. Diagnostics on
    # stderr (if any) remain visible.
    # shellcheck source=/dev/null
    if ! source "$filters_manifest" >/dev/null; then
        log_error "Unable to load filter manifest '$filters_manifest'."
        exit 1
    fi

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

# ----------------------------------------------------------------------
# Closure manifest: canonical identity of the effective renderer inputs
# ----------------------------------------------------------------------
sha256_of() {
    local target="$1"
    if [[ ! -f "$target" ]]; then
        log_error "Cannot compute digest: '$target' is missing or not a regular file."
        return 1
    fi
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$target" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$target" | awk '{print $1}'
    else
        log_error "Neither 'sha256sum' nor 'shasum' is available to compute digests."
        return 1
    fi
}

# Minimal but complete JSON string escaper: quotes, backslashes, and all
# C0 control characters (required by the JSON spec; anything else is
# passed through unmodified).
json_escape() {
    local s="$1" out="" c code esc
    local i len=${#s}
    for (( i=0; i<len; i++ )); do
        c="${s:i:1}"
        case "$c" in
            '"') out+='\"' ;;
            '\\') out+='\\\\' ;;
            *)
                printf -v code '%d' "'$c"
                if (( code < 32 )); then
                    case "$code" in
                        8) out+='\b' ;;
                        9) out+='\t' ;;
                        10) out+='\n' ;;
                        12) out+='\f' ;;
                        13) out+='\r' ;;
                        *) printf -v esc '\\u%04x' "$code"; out+="$esc" ;;
                    esac
                else
                    out+="$c"
                fi
                ;;
        esac
    done
    printf '%s' "$out"
}

# Print a bundled asset path relative to datadir (installation-independent
# and stable across install prefixes); pass through unchanged otherwise,
# e.g. an explicit --template path outside datadir, where the absolute
# path is itself part of the effective selection.
rel_to_datadir() {
    local target="$1"
    if [[ "$target" == "$datadir"/* ]]; then
        printf '%s\n' "${target#"$datadir"/}"
    else
        printf '%s\n' "$target"
    fi
}

# First line of "<name> --version" under a fixed locale, so the canonical
# manifest does not vary with the caller's LANG/LC_ALL.
tool_version() {
    local name="$1" out
    if ! out="$(LC_ALL=C "$name" --version 2>&1)"; then
        return 1
    fi
    printf '%s\n' "${out%%$'\n'*}"
}

print_closure_manifest() {
    local script_sha manifest_sha template_sha header_sha
    local pandoc_version pandoc_crossref_version pdf_engine_version
    local manifest_rel template_rel header_rel
    local filters_json="" first=true
    local filter_file filter_path filter_sha

    if ! script_sha="$(sha256_of "$script_path")"; then exit 1; fi
    if ! manifest_sha="$(sha256_of "$filters_manifest")"; then exit 1; fi
    if ! template_sha="$(sha256_of "$template")"; then exit 1; fi
    if ! header_sha="$(sha256_of "$header_includes")"; then exit 1; fi

    if ! pandoc_version="$(tool_version pandoc)"; then
        log_error "Unable to determine Pandoc version for closure manifest."
        exit 1
    fi
    if ! pdf_engine_version="$(tool_version pdflatex)"; then
        log_error "Unable to determine PDF engine (pdflatex) version for closure manifest."
        exit 1
    fi
    if ! pandoc_crossref_version="$(tool_version pandoc-crossref)"; then
        log_error "Unable to determine pandoc-crossref version for closure manifest."
        exit 1
    fi
    # pandoc-include exposes no --version/--help (it only speaks the
    # Pandoc JSON filter protocol on stdin), so no reliable version string
    # exists to report here. check_dependencies() already fails closed
    # if the executable itself is missing.

    manifest_rel="$(rel_to_datadir "$filters_manifest")"
    template_rel="$(rel_to_datadir "$template")"
    header_rel="$(rel_to_datadir "$header_includes")"

    for filter_file in "${MD2PDF_FILTER_FILES[@]}"; do
        filter_path="$filters_dir/$filter_file"
        if ! filter_sha="$(sha256_of "$filter_path")"; then exit 1; fi
        if $first; then first=false; else filters_json+=","; fi
        filters_json+=$'\n'"    { \"path\": \"$(json_escape "$(rel_to_datadir "$filter_path")")\", \"sha256\": \"$filter_sha\" }"
    done

    cat <<EOF
{
  "schema": "md2pdf.closure-manifest/v1",
  "script_sha256": "$script_sha",
  "filters_manifest": { "path": "$(json_escape "$manifest_rel")", "sha256": "$manifest_sha" },
  "filters": [$filters_json
  ],
  "template": { "path": "$(json_escape "$template_rel")", "sha256": "$template_sha" },
  "header_includes": { "path": "$(json_escape "$header_rel")", "sha256": "$header_sha" },
  "pandoc_version": "$(json_escape "$pandoc_version")",
  "pandoc_crossref_version": "$(json_escape "$pandoc_crossref_version")",
  "pdf_engine": "pdflatex",
  "pdf_engine_version": "$(json_escape "$pdf_engine_version")"
}
EOF
}


check_dependencies() {
    local missing=()
    local required=(pandoc pdflatex pandoc-include pandoc-crossref)
    local dep

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
        --list-templates)
            list_templates_mode=true
            ;;
        --closure-manifest)
            closure_manifest_mode=true
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

if $list_templates_mode && $closure_manifest_mode; then
    log_error "'--list-templates' and '--closure-manifest' are mutually exclusive."
    exit 1
fi

if $list_templates_mode; then
    list_available_templates | sort -u
    exit 0
fi

resolve_template_config "$template_selector"
build_filter_args

if $closure_manifest_mode; then
    check_dependencies
    print_closure_manifest
    exit 0
fi

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
    --metadata listings=true
    --resource-path="$input_path"
    "$input_file" -o "$output"
)

pandoc_cmd+=(-F pandoc-include)
pandoc_cmd+=("${pandoc_filter_args[@]}")
pandoc_cmd+=(-F pandoc-crossref)

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
# Execute Pandoc
# Pandoc invokes pdflatex and re-runs it automatically when LaTeX
# signals that labels or cross-references changed ("Rerun to get
# cross-references right").  A single pandoc call is therefore
# sufficient; a second external call would only double the work.
# ----------------------------------------------------------------------
_t_start=$SECONDS
log_info "Running Pandoc..."
"${pandoc_cmd[@]}"
status=$?
_t_elapsed=$(( SECONDS - _t_start ))

# ----------------------------------------------------------------------
# Exit status and success message
# ----------------------------------------------------------------------
if [[ $status -ne 0 ]]; then
    echo "[md2pdf|error] Error creating the PDF file."
    exit $status
else
    echo "[md2pdf|success] PDF created: $output (${_t_elapsed}s)"
fi
