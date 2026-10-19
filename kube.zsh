# kex <pod>: bash into a pod. zex <pod> [path]: zsh into a pod, optionally cd to path first.

kex() {
    if [ -n "$1" ]  # Check if a parameter was provided
    then
        kubectl exec -it "$1" -- /bin/bash
    else
        echo "Usage: kex [pod_name]"
    fi
}

zex() {
    if [ -n "$1" ]; then
        if [ -n "$2" ]; then
            kubectl exec -it "$1" -- /bin/zsh -c "cd '$2' && exec /bin/zsh"
        else
            kubectl exec -it "$1" -- /bin/zsh
        fi
    else
        echo "Usage: zex [pod_name] [optional_path]"
    fi
}
