# Bash completion for md2pdf

_md2pdf() {
  local cur prev
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  _md2pdf_templates() {
    local cmd templates
    cmd="${COMP_WORDS[0]}"
    if command -v "$cmd" >/dev/null 2>&1; then
      templates="$("$cmd" --list-templates 2>/dev/null | tr '\n' ' ')"
      printf '%s' "$templates"
    fi
  }

  case "$prev" in
    -o|--output)
      COMPREPLY=( $(compgen -f -- "$cur") )
      return 0
      ;;
    --template)
      local templates
      templates="$(_md2pdf_templates)"
      COMPREPLY=( $(compgen -W "$templates" -- "$cur") $(compgen -f -- "$cur") )
      return 0
      ;;
    --asset-link)
      COMPREPLY=( $(compgen -d -- "$cur") )
      return 0
      ;;
  esac

  local i
  for ((i=0; i<COMP_CWORD; i++)); do
    if [[ "${COMP_WORDS[i]}" == "--" ]]; then
      COMPREPLY=( $(compgen -f -- "$cur") )
      return 0
    fi
  done

  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "-o --output --template --no-crossref --list-templates --asset-link --debug --version --" -- "$cur") )
  else
    COMPREPLY=( $(compgen -f -- "$cur") )
  fi
}

complete -F _md2pdf md2pdf
