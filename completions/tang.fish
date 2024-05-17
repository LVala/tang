complete -c tang -f
complete -c tang -s h -l help -d "Print help"
complete -c tang -s v -l version -d "Print version"
complete -c tang -s e -l editor -d "Crate an editor window alongside the terminal window"
complete -c tang -a "(_tang_get_names (_tang_get_paths))"
