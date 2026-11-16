#!/usr/bin/env python3
"""保存した VCD から比較波形の SVG と CSV を生成します．"""
import argparse
import csv
import hashlib
import re
from fractions import Fraction
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
GOOD = ROOT / 'eda/archive/adder_lab/experiment-sim-E32sRH6I/adder4.vcd'
BAD = ROOT / 'eda/archive/adder_lab/experiment-sim-ZAqr3r1q/adder4.vcd'
SIGNALS = {
    'left': 'adder4_tb.left_i',
    'right': 'adder4_tb.right_i',
    'sum': 'adder4_tb.sum_o',
    'expected': 'adder4_tb.check.expected',
}


def read_vcd(path):
    """Read scoped integer signals and exact timestamps from these Icarus VCDs."""
    header, body = path.read_text().split('$enddefinitions $end', 1)
    scale = re.search(r'\$timescale\s+(\d+)\s*(s|ms|us|ns|ps|fs)\s+\$end', header)
    if not scale:
        raise ValueError(f'Missing VCD timescale: {path}')
    ns_per_tick = int(scale[1]) * {
        's': Fraction(10**9), 'ms': Fraction(10**6), 'us': Fraction(1000),
        'ns': Fraction(1), 'ps': Fraction(1, 1000), 'fs': Fraction(1, 10**6),
    }[scale[2]]
    scopes, codes = [], {}
    for line in header.splitlines():
        words = line.split()
        if not words:
            continue
        if words[0] == '$scope':
            scopes.append(words[2])
        elif words[0] == '$upscope':
            scopes.pop()
        elif words[0] == '$var':
            name = '.'.join([*scopes, words[4]])
            if name in SIGNALS.values():
                codes[words[3]] = next(key for key, value in SIGNALS.items() if value == name)
    if set(codes.values()) != set(SIGNALS):
        raise ValueError(f'Missing required scoped signals: {path}')
    changes = {name: [] for name in SIGNALS}
    now = Fraction(0)
    for line in body.splitlines():
        line = line.strip()
        if line.startswith('#'):
            now = int(line[1:]) * ns_per_tick
        elif line.startswith(('b', 'B')):
            value, code = line[1:].split()
            if code in codes:
                if not re.fullmatch('[01]+', value):
                    raise ValueError(f'Unknown logic value in {path}: {line}')
                changes[codes[code]].append((now, int(value, 2)))
    return changes, now


def value_at(changes, name, time, before=False):
    values = [value for tick, value in changes[name]
              if tick < time or (tick == time and not before)]
    if not values:
        raise ValueError(f'No {name} value at {time} ns')
    return values[-1]


def extract():
    good, good_end = read_vcd(GOOD)
    bad, bad_end = read_vcd(BAD)
    if good_end < 4 or bad_end != 4:
        raise ValueError('The saved runs do not cover the expected 0–4 ns comparison')
    for changes in (good, bad):
        if any(0 <= tick < 4 and tick not in range(4)
               for events in changes.values() for tick, _ in events):
            raise ValueError('A signal changes inside an interval drawn as stable')
    samples = []
    for time in range(4):
        for name in ('left', 'right', 'expected'):
            if value_at(good, name, time) != value_at(bad, name, time):
                raise ValueError(f'Run inputs/expectations differ: {name}, {time} ns')
        samples.append({
            'ns': time,
            **{name: value_at(good, name, time) for name in ('left', 'right', 'expected')},
            'good': value_at(good, 'sum', time),
            'bad': value_at(bad, 'sum', time),
        })
    if [(s['left'], s['right']) for s in samples] != [(0, 0), (2, 3), (9, 0), (15, 1)]:
        raise ValueError('The VCD input sequence differs from the published five-case test')
    for sample in samples:
        if sample['expected'] != sample['left'] + sample['right'] or sample['good'] != sample['expected']:
            raise ValueError(f'Unexpected reference result: {sample}')
    if [s['bad'] for s in samples] != [0, 5, 9, 0]:
        raise ValueError('The carry-dropping result differs from the saved experiment')
    # At 4 ns the good run starts its next input in the same simulation time.
    # Show the half-open interval [0, 4), using the values just before comparison.
    if value_at(good, 'sum', 4, before=True) != 16 or value_at(bad, 'sum', 4, before=True) != 0:
        raise ValueError('Unexpected sum immediately before the 4 ns comparison')
    return samples


def render(samples):
    lines = ['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 900 370">',
             '<rect width="900" height="370" fill="white"/>',
             '<g font-family="monospace" font-size="17" fill="black" stroke="none">',
             '<text x="20" y="25">Saved RTL VCD: good vs. drop-carry (decimal values)</text>']
    for i in range(5):
        x = 260 + 140*i
        lines += [f'<text x="{x}" y="60">{i} ns</text>',
                  f'<path d="M{x},70 V310" stroke="#ccc"/>']
    for row, (key, label) in enumerate([('left','left_i'),('right','right_i'),('expected','expected'),('good','sum_o (good)'),('bad','sum_o (drop-carry)')]):
        y=100+45*row
        lines.append(f'<text x="20" y="{y}">{label}</text>')
        for i, sample in enumerate(samples):
            x=260+140*i
            lines += [f'<path d="M{x},{y-20} l5,-5 h130 l5,5 l-5,5 h-130 Z" fill="none" stroke="black"/>',
                      f'<text x="{x+60}" y="{y-13}">{sample[key]}</text>']
    lines += ['<text x="20" y="340">[3,4) ns: expected=16, good=16, drop-carry=0. Failure checked at 4 ns.</text>',
              '</g></svg>']
    return '\n'.join(lines)+'\n'

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check',action='store_true')
    args=parser.parse_args()
    samples=extract()
    out=ROOT/'docs/images/adder-wave-compare.svg'
    csv_path=ROOT/'docs/adder-wave-compare.csv'
    import io
    buf=io.StringIO(newline='')
    writer=csv.writer(buf,lineterminator='\n')
    keys=['ns','left','right','expected','good','bad']
    writer.writerow(keys)
    writer.writerows([[s[k] for k in keys] for s in samples])
    for path, content in [(out,render(samples)),(csv_path,buf.getvalue())]:
        if args.check:
            if not path.exists() or path.read_text()!=content:
                raise SystemExit(f'Out of date: {path.relative_to(ROOT)}')
        else:
            path.parent.mkdir(exist_ok=True,parents=True)
            path.write_text(content)
    print('PASS: saved VCD extraction; SVG/CSV match 0-4 ns')
if __name__=='__main__': main()
