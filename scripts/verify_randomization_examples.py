"""Extract the guide's complete examples and verify them with installed XSim.

Run from any directory. Generated compiler products stay under ignored output/.
The Markdown is authoritative: the checked .sv files are exact code-block copies.
"""
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
from fractions import Fraction
import argparse
import hashlib
import json
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
REV = ROOT / 'SV Basics' / 'Revision'
SOURCE = REV / 'Section-6-Randomization.md'
EXAMPLES = REV / 'examples' / 'section-6'
WORK = ROOT / 'output' / 'section-6-randomization' / 'runs'


def extract():
    pattern = r'<!-- example: ([\w-]+\.sv) -->\s*```systemverilog\n(.*?)\n```'
    entries = []
    for name, code in re.findall(pattern, SOURCE.read_text(encoding='utf-8'), re.S):
        module = re.search(r'^module (\w+);', code, re.M).group(1)
        path = EXAMPLES / name
        path.parent.mkdir(parents=True, exist_ok=True)
        content = code + '\n'
        path.write_text(content, encoding='utf-8')
        entries.append((name, module, path,
                        hashlib.sha256(content.encode()).hexdigest()))
    if len(entries) != 8 or len({e[0] for e in entries}) != 8:
        raise ValueError('Expected eight uniquely named complete examples')
    return sorted(entries)


def verify_derived_results():
    domain = set(range(16))
    excluded_a = domain - set(range(3, 8))
    excluded_b = domain - set(range(5, 10))
    assert len(excluded_a) * len(excluded_b) == 121
    assert len((set(range(9)) | {10, 11, 15})) * len(range(3, 12)) == 108
    assert domain & set(range(12, 34)) == {12, 13, 14, 15}
    assert not domain & set(range(16, 34))
    assert [(r,c) for r in range(2) for c in range(2)
            if r != 0 or c == 1] == [(0,1), (1,0), (1,1)]
    assert [(w,o) for w in range(2) for o in range(2)
            if (w == 1) == (o == 0)] == [(0,1), (1,0)]
    pairs = [(w,wa,ra) for w in range(2) for wa in domain for ra in domain
             if ((wa in range(11,16) and ra == 0) if w else ra in range(11,16))]
    assert len(pairs) == 85 and sum(w for w,_,_ in pairs) == 5
    assert Fraction(30,30+3*70) == Fraction(1,8)
    assert Fraction(70,30+3*70) == Fraction(7,24)
    assert Fraction(90,3) == 30
    assert Fraction(30,30+90) == Fraction(1,4)
    return 'PASS: legal sets, truth tables, branch counts, and rational weights'


def verify(entry, vivado):
    name, module, path, sha = entry
    directory = WORK / path.stem
    directory.mkdir(parents=True, exist_ok=True)
    stages = [
        ('compile', [str(vivado/'xvlog.bat'), '-sv', str(path)]),
        ('elaborate', [str(vivado/'xelab.bat'), module, '-s', 'example_sim']),
        ('simulate', [str(vivado/'xsim.bat'), 'example_sim', '-runall']),
    ]
    diagnostics = []
    for stage, command in stages:
        result = subprocess.run(command, cwd=directory, capture_output=True,
                                text=True, errors='replace', timeout=120)
        output = result.stdout + result.stderr
        (directory/(stage+'.log')).write_text(output, encoding='utf-8')
        diagnostics += [line.strip() for line in output.splitlines()
                        if 'WARNING:' in line or 'Warning:' in line]
        if result.returncode or 'ERROR:' in output or 'Fatal:' in output:
            raise RuntimeError(f'{name} {stage} failed:\n{output[-6000:]}')
    if f'PASS {module}' not in output:
        raise RuntimeError(f'{name}: PASS marker missing:\n{output[-4000:]}')
    trace = [line.strip() for line in output.splitlines()
             if line.startswith(('PASS ', 'value=', 'writes=', 'i=', 'external:',
                                 'rst=', 'raddr='))]
    print(name + ': PASS', flush=True)
    return {'file': name, 'module': module, 'sha256': sha,
            'result': 'PASS', 'trace': trace, 'warnings': diagnostics}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--vivado-bin', type=Path,
                        default=Path('C:/Xilinx/Vivado/2024.1/bin'))
    parser.add_argument('--extract-only', action='store_true')
    parser.add_argument('--only', nargs='+', help='Run only these example numbers')
    args = parser.parse_args()
    entries = extract()
    derived = verify_derived_results()
    print(derived, flush=True)
    if args.extract_only:
        return
    if args.only:
        entries = [e for e in entries if e[0][:2] in args.only]
    def checked(entry):
        try:
            return verify(entry, args.vivado_bin)
        except Exception as exc:
            print(entry[0]+': NOT PASSED (see report)', flush=True)
            return {'file': entry[0], 'module': entry[1], 'sha256': entry[3],
                    'result': 'NOT PASSED', 'diagnostic': str(exc)}
    with ThreadPoolExecutor(max_workers=2) as pool:
        results = list(pool.map(checked, entries))
    report = {'simulator': 'AMD Vivado Simulator 2024.1',
              'derived_checks': derived, 'examples': results}
    (WORK/'results.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
    passed = sum(r['result'] == 'PASS' for r in results)
    print(f'{passed}/{len(results)} exact examples passed. See results.json.', flush=True)
    if passed != len(results):
        sys.exit(1)


if __name__ == '__main__':
    main()
