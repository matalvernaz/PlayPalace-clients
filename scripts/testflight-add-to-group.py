#!/usr/bin/env python3
"""Add a TestFlight build to an external beta group via the App Store Connect API.

Usage: testflight-add-to-group.py <build_number> [--group "group name"]
"""

from __future__ import annotations

import argparse
import json
import base64
import subprocess
import sys
import time
from pathlib import Path

API_KEY_ID = "8LD279H5H9"
API_ISSUER_ID = "4e69fbec-a077-43c2-aea0-55045fe3dddc"
API_KEY_PATH = Path.home() / ".appstoreconnect/private_keys" / f"AuthKey_{API_KEY_ID}.p8"
BUNDLE_ID = "ca.cobd.playpalace.ios"
DEFAULT_GROUP = "playPalace testext"


def b64url(data: bytes | str) -> str:
    if isinstance(data, str):
        data = data.encode()
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()


def generate_jwt() -> str:
    now = int(time.time())
    header = json.dumps(
        {"alg": "ES256", "kid": API_KEY_ID, "typ": "JWT"}, separators=(",", ":")
    )
    payload = json.dumps(
        {
            "iss": API_ISSUER_ID,
            "iat": now,
            "exp": now + 1200,
            "aud": "appstoreconnect-v1",
        },
        separators=(",", ":"),
    )
    signing_input = b64url(header) + "." + b64url(payload)

    der = subprocess.run(
        ["openssl", "dgst", "-sha256", "-sign", str(API_KEY_PATH), "-binary"],
        input=signing_input.encode(),
        capture_output=True,
        check=True,
    ).stdout

    # Convert DER-encoded ECDSA signature to raw r||s (32 bytes each)
    def parse_int(data, offset):
        length = data[offset + 1]
        value = data[offset + 2 : offset + 2 + length]
        while len(value) > 32 and value[:1] == b"\x00":
            value = value[1:]
        return value.rjust(32, b"\x00"), offset + 2 + length

    r, next_off = parse_int(der, 2)
    s, _ = parse_int(der, next_off)
    return signing_input + "." + b64url(r + s)


def api(jwt: str, method: str, path: str, data: dict | None = None) -> dict:
    url = f"https://api.appstoreconnect.apple.com{path}"
    cmd = [
        "curl", "-s", "--globoff",
        "-H", f"Authorization: Bearer {jwt}",
        "-H", "Content-Type: application/json",
    ]
    if data is not None:
        cmd += ["-X", method, "-d", json.dumps(data)]
    elif method != "GET":
        cmd += ["-X", method]
    cmd.append(url)

    result = subprocess.run(cmd, capture_output=True, text=True)
    if not result.stdout.strip():
        return {}
    return json.loads(result.stdout)


def main():
    parser = argparse.ArgumentParser(description="Add a build to a TestFlight beta group")
    parser.add_argument("build_number", help="The build number to add")
    parser.add_argument("--group", default=DEFAULT_GROUP, help="Beta group name")
    parser.add_argument("--notes", default="New build available.", help="What to Test notes for testers")
    parser.add_argument("--max-wait", type=int, default=60, help="Max polling iterations (30s each)")
    args = parser.parse_args()

    if not API_KEY_PATH.exists():
        print(f"Error: API key not found at {API_KEY_PATH}", file=sys.stderr)
        sys.exit(1)

    jwt = generate_jwt()

    # Find the app
    print("Looking up app...")
    resp = api(jwt, "GET", f"/v1/apps?filter[bundleId]={BUNDLE_ID}&fields[apps]=bundleId")
    apps = resp.get("data", [])
    if not apps:
        print(f"Error: Could not find app with bundle ID {BUNDLE_ID}", file=sys.stderr)
        sys.exit(1)
    app_id = apps[0]["id"]
    print(f"App ID: {app_id}")

    # Find the beta group
    resp = api(jwt, "GET", f"/v1/apps/{app_id}/betaGroups?fields[betaGroups]=name")
    group_id = None
    for group in resp.get("data", []):
        if group["attributes"]["name"] == args.group:
            group_id = group["id"]
            break
    if not group_id:
        print(f"Error: Beta group '{args.group}' not found", file=sys.stderr)
        sys.exit(1)
    print(f"Beta group: {args.group} ({group_id})")

    # Wait for build to be processed
    print(f"Waiting for build {args.build_number} to be processed...")
    build_id = None
    for i in range(args.max_wait):
        resp = api(
            jwt, "GET",
            f"/v1/builds?filter[app]={app_id}&filter[version]={args.build_number}"
            f"&fields[builds]=processingState,version",
        )
        for build in resp.get("data", []):
            state = build.get("attributes", {}).get("processingState", "")
            if state == "VALID":
                build_id = build["id"]
                print("Build processed successfully.")
                break
            elif state in ("PROCESSING", "WAITING_FOR_EXPORT_COMPLIANCE"):
                print(f"  Build state: {state} (waiting...)")
        if build_id:
            break
        time.sleep(30)

    if not build_id:
        print(
            f"Build {args.build_number} not ready after waiting. "
            f"Add it to '{args.group}' manually.",
            file=sys.stderr,
        )
        sys.exit(1)

    # Set "What to Test" notes
    print("Setting release notes...")
    resp = api(
        jwt, "GET",
        f"/v1/builds/{build_id}/betaBuildLocalizations?fields[betaBuildLocalizations]=locale,whatsNew",
    )
    localizations = resp.get("data", [])
    if localizations:
        loc_id = localizations[0]["id"]
        api(jwt, "PATCH", f"/v1/betaBuildLocalizations/{loc_id}", {
            "data": {
                "type": "betaBuildLocalizations",
                "id": loc_id,
                "attributes": {"whatsNew": args.notes},
            }
        })
    else:
        api(jwt, "POST", "/v1/betaBuildLocalizations", {
            "data": {
                "type": "betaBuildLocalizations",
                "attributes": {"locale": "en-CA", "whatsNew": args.notes},
                "relationships": {
                    "build": {"data": {"type": "builds", "id": build_id}}
                },
            }
        })

    # Submit for beta review (NOT App Store review)
    print("Submitting for beta review...")
    review_resp = api(jwt, "POST", "/v1/betaAppReviewSubmissions", {
        "data": {
            "type": "betaAppReviewSubmissions",
            "relationships": {
                "build": {"data": {"type": "builds", "id": build_id}}
            },
        }
    })
    errors = review_resp.get("errors", [])
    if errors:
        # Already submitted or already approved is fine
        code = errors[0].get("code", "")
        if "ALREADY" in code.upper() or "EXISTS" in code.upper():
            print("Build already submitted or approved for beta review.")
        else:
            print(f"Warning: Beta review submission issue: {errors[0].get('detail', code)}")
    else:
        print("Submitted for beta review.")

    # Add build to group
    print(f"Adding build to '{args.group}'...")
    api(jwt, "POST", f"/v1/betaGroups/{group_id}/relationships/builds", {
        "data": [{"type": "builds", "id": build_id}]
    })

    print(f"Done! Build {args.build_number} is queued for beta review and will be available to testers once approved.")


if __name__ == "__main__":
    main()
