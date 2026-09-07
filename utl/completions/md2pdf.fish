# Fish completion for md2pdf

function __fish_md2pdf_templates
    md2pdf --list-templates 2>/dev/null
end

complete -c md2pdf -s o -l output -r -a "(__fish_complete_path)" -d "Output PDF"
complete -c md2pdf -l template -r -a "(__fish_md2pdf_templates) (__fish_complete_path)" -d "Template name or .tex path"
complete -c md2pdf -l list-templates -d "List available template names and exit"
complete -c md2pdf -l closure-manifest -d "Print canonical renderer-closure identity (JSON) and exit"
complete -c md2pdf -l asset-link -r -a "(__fish_complete_directories)" -d "Symlink asset directory into input folder"
complete -c md2pdf -l debug -d "Enable debug output"
complete -c md2pdf -l version -d "Show version and exit"
