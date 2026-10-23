#!/bin/sh
# Slice 176: the controls' outcomes, read from their saved step outputs and run logs (nothing is built or run here).
S=/c/Nyasha_Planet/LMX/build2/opus_fix176
cd $S || exit 1
show () {
    echo "== $1"
    shift
    for f in "$@"; do
        echo "-- $f"
        tr -d '\r' < "$f" | grep -E 'exit=|S81 runtime|S81 a Thin|lmx: invariant|lmx: walk error|lmx: R0 closed without' | sed 's/^/  /'
    done
}
show "Verified175 frontend and runtime (boot-quick-01 of build2/opus_fix175)" runs/ctl-fe175-rt175-native-01.out runs/ctl-fe175-rt175-native-01/run-root0.log runs/ctl-fe175-rt175-native-01/run-root1.log runs/ctl-fe175-rt175-forced-01.out runs/ctl-fe175-rt175-forced-01/run-root0.log runs/ctl-fe175-rt175-forced-01/run-root1.log
show "Verified175 frontend with the 176 runtime rt-01" runs/ctl-fe175-rt176-native-01.out runs/ctl-fe175-rt176-native-01/run-root0.log runs/ctl-fe175-rt176-native-01/run-root1.log runs/ctl-fe175-rt176-forced-01.out runs/ctl-fe175-rt176-forced-01/run-root0.log runs/ctl-fe175-rt176-forced-01/run-root1.log
show "fe-01 (header requirement only) with rt-01: rebuild runtime's smoke" rt-01/smoke/lib_owner-native/run-root0.log rt-01/smoke/lib_owner-native/run-root1.log rt-01/smoke/lib_owner-forced/run-root0.log rt-01/smoke/lib_owner-forced/run-root1.log
show "fe-probe-01 (header requirement and description scope, no described refusal) with rt-01" runs/p176-native-03.out runs/p176-native-03/run-root0.log runs/p176-native-03/run-root1.log runs/p176-forced-03.out runs/p176-forced-03/run-root0.log runs/p176-forced-03/run-root1.log
