import argparse
import os
import re
import subprocess as sp
from datetime import datetime


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument('--timeline-log')
    return p.parse_args()


def parse_time_intervals(log_path):
    ret = {
        'SCALE UP': {'start': None, 'end': None, 'elapsed': None},
        'COMPUTE PLATEAU': {'start': None, 'end': None, 'elapsed': None},
        'SCALE DOWN': {'start': None, 'end': None, 'elapsed': None},
    }
    pattern = r'(COMPUTE PLATEAU|SCALE UP|SCALE DOWN) TIME IS (STARTING|FINISHED) AT (.*)'
    with open(log_path) as infile:
        for l in infile:
            match = re.search(pattern, l.strip())
            if match:
                phase = match.group(1)
                start_or_end = 'start' if match.group(2) == 'STARTING' else 'end'
                timestamp = datetime.strptime(match.group(3), '%a %b %d %H:%M:%S UTC %Y')
                ret[phase][start_or_end] = timestamp.strftime('%Y-%m-%dT%H:%M:%SZ')

    for phase, phase_dict in ret.items():
        elapsed = {}
        elapsed['start'] = datetime.strptime(phase_dict['start'], '%Y-%m-%dT%H:%M:%SZ')
        elapsed['end'] = datetime.strptime(phase_dict['end'], '%Y-%m-%dT%H:%M:%SZ')
        ret[phase]['elapsed'] = int(round((elapsed['end'] - elapsed['start']).total_seconds() / 60))

    # Ensure correct format of returned list
    assert len(ret) == 3
    for phase, phase_dict in ret.items():
        for start_or_end, ts in phase_dict.items():
            assert ts is not None

    return ret


def main():
    args = parse_args()
    cluster_name = re.search(r'(.*)-timeline-log.txt', os.path.basename(args.timeline_log)).group(1)
    time_interval_dicts = parse_time_intervals(args.timeline_log)
    ingested_dict = {}
    for phase in ['SCALE UP', 'COMPUTE PLATEAU', 'SCALE DOWN']:
        phase_dict = time_interval_dicts[phase]
        cmd_args = ['scripts/get-ingested-data.sh', cluster_name, phase_dict['start'], phase_dict['end']]
        ingested_bytes = int(sp.check_output(cmd_args).decode().strip())
        ingested_MB = ingested_bytes / 1048576
        ingested_dict[phase] = ingested_MB
        print(f"{cluster_name}'s log group ingested {ingested_MB} MB during {phase} that elapsed {phase_dict['elapsed']} min")

    print(f"{cluster_name}'s log group ingested during SCALE UP/SCALE DOWN {round(ingested_dict['SCALE UP'] + ingested_dict['SCALE DOWN'],1 )} MB")
    print(f"{cluster_name}'s log group ingested during COMPUTE PLATEAU per hour {round(ingested_dict['COMPUTE PLATEAU'] * 3, 1)} MB")


if __name__ == '__main__':
    main()
