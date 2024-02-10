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

    for path in $tang_paths
        set resolved_path (path resolve $path)
        test -d $resolved_path || continue

        # if directory path ends with trailing slash
        # we use its subdirectiories instead of the directory itself
        if test (string sub -s -1 $path) = /
            for dir in $resolved_path/*
                test -d $dir && set paths $paths $dir
            end
        else
            set paths $paths $resolved_path
        end
    end

    for path in $paths
        set names $names (path basename $path)
    end

    set -q argv[1]
    and set name $argv[1]
    or set name (string join \n $names | fzf) || return

    set idx (contains -i $name $names) || begin
        echo "$cmd: Session named `$name` is not managed by $cmd" >&2
        return 1
    end

    tmux has-session -t=$name 2>/dev/null || begin
        # could pass "editor" as a argument to command below
        # but I want to be able to exit vim and not kill the tmux window
        set dir $paths[$idx]
        tmux new-session -ds $name -c $dir -n editor
        and tmux send-keys -t $name "$EDITOR ." Enter
        and tmux new-window -dt "$name:" -c $dir -n terminal
    end

    set -q TMUX
    and tmux switch-client -t $name
    or tmux attach-session -t $name
end
