#!/usr/bin/env bash
# Adapted from vol.2 scripts/portable-eda.sh; no design or GUI dependency.
set -euo pipefail
image='hpretl/iic-osic-tools@sha256:92961478ad3c4f508efb42d9ccdba12ab262eb42a14926d2bd49862230ba8521'
mode="${1:-versions}"
case "$mode" in setup|versions|sim|synth|synth-sky130|gds) ;; *) echo "usage: $0 {setup|versions|sim|synth|synth-sky130|gds [jobs]}" >&2; exit 2;; esac
command -v docker >/dev/null || { echo 'Enable Docker Desktop WSL integration first.' >&2; exit 1; }
docker info >/dev/null
if [[ "$mode" == setup ]]; then
    docker image inspect "$image" >/dev/null 2>&1 || docker pull --platform linux/amd64 "$image"
    echo 'Pinned EDA image ready. Next: make env-check'
    exit 0
fi
docker image inspect "$image" >/dev/null 2>&1 || { echo 'Run make setup first.' >&2; exit 1; }
printf 'image=%s\n' "$image"
if [[ "$mode" == versions ]]; then
exec docker run --rm --platform linux/amd64 --network none --user "$(id -u):$(id -g)" --entrypoint /bin/bash "$image" -lc '
set -euo pipefail
iverilog -V
vvp -V
librelane --version
yosys -V
cat /foss/pdks/sky130A/SOURCES
'
fi
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
design="${DESIGN:-my_cpu4}"
case "$design" in
    my_cpu4) [[ "$mode" != synth && "$mode" != synth-sky130 ]] || { echo 'synthesis experiments support adder_lab only.' >&2; exit 2; } ;;
    adder_lab)
        [[ "$mode" == sim || "$mode" == synth || "$mode" == synth-sky130 ]] || { echo 'adder_lab supports sim and synthesis experiments only.' >&2; exit 2; }
        adder_test="${ADDER_TEST:-five}"
        adder_variant="${ADDER_VARIANT:-good}"
        case "$adder_test" in
            one) test_top=adder4_one_tb; test_file=adder4_one_tb.sv ;;
            five) test_top=adder4_tb; test_file=adder4_tb.sv ;;
            *) echo 'ADDER_TEST must be one or five.' >&2; exit 2 ;;
        esac
        case "$adder_variant" in
            good) rtl_file=adder4.v ;;
            drop-carry) rtl_file=adder4_drop_carry.v ;;
            *) echo 'ADDER_VARIANT must be good or drop-carry.' >&2; exit 2 ;;
        esac
        ;;
    *) echo 'DESIGN must be my_cpu4 or adder_lab.' >&2; exit 2 ;;
esac
jobs="${2:-2}"
[[ "$jobs" =~ ^[1-9][0-9]*$ ]] || { echo 'jobs must be positive.' >&2; exit 2; }
mkdir -p "$repo_dir/eda/designs/$design/runs"
run_dir="$(mktemp -d "$repo_dir/eda/designs/$design/runs/experiment-${mode}-XXXXXXXX")"
if [[ "$design" == my_cpu4 ]]; then
    cp "$repo_dir/eda/designs/$design/"{my_cpu4.v,my_cpu4_tb.sv,blocks_tb.sv,my_cpu4.json,my_cpu4.sdc,pin_order.cfg} "$run_dir/"
else
    cp "$repo_dir/eda/designs/$design/"{adder4.v,adder4_one_tb.sv,adder4_tb.sv,adder4_drop_carry.v} "$run_dir/"
fi
cp "${BASH_SOURCE[0]}" "$run_dir/runner.sh"
printf 'image=%s\nrepo_commit=%s\nmode=%s\njobs=%s\n' "$image" "$(git -C "$repo_dir" rev-parse HEAD)" "$mode" "$jobs" > "$run_dir/environment.txt"
printf 'design=%s\n' "$design" >> "$run_dir/environment.txt"
if [[ "$design" == adder_lab ]]; then
    printf 'adder_test=%s\nadder_variant=%s\n' "$adder_test" "$adder_variant" >> "$run_dir/environment.txt"
fi
git -C "$repo_dir" status --porcelain >> "$run_dir/environment.txt"
(cd "$run_dir" && shopt -s nullglob && sha256sum *.v *.sv *.json *.sdc *.cfg runner.sh > inputs.sha256)
echo "Outputs: $run_dir"
args=(run --rm --platform linux/amd64 --network none --user "$(id -u):$(id -g)" --entrypoint /bin/bash --mount "type=bind,source=$run_dir,target=/foss/designs" --workdir /foss/designs)
set +e
if [[ "$mode" == sim ]]; then
    if [[ "$design" == adder_lab ]]; then
        docker "${args[@]}" "$image" -lc 'set -euo pipefail; iverilog -g2012 -Wall -Wno-timescale -s "$1" -o sim.out "$2" "$3"; vvp sim.out' bash "$test_top" "$rtl_file" "$test_file" 2>&1 | tee "$run_dir/console.log"
    else
        docker "${args[@]}" "$image" -lc 'set -euo pipefail; iverilog -g2012 -Wall -Wno-timescale -s blocks_tb -o blocks.out my_cpu4.v blocks_tb.sv; vvp blocks.out; iverilog -g2012 -Wall -Wno-timescale -s my_cpu4_tb -o sim.out my_cpu4.v my_cpu4_tb.sv; vvp sim.out' 2>&1 | tee "$run_dir/console.log"
    fi
elif [[ "$mode" == synth ]]; then
    docker "${args[@]}" "$image" -lc 'set -euo pipefail; yosys -p "read_verilog adder4.v; synth -top adder4; stat; write_verilog -noattr adder4_gates.v; show -format dot -prefix adder4_gates adder4"' 2>&1 | tee "$run_dir/console.log"
elif [[ "$mode" == synth-sky130 ]]; then
    docker "${args[@]}" "$image" -lc 'set -euo pipefail; lib=/foss/pdks/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib; yosys -p "read_verilog adder4.v; synth -top adder4 -noabc; abc -liberty $lib; clean; stat -liberty $lib; write_verilog -noattr adder4_sky130.v; read_liberty -lib -ignore_miss_func $lib; show -format dot -prefix adder4_sky130 adder4"' 2>&1 | tee "$run_dir/console.log"
else
    docker "${args[@]}" "$image" -lc 'set -euo pipefail; source sak-pdk-script.sh sky130A sky130_fd_sc_hd; librelane --manual-pdk --pdk sky130A --scl sky130_fd_sc_hd --jobs "$1" --run-tag implementation --condensed my_cpu4.json' bash "$jobs" 2>&1 | tee "$run_dir/console.log"
fi
result=$?
printf '%s\n' "$result" > "$run_dir/exit_code.txt"
exit "$result"
