#!/bin/bash
# cat >/tmp/demo-space-separated.sh <<'EOF'
# source: https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

demo_space_args() {
# demonstrate an example of parsing space separated positional arguments
    POSITIONAL_ARGS=()

    while [[ $# -gt 0 ]]; do
      case $1 in
        -e|--extension)
          EXTENSION="$2"
          shift # past argument
          shift # past value
          ;;
        -s|--searchpath)
          SEARCHPATH="$2"
          shift # past argument
          shift # past value
          ;;
        --default)
          DEFAULT=YES
          shift # past argument
          ;;
        -*|--*)
          echo "Unknown option $1"
          exit 1
          ;;
        *)
          POSITIONAL_ARGS+=("$1") # save positional arg
          shift # past argument
          ;;
      esac
    done

    set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

    echo "FILE EXTENSION  = ${EXTENSION}"
    echo "SEARCH PATH     = ${SEARCHPATH}"
    echo "DEFAULT         = ${DEFAULT}"
    echo "Number files in SEARCH PATH with EXTENSION:" $(ls -1 "${SEARCHPATH}"/*."${EXTENSION}" | wc -l)

    if [[ -n $1 ]]; then
        echo "Last line of file specified as non-opt/last argument:"
        tail -1 "$1"
    fi
    #EOF
}
# example usage
#./demo-space-separated.sh -e conf -s /etc /etc/hosts
# OR demo_space_args -e conf -s /etc /etc/hosts

#!/bin/bash
# cat >/tmp/demo-equals-separated.sh <<'EOF'

demo-equals-args() {
# demonstrate an example of parsing equals separatedpositional  arguments
    for i in "$@"; do
      case $i in
        -e=*|--extension=*)
          EXTENSION="${i#*=}"
          shift # past argument=value
          ;;
        -s=*|--searchpath=*)
          SEARCHPATH="${i#*=}"
          shift # past argument=value
          ;;
        --default)
          DEFAULT=YES
          shift # past argument with no value
          ;;
        -*|--*)
          echo "Unknown option $i"
          exit 1
          ;;
        *)
          ;;
      esac
    done

    echo "FILE EXTENSION  = ${EXTENSION}"
    echo "SEARCH PATH     = ${SEARCHPATH}"
    echo "DEFAULT         = ${DEFAULT}"
    echo "Number files in SEARCH PATH with EXTENSION:" $(ls -1 "${SEARCHPATH}"/*."${EXTENSION}" | wc -l)

    if [[ -n $1 ]]; then
        echo "Last line of file specified as non-opt/last argument:"
        tail -1 $1
    fi
    #EOF
}
#./demo-equals-separated.sh -e=conf -s=/etc /etc/hosts

####  USE GNU GLIB/UTIL-LINUX ENHANCED GETOPT
#No answer showcases enhanced getopt. And the top-voted answer is misleading: It either ignores -⁠vfd style short options (requested by the OP) or options after positional arguments (also requested by the OP); and it ignores parsing-errors. Instead:

#Use enhanced getopt from util-linux or formerly GNU glibc.1
#It works with getopt_long() the C function of GNU glibc.
#no other solution on this page can do all this:
#handles spaces, quoting characters and even binary in arguments2 (non-enhanced getopt can’t do this)
#it can handle options at the end: script.sh -o outFile file1 file2 -v (getopts doesn’t do this)
#allows =-style long options: script.sh --outfile=fileOut --infile fileIn (allowing both is lengthy if self parsing)
#allows combined short options, e.g. -vfd (real work if self parsing)
#allows touching option-arguments, e.g. -oOutfile or -vfdoOutfile
#Is so old already3 that no GNU system is missing this (e.g. any Linux has it).
#You can test for its existence with: getopt --test → return value 4.
#Other getopt or shell-builtin getopts are of limited use.

#The following calls

    # myscript -vfd ./foo/bar/someFile -o /fizz/someOtherFile
    # myscript -v -f -d -o/fizz/someOtherFile -- ./foo/bar/someFile
    # myscript --verbose --force --debug ./foo/bar/someFile -o/fizz/someOtherFile
    # myscript --output=/fizz/someOtherFile ./foo/bar/someFile -vfd
    # myscript ./foo/bar/someFile -df -v --output /fizz/someOtherFile
#all return

    # verbose: y, force: y, debug: y, in: ./foo/bar/someFile, out: /fizz/someOtherFile
#with the following myscript

##!/bin/bash
myscript() {
    # More safety, by turning some bugs into errors.
    # Without `errexit` you don’t need ! and can replace
    # ${PIPESTATUS[0]} with a simple $?, but I prefer safety.
    set -o errexit -o pipefail -o noclobber -o nounset

    # -allow a command to fail with !’s side effect on errexit
    # -use return value from ${PIPESTATUS[0]}, because ! hosed $?
    ! getopt --test > /dev/null 
    if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
        echo 'I’m sorry, `getopt --test` failed in this environment.'
        exit 1
    fi

    # option --output/-o requires 1 argument
    LONGOPTS=debug,force,output:,verbose
    OPTIONS=dfo:v

    # -regarding ! and PIPESTATUS see above
    # -temporarily store output to be able to check for errors
    # -activate quoting/enhanced mode (e.g. by writing out “--options”)
    # -pass arguments only via   -- "$@"   to separate them correctly
    ! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        # e.g. return value is 1
        #  then getopt has complained about wrong arguments to stdout
        exit 2
    fi
    # read getopt’s output this way to handle the quoting right:
    eval set -- "$PARSED"

    d=n f=n v=n outFile=-
    # now enjoy the options in order and nicely split until we see --
    while true; do
        case "$1" in
            -d|--debug)
                d=y
                shift
                ;;
            -f|--force)
                f=y
                shift
                ;;
            -v|--verbose)
                v=y
                shift
                ;;
            -o|--output)
                outFile="$2"
                shift 2
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Programming error"
                exit 3
                ;;
        esac
    done

    # handle non-option arguments
    if [[ $# -ne 1 ]]; then
        echo "$0: A single input file is required."
        exit 4
    fi

    echo "verbose: $v, force: $f, debug: $d, in: $1, out: $outFile"
}
