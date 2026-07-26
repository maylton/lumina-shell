#!/usr/bin/env python3

from __future__ import annotations

import glob
import json
import os
import shutil
import subprocess
import time
from pathlib import Path


def read_text(path: str | Path) -> str:
    try:
        return Path(path).read_text(encoding="utf-8", errors="replace").strip()
    except (OSError, ValueError):
        return ""


def read_number(path: str | Path, fallback: float = 0) -> float:
    try:
        return float(read_text(path))
    except ValueError:
        return fallback


def parse_cpu_stat(text: str) -> dict[str, int]:
    for line in text.splitlines():
        fields = line.split()

        if not fields or fields[0] != "cpu":
            continue

        values = [int(value) for value in fields[1:] if value.isdigit()]
        idle = sum(values[3:5])
        return {"total": sum(values), "idle": idle}

    return {"total": 0, "idle": 0}


def parse_cpuinfo(text: str) -> dict[str, object]:
    model = ""
    physical_cores: set[tuple[str, str]] = set()
    physical_id = "0"
    core_id = ""

    for line in text.splitlines() + [""]:
        if not line.strip():
            if core_id:
                physical_cores.add((physical_id, core_id))
            physical_id = "0"
            core_id = ""
            continue

        key, separator, value = line.partition(":")

        if not separator:
            continue

        key = key.strip()
        value = value.strip()

        if key in ("model name", "Hardware") and not model:
            model = value
        elif key == "physical id":
            physical_id = value
        elif key == "core id":
            core_id = value

    cores = len(physical_cores) or (os.cpu_count() or 1)
    return {
        "model": model or "Processador",
        "cores": cores,
    }


def parse_meminfo(text: str) -> dict[str, int]:
    values: dict[str, int] = {}

    for line in text.splitlines():
        key, separator, raw_value = line.partition(":")

        if not separator:
            continue

        fields = raw_value.strip().split()

        try:
            values[key] = int(fields[0]) * 1024
        except (IndexError, ValueError):
            continue

    total = values.get("MemTotal", 0)
    available = values.get("MemAvailable", values.get("MemFree", 0))
    return {
        "totalBytes": total,
        "availableBytes": available,
        "usedBytes": max(0, total - available),
    }


def parse_default_interface(text: str) -> str:
    lines = text.splitlines()

    for line in lines[1:]:
        fields = line.split()

        if len(fields) < 4:
            continue

        try:
            flags = int(fields[3], 16)
        except ValueError:
            continue

        if fields[1] == "00000000" and flags & 0x2:
            return fields[0]

    return ""


def storage_snapshot(path: str, label: str) -> dict[str, object]:
    try:
        stats = os.statvfs(path)
    except OSError:
        return {
            "label": label,
            "path": path,
            "available": False,
            "usedBytes": 0,
            "totalBytes": 0,
        }

    total = stats.f_blocks * stats.f_frsize
    free = stats.f_bfree * stats.f_frsize
    return {
        "label": label,
        "path": path,
        "available": True,
        "usedBytes": max(0, total - free),
        "totalBytes": total,
    }


def compact_pci_name(text: str) -> str:
    value = text.strip()

    if ": " in value:
        value = value.split(": ", 1)[1]

    if " (rev " in value:
        value = value.split(" (rev ", 1)[0]

    return value or "Placa de vídeo"


def pci_device_name(device_path: Path) -> str:
    slot = ""

    for line in read_text(device_path / "uevent").splitlines():
        if line.startswith("PCI_SLOT_NAME="):
            slot = line.split("=", 1)[1]
            break

    if not slot or not shutil.which("lspci"):
        return "Placa de vídeo"

    try:
        result = subprocess.run(
            ["lspci", "-s", slot],
            check=False,
            capture_output=True,
            text=True,
            timeout=0.5,
        )
    except (OSError, subprocess.TimeoutExpired):
        return "Placa de vídeo"

    return compact_pci_name(result.stdout)


def first_gpu_temperature(device_path: Path) -> float:
    temperatures = []

    for path in glob.glob(str(device_path / "hwmon/hwmon*/temp*_input")):
        value = read_number(path, -1)

        if value >= 0:
            temperatures.append(value / 1000)

    return temperatures[0] if temperatures else -1


