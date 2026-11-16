#!/usr/bin/env bash
# Adapted from vol.2 scripts/portable-eda.sh; no design or GUI dependency.
set -euo pipefail
image='hpretl/iic-osic-tools@sha256:92961478ad3c4f508efb42d9ccdba12ab262eb42a14926d2bd49862230ba8521'
mode="${1:-versions}"
case "$mode" in setup|versions|sim|gds) ;; *) echo "usage: $0 {setup|versions|sim|gds [jobs]}" >&2; exit 2;; esac
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
[[ "$design" == my_cpu4 ]] || { echo 'Only DESIGN=my_cpu4 is supported.' >&2; exit 2; }
jobs="${2:-2}"
[[ "$jobs" =~ ^[1-9][0-9]*$ ]] || { echo 'jobs must be positive.' >&2; exit 2; }
mkdir -p "$repo_dir/eda/designs/$design/runs"
run_dir="$(mktemp -d "$repo_dir/eda/designs/$design/runs/experiment-${mode}-XXXXXXXX")"
cp "$repo_dir/eda/designs/$design/"{my_cpu4.v,my_cpu4_tb.sv,blocks_tb.sv,my_cpu4.json,my_cpu4.sdc,pin_order.cfg} "$run_dir/"
cp "${BASH_SOURCE[0]}" "$run_dir/runner.sh"
printf 'image=%s\nrepo_commit=%s\nmode=%s\njobs=%s\n' "$image" "$(git -C "$repo_dir" rev-parse HEAD)" "$mode" "$jobs" > "$run_dir/environment.txt"
git -C "$repo_dir" status --porcelain >> "$run_dir/environment.txt"
(cd "$run_dir" && sha256sum *.v *.sv *.json *.sdc *.cfg runner.sh > inputs.sha256)
echo "Outputs: $run_dir"
args=(run --rm --platform linux/amd64 --network none --user "$(id -u):$(id -g)" --entrypoint /bin/bash --mount "type=bind,source=$run_dir,target=/foss/designs" --workdir /foss/designs)
set +e
if [[ "$mode" == sim ]]; then
    docker "${args[@]}" "$image" -lc 'set -euo pipefail; iverilog -g2012 -Wall -Wno-timescale -s blocks_tb -o blocks.out my_cpu4.v blocks_tb.sv; vvp blocks.out; iverilog -g2012 -Wall -Wno-timescale -s my_cpu4_tb -o sim.out my_cpu4.v my_cpu4_tb.sv; vvp sim.out' 2>&1 | tee "$run_dir/console.log"
else
    docker "${args[@]}" "$image" -lc 'set -euo pipefail; source sak-pdk-script.sh sky130A sky130_fd_sc_hd; librelane --manual-pdk --pdk sky130A --scl sky130_fd_sc_hd --jobs "$1" --run-tag implementation --condensed my_cpu4.json' bash "$jobs" 2>&1 | tee "$run_dir/console.log"
fi
result=$?
printf '%s\n' "$result" > "$run_dir/exit_code.txt"
exit "$result"
