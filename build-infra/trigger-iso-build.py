#!/usr/bin/python3

import datetime
import subprocess
import sys
import tempfile


def main():
    if len(sys.argv) != 2:
        raise ValueError("Provide Qubes OS release! For example '4.2'.")

    release = sys.argv[1]
    timestamp = datetime.datetime.now(datetime.UTC).strftime("%Y%m%d%H%M")
    with tempfile.TemporaryDirectory() as tmpdir:

        with open(f"{tmpdir}/timestamp", "w") as f:
            f.write(timestamp)

        with open(f"{tmpdir}/command", "w") as f:
            f.write(f"Build-iso r{release} {release}.{timestamp} {timestamp}")

        cmd = [
            str(f"/usr/local/lib/qubes-builder-github/github-command.py"),
            "--no-signer-github-command-check",
            "Build-iso",
            f"{tmpdir}/command",
        ]

        subprocess.Popen(cmd)


if __name__ == "__main__":
    main()
