#!/usr/bin/python3

import datetime
import os
import subprocess
import sys
from pathlib import Path


BUILDERS_LIST = Path.home() / ".config/qubes-builder-github/builders.list"
GITHUB_COMMAND = "/usr/local/lib/qubes-builder-github/github-command.py"


def main():
    if len(sys.argv) != 2:
        raise ValueError("Provide Qubes OS release! For example '4.2'.")

    release = sys.argv[1]
    release_name = f"r{release}"
    timestamp = datetime.datetime.now(datetime.UTC).strftime("%Y%m%d%H%M")
    iso_version = f"{release}.{timestamp}"

    for line in BUILDERS_LIST.read_text().splitlines():
        builder_release_name, builder_dir_str, builder_conf = line.split("=")
        if builder_release_name != release_name:
            continue
        if not Path(builder_dir_str).exists():
            continue
        cmd = [
            GITHUB_COMMAND,
            "action",
            "--no-signer-github-command-check",
            "build-iso",
            builder_dir_str,
            builder_conf,
            iso_version,
            timestamp,
        ]
        subprocess.Popen(cmd, env={
            "PYTHONPATH": f"{builder_dir_str}:{os.environ.get('PYTHONPATH', '')}",
            **os.environ,
        })


if __name__ == "__main__":
    main()
