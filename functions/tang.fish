function tang -d "Create and/or attach to tmux session"
    set -l options h/help v/version e/editor
    argparse --max-args 1 $options -- $argv
    or return

    set -l cmd (status current-command)
    set -l tang_help "[-h|--help] [-v|--version] [-e|--editor] [SESSION]"
    set -l tang_version "v0.1.0"

    set -ql _flag_help
    and echo "$cmd $tang_help"
    and return 0

    set -ql _flag_version
    and echo "$cmd $tang_version"
    and return 0

    set -l paths (_tang_get_paths)
    set -l names (_tang_get_names $paths)

    set -q argv[1]
    and set -l name $argv[1]
    or set -l name (string join \n $names | fzf --tac) || return

    set idx (contains -i $name $names)
    and set -l dir $paths[$idx]
    or set -l dir (pwd)

    tmux has-session -t=$name 2>/dev/null || begin
        tmux new-session -ds $name -c $dir -n terminal

        set -ql _flag_editor
        or tmux new-window -dbt "$name:" -c $dir -n editor "fish -C $EDITOR"
    end

    set -q TMUX
    and tmux switch-client -t $name
    or tmux attach-session -t $name
end

function _tang_get_paths
    for path in $tang_paths
        set resolved_path (path resolve $path)
        test -d $resolved_path || continue

        # if directory path ends with trailing slash
        # we use its subdirectiories instead of the directory itself
        if test (string sub -s -1 $path) = /
            for dir in $resolved_path/*
                test -d $dir && echo $dir
            end
        else
            echo $resolved_path
        end
    end
end

function _tang_get_names
    for path in $argv
        set -l name (path basename $path)
        set names $names $name
        echo $name
    end

    for name in (tmux list-sessions -F "#{session_name}" 2>/dev/null)
        contains $name $names
        or echo $name
    end
end
