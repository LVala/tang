function tang -d "Create and/or attach to tmux session"
    argparse --max-args 1 h/help v/version -- $argv
    or return

    set cmd (status current-command)
    if set -ql _flag_help
        echo "$cmd [-h|--help] [-v|--version] [SESSION_NAME]"
        return 0
    end

    if set -ql _flag_version
        echo "$cmd v0.1.0"
        return 0
    end

    set paths (_tang_get_paths)
    set names (_tang_get_names $paths)

    set -q argv[1]
    and set name $argv[1]
    or set name (string join \n $names | fzf --tac) || return

    set idx (contains -i $name $names)
    and set dir $paths[$idx]
    or set dir (pwd)

    _tang_switch_session $name $dir
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

function _tang_switch_session -a name dir
    tmux has-session -t=$name 2>/dev/null || begin
        # could pass "editor" as a argument to command below
        # but I want to be able to exit vim and not kill the tmux window
        tmux new-session -ds $name -c $dir -n editor
        and tmux send-keys -t $name "$EDITOR ." Enter
        and tmux new-window -dt "$name:" -c $dir -n terminal
    end

    set -q TMUX
    and tmux switch-client -t $name
    or tmux attach-session -t $name
end
