#!/bin/bash

usage()
{
    echo
    echo -e "Usage : disassemble <options> <cmd> <cmd args>"
    exit
}

check_option()
{
    keep_tmp_dir=0
    output_dir=.
    opt_list_short="hd:t" ; 
    opt_list="help,output-dir:,keep-tmp" ; 

    TEMP=$(getopt -o $opt_list_short \
                  -l $opt_list \
                  -n $(basename $0) -- "$@")
    if [ $? != 0 ]; then usage ; fi
    eval set -- "$TEMP"
    if [ $? != 0 ]; then usage ; fi

    while true ; do
        case "$1" in
            -h|--help) usage ;;
            -d|--output-dir) output_dir=$2 ; shift 2;;
            -t|--keep-tmp) keep_tmp_dir=1 ; shift ;;
            --) shift ; break ;;
            *) echo "No option $1."; usage ;;
        esac
    done  
    APP_NAME=$1
    APP_CMD=$@
    if [ -z $APP_CMD ]; then
        echo "Error : No input binary"
        usage
    fi
}

check_option $@

ROCM_PATH=/opt/rocm
ROCM_GPUTARGET=amdgcn-amd-amdhsa
INSTALLED_GPU=$($ROCM_PATH/bin/offload-arch | grep -m 1 -E gfx[^0]{1})
ISA_NAME="$ROCM_GPUTARGET--$INSTALLED_GPU"

WORK_DIR=$PWD
SCRIPT_DIR=$(dirname $0)

TMP_DIR="./tmp"
mkdir $TMP_DIR 2> /dev/null

export LOADER_OPTIONS_APPEND="-dump-code=1 -dump-dir=$TMP_DIR"

echo "> Execute '$WORK_DIR/$APP_CMD'"
echo "> Command output :"
eval "$WORK_DIR/$APP_CMD"

echo "> Disassemble '$APP_CMD' for $ISA_NAME"

FILES="$TMP_DIR/*.hsaco"
for hsaco in $FILES
do
    output_file=$output_dir/$(basename $APP_NAME)_$(basename $hsaco).s
    eval $SCRIPT_DIR/amd-disassembler $hsaco $ISA_NAME $output_file
done

if [ $keep_tmp_dir == 0 ]; then
    rm $TMP_DIR -r
fi
