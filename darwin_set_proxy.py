"""
Set proxy for nix-daemon to speed up downloads
You can safely ignore this file if you don't need a proxy.

https://github.com/NixOS/nix/issues/1472#issuecomment-1532955973
"""

import argparse
import os
import plistlib
import shlex
import subprocess
from pathlib import Path
from urllib.parse import urlparse

import requests

NIX_DAEMON_PLIST = Path("/Library/LaunchDaemons/org.nixos.nix-daemon.plist")
PLIST = plistlib.loads(NIX_DAEMON_PLIST.read_bytes())


def is_valid_proxy(proxy_url):
    try:
        # validate url
        parsed = urlparse(proxy_url)
        if not parsed.scheme or not parsed.netloc:
            print(f"Parse URL failed: {parsed}")
            return False

        # test connection
        proxies = {"http": proxy_url, "https": proxy_url}
        response = requests.get("https://cache.nixos.org", proxies=proxies, timeout=5)
        return response.status_code == 200
    except requests.RequestException as e:
        print(f"{e}")
        return False


def update_plist():
    os.chmod(NIX_DAEMON_PLIST, 0o644)
    NIX_DAEMON_PLIST.write_bytes(plistlib.dumps(PLIST))
    os.chmod(NIX_DAEMON_PLIST, 0o444)


def reload_daemon():
    # reload the plist
    for cmd in (
        f"launchctl unload {NIX_DAEMON_PLIST}",
        f"launchctl load {NIX_DAEMON_PLIST}",
    ):
        print(cmd)
        subprocess.run(shlex.split(cmd), capture_output=False)


def set_proxy(proxy_url):
    if not is_valid_proxy(proxy_url):
        raise ValueError(f"Invalid proxy address: {proxy_url}")

    if "EnvironmentVariables" not in PLIST:
        PLIST["EnvironmentVariables"] = {}
    # set http/https proxy
    # NOTE: curl only accept the lowercase of `http_proxy`!
    # NOTE: https://curl.se/libcurl/c/libcurl-env.html
    PLIST["EnvironmentVariables"]["http_proxy"] = proxy_url
    PLIST["EnvironmentVariables"]["https_proxy"] = proxy_url
    update_plist()
    reload_daemon()


def unset_proxy():
    if "EnvironmentVariables" not in PLIST:
        return
    # remove http proxy
    PLIST["EnvironmentVariables"].pop("http_proxy", None)
    PLIST["EnvironmentVariables"].pop("https_proxy", None)
    update_plist()
    reload_daemon()


def main():
    parser = argparse.ArgumentParser(description="Set or unset proxy for nix-daemon")
    parser.add_argument(
        "action",
        choices=["set", "unset"],
        help="Choose whether to set or unset the proxy",
    )
    parser.add_argument(
        "-p",
        "--proxy",
        help="http proxy address (e.g., http://127.0.0.1:7890)",
        required=False,
    )

    args = parser.parse_args()

    if args.action == "set":
        if not args.proxy:
            parser.error("--proxy is required")
        set_proxy(args.proxy)
    else:
        unset_proxy()


if __name__ == "__main__":
    main()
