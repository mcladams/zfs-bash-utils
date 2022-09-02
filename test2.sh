#! /bin/bash

tablist2() {
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
ftest2() {
    local inpkgs rdep rdepr insrdep inspkg
    if ( [ $(wc -w <<< $@) -gt 1 ] && [ $(eval $@ >/tmp/result 2>/dev/null ; echo $?) = 0 ] ); then
        inpkgs="$(cat /tmp/result)"
    else
        inpkgs=$@
    fi
    echo $inpkgs
    pkgnordeps=""
    pkgrdeps=""
    rdepsinst=""
    for pkg in $inpkgs; do
#        if [ -z "$(apt list $pkg 2>/dev/null | tail -n +2)" ]; then continue; fi
        rdep=$(apt-cache rdepends --installed --no-recommends --no-suggests --no-enhances $pkg | egrep -e '^[ ][ |][[:alpha:]]+' | sed 's/[ ][ |]//g' | sort | uniq)
#        rdepr=$(apt-cache rdepends --no-suggests --no-enhances $pkg | egrep -e '^[ ][ |][[:alpha:]]+' | sed 's/[ ][ |]//g' | sort | uniq)
        if [ -z "$rdep" ]; then
            pkgnordeps="$pkg $pkgnordeps"
        else
            pkgrdeps="$pkg $pkgrdeps"
            rdepsinst="$rdep $rdepsinst"
        fi
    done
    printf $(echo \\t$pkgnordeps | sed -E 's/[[:space:]]+/\\n\\t/g') | sort | uniq > pkgnordeps.list
    printf $(echo \\t$pkgrdeps | sed -E 's/[[:space:]]+/\\n\\t/g') | sort | uniq >> pkgrdeps.list
    printf $(echo \\t$rdepsinst | sed -E 's/[[:space:]]+/\\n\\t/g') | sort | uniq > rdepsinst.list

    $manrdeps=$(apt list $pkgrdeps | egrep -e '\[installed\]' | egrep -e '^[^/]+' -o)
    $mannordeps=$(apt list $pkgnordeps | egrep -e '\[installed\]' | egrep -e '^[^/]+' -o)
    printf $(echo \\t$pkgnordeps | sed -E 's/[[:space:]]+/\\n\\t/g') | sort | uniq > mannordeps.list
    printf $(echo \\t$pkgrdeps | sed -E 's/[[:space:]]+/\\n\\t/g') | sort | uniq >> manrdeps.list


    manNORdep=""
    manRDEPR=""
    RDEPRinst=""
    for pk in $mannordeps; do
        rdepr=$(apt-cache rdepends --installed --no-suggests --no-enhances $pk | egrep -e '^[ ][ |][[:alpha:]]+' | sed 's/[ ][ |]//g' | sort | uniq)
        if [ -z $rdepr ]; then
            manNORdep="$pk $manNORdep"
        else
            manRDEPR="$pk $manRDEPR"
            RDEPRinst="$rdepr $RDEPRinst"
        fi
    done
    printf $(echo \\t$manNORdep | sed -E 's/[[:space:]]+/\\n\\t/g') | sort | uniq > manNORdep.list
    printf $(echo \\t$manRDEPR | sed -E 's/[[:space:]]+/\\n\\t/g') | sort | uniq > manRDEPR.list
    printf $(echo \\t$RDEPRinst | sed -E 's/[[:space:]]+/\\n\\t/g') | sort | uniq > RDEPRinst.list
    $RDEPRmaninst=$(apt list $(cat RDEPRinst.list) | egrep -e '\[installed\]' | egrep -e '^[^/]+' -o)
    printf $(echo \\t$RDEPRmaninst | sed -E 's/[[:space:]]+/\\n\\t/g') | sort | uniq > RDEPRmaninst.list

echo; echo "Manual installed no reverse depencies:"; cat manNORdep.list; echo
echo; echo "Manual installed only recommended rev depencies:"; cat manRDEPR.list; echo
echo; echo "RDEPR installed recommended rev depencies:"; cat RDEPRinst.list; echo
echo; echo "RDEPR MAN INSTALLED recommended rev depencies:"; cat RDEPRmaninst.list; echo
}
