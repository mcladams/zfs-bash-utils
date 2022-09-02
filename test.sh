#! /bin/bash

tablist() {
    instr=""
    if ( [ $(wc -w <<< $@) -gt 1 ] && [ $(eval $@ >/tmp/result 2>/dev/null ; echo $?) = 0 ] ); then
        instr="$(cat /tmp/result)"
    else
        for arg in "$@"; do
            if [ $(wc -w <<< $arg) = "1" ]; then
              if [ -f "$arg" ]; then
                instr="$(cat $arg) $instr"
              elif [ "$(declare | grep \^$arg\= )" ]; then
                instr="$(eval echo '$'$arg) $instr"
              else
                instr="$arg $instr"
              fi
            else
              if [ $(eval $arg >/tmp/result 2>/dev/null ; echo $?) = 0 ]; then
                instr="$(cat /tmp/result) $instr"
              else
                instr="$arg $instr"
              fi
            fi
        done
    fi
    printf $(echo \\t$instr | sed -E 's/[[:space:]]+/\\n\\t/g') | sort | uniq
}

# display all reverse depends of all manually installed pkgs
ftest() {
    local inpkgs rdep rdepr insrdep inspkg
    if ( [ $(wc -w <<< $@) -gt 1 ] && [ $(eval $@ >/tmp/result 2>/dev/null ; echo $?) = 0 ] ); then
        inpkgs="$(cat /tmp/result)"
    else
        inpkgs=$@
    fi
    echo $inpkgs
    noinsnorevdeps=""
    noinsrevdeps=""
    insrevdeps=""
    for pkg in $inpkgs; do
#        if [ -z "$(apt list $pkg 2>/dev/null | tail -n +2)" ]; then continue; fi
        rdep=$(apt-cache rdepends --no-recommends --no-suggests --no-enhances $pkg | egrep -e '^[ ][ |][[:alpha:]]+' | sed 's/[ ][ |]//g' | sort | uniq)
#        rdepr=$(apt-cache rdepends --no-suggests --no-enhances $pkg | egrep -e '^[ ][ |][[:alpha:]]+' | sed 's/[ ][ |]//g' | sort | uniq)
        if [ -z "$rdep" ]; then
            inspkg=$(dpkg-query -l $pkg 2>/dev/null | egrep -e '^ii' | awk '{ print $2 }')
                if [ -z $inspkg ]; then
                     noinsnorevdeps="$(echo $pkg) $noinsnorevdeps"
                else
                     insnorevdeps="$(echo $inspkg) $insnorevdeps"
                fi
        else
            insrdep=$(dpkg-query -l $rdep 2>/dev/null | egrep -e '^ii' | awk '{ print $2 }')
            insrevdeps="$insrdep $insrevdeps"
        fi
    done
    printf $(echo \\t$insnorevdeps | sed -E 's/[[:space:]]+/\\n\\t/g') | sort | uniq > insnorevdeps.list
    printf $(echo \\t$insnorevdeps | sed -E 's/[[:space:]]+/\\n\\t/g') | sort | uniq >> allinsnorevdeps.list
    printf $(echo \\t$noinsnorevdeps | sed -E 's/[[:space:]]+/\\n\\t/g') | sort | uniq > noinsnorevdeps.list
    printf $(echo \\t$insrevdeps | sed -E 's/[[:space:]]+/\\n\\t/g') | sort | uniq > insrevdeps.list
    apt list $(cat insrevdeps.list) | egrep -e '\[installed\]' | egrep -e '^[^/]+' -o > maninsrevdeps.list
echo; echo "No reverse dependencies:"; cat insnorevdeps.list; echo
echo; echo "No installed reverse depencies:"; cat noinsnorevdeps.list; echo
echo; echo "Manual nstalled reverse depencies:"; cat maninsrevdeps.list; echo
}

