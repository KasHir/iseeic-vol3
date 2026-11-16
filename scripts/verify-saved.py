#!/usr/bin/env python3
"""保存した実行結果のハッシュを検査します．EDA ツールは不要です．"""
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ARCHIVE = ROOT / 'eda/archive'


def check(path, digest):
    if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != digest:
        raise SystemExit(f'FAIL: {path.relative_to(ROOT)}')


def main():
    inputs = 0
    for sums in sorted(ARCHIVE.glob('*/*/inputs.sha256')):
        for line in sums.read_text().splitlines():
            digest, name = line.split(maxsplit=1)
            check(sums.parent / name.lstrip('*'), digest)
            inputs += 1
    files = 0
    for line in (ARCHIVE / 'SHA256SUMS').read_text().splitlines():
        digest, name = line.split(maxsplit=1)
        check(ARCHIVE / name.lstrip('*'), digest)
        files += 1
    print(f'PASS: {inputs} archived input hashes, {files} saved result files')


if __name__ == '__main__':
    main()
