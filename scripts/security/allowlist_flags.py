#!/usr/bin/env python3
"""Utility to convert the TruffleHog allowlist YAML into CLI flags."""
from __future__ import annotations

import argparse
import os
from pathlib import Path
from typing import List, Tuple


def parse_allowlist(path: Path) -> Tuple[List[str], List[str]]:
    if not path.exists():
        return [], []

    current = None
    paths: List[str] = []
    detectors: List[str] = []

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("ignored_paths"):
            current = "paths"
            continue
        if line.startswith("ignored_detectors"):
            current = "detectors"
            continue
        if line.startswith("- "):
            value = line[2:].strip()
            if not value:
                continue
            if current == "paths":
                paths.append(value)
            elif current == "detectors":
                detectors.append(value)
    return paths, detectors


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--allowlist",
        default="security/trufflehog-allowlist.yml",
        help="Path to the allowlist YAML file.",
    )
    parser.add_argument(
        "--output",
        required=True,
        help="Path to the file where GitHub Actions outputs should be written.",
    )
    parser.add_argument(
        "--paths-file",
        default="security/.generated/allowlist-paths.txt",
        help="Path to write newline-separated path regexes for --exclude-paths.",
    )
    args = parser.parse_args()

    allowlist_path = Path(args.allowlist)
    output_path = Path(args.output)
    paths_file = Path(args.paths_file)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    paths, detectors = parse_allowlist(allowlist_path)

    paths_flag = ""
    if paths:
        paths_file.parent.mkdir(parents=True, exist_ok=True)
        paths_file.write_text("\n".join(paths), encoding="utf-8")
        paths_flag = f"--exclude-paths {paths_file}"
    else:
        if paths_file.exists():
            paths_file.unlink()

    detectors_flag = f"--exclude-detectors {','.join(detectors)}" if detectors else ""

    with output_path.open("w", encoding="utf-8") as handle:
        handle.write(f"paths_flag={paths_flag}\n")
        handle.write(f"detectors_flag={detectors_flag}\n")
        handle.write(f"paths_file={paths_file if paths else ''}\n")


if __name__ == "__main__":
    main()
