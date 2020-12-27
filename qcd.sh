#!/bin/bash
input_1=$1
input_2=$2

cur_script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cur_script_name=$(basename $BASH_SOURCE)
cur_script_path="${cur_script_dir}/${cur_script_name}"
qdir_path="${cur_script_dir}/qdir"

function show_all_dir {
    cat $qdir_path
}
if [ -z "$input_1" ]; then
    echo "invalid dir shortcut: it must be a key below"
    show_all_dir
    return
fi

register_autocompletion()
{
    #echo "register following completion for command qcd"
    # cur_script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    complete_list=
    while read line;
    do
        key="$(cut -d' ' -f1 <<<"$line")"  #get first field seperated by space
        complete_list+="${key} "
    done <$qdir_path
    complete_list+="show"
    #echo $complete_list
    complete -W "${complete_list}" qcd
}

case $input_1 in 
    "show")
        show_all_dir
        ;;
    "rc")
        register_autocompletion
        ;;
    "cur")
        if [ -z "$input_2" ]; then
            echo "require a quick instruction for current dir, e.g.: qcd cur home"
            return
        fi
        if [ ! -f "$qdir_path" ]; then
            touch $qdir_path
        else 
            while read line; do
            key="$(cut -d' ' -f1 <<<"$line")"  #get first field seperated by space
            if [ $input_2 == $key ]
            then
                echo "instruction ${input_2} has been registered, please change another one!"
                return
            fi
            done <$qdir_path
        fi
        pwd=$(pwd)
        # last_path_idx=$(cut -d' ' -f1 <<<$(tail -n 1 ${qdir_path}))
        # cur_path_idx=$(($last_path_idx+1))
        echo "${input_2} ${pwd}" >>$qdir_path
        register_autocompletion
	    show_all_dir
        ;;
    "rm")
        if [ -z "$input_2" ]; then
            echo "require a quick instruction to remove, e.g.: qcd rm home"
            return
        fi
        if [ ! -f "$qdir_path" ]; then
            echo "no instruction has been registered"
            return
        else
            n=0
            while read line; do
            ((n=n+1))
            key="$(cut -d' ' -f1 <<<"$line")"
            if [ $input_2 == $key ]
            then
                sed -i "${n}d" $qdir_path
                register_autocompletion
	            show_all_dir
                return
            fi
            done <$qdir_path
            echo "instruction ${input_2} not found"
        fi
        ;;
    *)
        while read line; do
        key="$(cut -d' ' -f1 <<<"$line")"
        if [ $input_1 == $key ]
        then
            cd "$(cut -d' ' -f2 <<<"$line")"   #get second field seperated by space
            pwd
        fi
        done <$qdir_path
        ;;
esac