def nvidia_snapshot() -> dict[str, object] | None:
    if not shutil.which("nvidia-smi"):
        return None

    try:
        result = subprocess.run(
            [
                "nvidia-smi",
                "--query-gpu=name,utilization.gpu,temperature.gpu,"
                "memory.used,memory.total",
                "--format=csv,noheader,nounits",
            ],
            check=False,
            capture_output=True,
            text=True,
            timeout=0.8,
        )
    except (OSError, subprocess.TimeoutExpired):
        return None

    line = result.stdout.splitlines()[0] if result.stdout.strip() else ""
    fields = [field.strip() for field in line.split(",")]

    if len(fields) < 5:
        return None

    try:
        return {
            "available": True,
            "name": fields[0],
            "usage": float(fields[1]),
            "temperatureC": float(fields[2]),
            "memoryUsedBytes": float(fields[3]) * 1024 * 1024,
            "memoryTotalBytes": float(fields[4]) * 1024 * 1024,
            "memoryLabel": "VRAM",
        }
    except ValueError:
        return None


def drm_gpu_snapshot() -> dict[str, object]:
    candidates = []

    for path_value in glob.glob("/sys/class/drm/card[0-9]/device"):
        path = Path(path_value)
        total = read_number(path / "mem_info_vram_total", 0)
        candidates.append((total, path))

    if not candidates:
        return {
            "available": False,
            "name": "Indisponível",
            "usage": 0,
            "temperatureC": -1,
            "memoryUsedBytes": 0,
            "memoryTotalBytes": 0,
            "memoryLabel": "VRAM",
        }

    _, device = max(candidates, key=lambda candidate: candidate[0])
    return {
        "available": True,
        "name": pci_device_name(device),
        "usage": read_number(device / "gpu_busy_percent", 0),
        "temperatureC": first_gpu_temperature(device),
        "memoryUsedBytes": read_number(
            device / "mem_info_vram_used",
            0,
        ),
        "memoryTotalBytes": read_number(
            device / "mem_info_vram_total",
            0,
        ),
        "memoryLabel": "VRAM",
    }


def memory_hardware() -> dict[str, object]:
    memory_type = ""
    speed = 0

    for dimm in glob.glob(
        "/sys/devices/system/edac/mc/mc*/dimm*"
    ):
        path = Path(dimm)
        memory_type = (
            read_text(path / "dimm_mem_type")
            or read_text(path / "dimm_dev_type")
        )
        speed = int(read_number(path / "dimm_speed", 0))

        if memory_type or speed:
            break

    return {
        "type": memory_type,
        "speedMhz": speed,
    }


def network_snapshot() -> dict[str, object]:
    interface = parse_default_interface(read_text("/proc/net/route"))

    if not interface:
        for path_value in glob.glob("/sys/class/net/*"):
            path = Path(path_value)

            if path.name != "lo" and read_text(path / "operstate") == "up":
                interface = path.name
                break

    base = Path("/sys/class/net") / interface if interface else Path("")
    return {
        "interface": interface,
        "rxBytes": read_number(base / "statistics/rx_bytes", 0)
        if interface else 0,
        "txBytes": read_number(base / "statistics/tx_bytes", 0)
        if interface else 0,
    }


def snapshot() -> dict[str, object]:
    cpu = parse_cpu_stat(read_text("/proc/stat"))
    cpu.update(parse_cpuinfo(read_text("/proc/cpuinfo")))
    memory = parse_meminfo(read_text("/proc/meminfo"))
    memory.update(memory_hardware())
    gpu = nvidia_snapshot() or drm_gpu_snapshot()

    return {
        "timestampMs": int(time.time() * 1000),
        "cpu": cpu,
        "memory": memory,
        "gpu": gpu,
        "storage": [
            storage_snapshot("/", "/ (Root)"),
            storage_snapshot("/home", "/home"),
        ],
        "network": network_snapshot(),
    }


def main() -> None:
    print(json.dumps(snapshot(), ensure_ascii=False, separators=(",", ":")))


if __name__ == "__main__":
    main()
