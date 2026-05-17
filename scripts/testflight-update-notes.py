#!/usr/bin/env python3
"""Update the "What to Test" release notes on a TestFlight build.

Usage: testflight-update-notes.py <build_number> --notes "..."

Prints the build's current beta-review state alongside the update so the
caller knows whether the notes are still editable (notes can be updated
right up until — and after — beta approval; only the binary is locked
in by review).
"""

from __future__ import annotations

import argparse
import base64
import json
import subprocess
import sys
import time
from pathlib import Path

API_KEY_ID = "8LD279H5H9"
API_ISSUER_ID = "4e69fbec-a077-43c2-aea0-55045fe3dddc"
API_KEY_PATH = Path.home() / ".appstoreconnect/private_keys" / f"AuthKey_{API_KEY_ID}.p8"
BUNDLE_ID = "ca.cobd.playpalace.ios"


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


def main() -> None:
    parser = argparse.ArgumentParser(description="Update TestFlight release notes for a build")
    parser.add_argument("build_number", help="The build number to update")
    parser.add_argument("--notes", required=True, help="Replacement What-to-Test text")
    parser.add_argument("--locale", default="en-CA", help="Locale to create if missing")
    args = parser.parse_args()

    if not API_KEY_PATH.exists():
        print(f"Error: API key not found at {API_KEY_PATH}", file=sys.stderr)
        sys.exit(1)

    jwt = generate_jwt()

    resp = api(jwt, "GET", f"/v1/apps?filter[bundleId]={BUNDLE_ID}&fields[apps]=bundleId")
    apps = resp.get("data", [])
    if not apps:
        print(f"Error: app {BUNDLE_ID} not found", file=sys.stderr)
        sys.exit(1)
    app_id = apps[0]["id"]

    resp = api(
        jwt, "GET",
        f"/v1/builds?filter[app]={app_id}&filter[version]={args.build_number}"
        f"&fields[builds]=processingState,version",
    )
    builds = resp.get("data", [])
    if not builds:
        print(f"Error: build {args.build_number} not found for app {app_id}", file=sys.stderr)
        sys.exit(1)
    build_id = builds[0]["id"]
    print(f"Build {args.build_number} -> id {build_id}, processing={builds[0]['attributes']['processingState']}")

    review = api(
        jwt, "GET",
        f"/v1/builds/{build_id}/betaAppReviewSubmission?fields[betaAppReviewSubmissions]=betaReviewState",
    )
    review_data = review.get("data")
    if review_data:
        state = review_data.get("attributes", {}).get("betaReviewState", "UNKNOWN")
        print(f"Beta review state: {state}")
    else:
        print("Beta review state: not yet submitted")

    resp = api(
        jwt, "GET",
        f"/v1/builds/{build_id}/betaBuildLocalizations?fields[betaBuildLocalizations]=locale,whatsNew",
    )
    localizations = resp.get("data", [])
    if localizations:
        loc = localizations[0]
        loc_id = loc["id"]
        print(f"Updating existing localization {loc_id} ({loc['attributes'].get('locale')})...")
        api(jwt, "PATCH", f"/v1/betaBuildLocalizations/{loc_id}", {
            "data": {
                "type": "betaBuildLocalizations",
                "id": loc_id,
                "attributes": {"whatsNew": args.notes},
            }
        })
    else:
        print(f"Creating new localization ({args.locale})...")
        api(jwt, "POST", "/v1/betaBuildLocalizations", {
            "data": {
                "type": "betaBuildLocalizations",
                "attributes": {"locale": args.locale, "whatsNew": args.notes},
                "relationships": {
                    "build": {"data": {"type": "builds", "id": build_id}}
                },
            }
        })

    print("Done.")


if __name__ == "__main__":
    main()
