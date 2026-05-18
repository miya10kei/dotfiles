#!/usr/bin/env python3
"""メールID or スレッドIDを受け取り、本文をデコードして表示."""

import base64
import json
import subprocess
import sys
from html.parser import HTMLParser


def gws(*args: str) -> dict:
    result = subprocess.run(
        ["gws", *args],
        capture_output=True,
        text=True,
    )
    lines = result.stdout.strip().split("\n")
    json_start = next(
        (i for i, l in enumerate(lines) if l.strip().startswith("{")),
        0,
    )
    return json.loads("\n".join(lines[json_start:]))


class HTMLTextExtractor(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self._text: list[str] = []

    def handle_data(self, data: str) -> None:
        self._text.append(data)

    def get_text(self) -> str:
        return "".join(self._text)


def decode_base64url(data: str) -> str:
    padded = data + "=" * (4 - len(data) % 4)
    return base64.urlsafe_b64decode(padded).decode("utf-8", errors="replace")


def extract_body(payload: dict) -> str:
    """再帰的に text/plain → text/html の順で本文を探す."""
    # direct body
    body_data = payload.get("body", {}).get("data")
    if body_data and payload.get("mimeType") == "text/plain":
        return decode_base64url(body_data)

    # multipart
    parts = payload.get("parts", [])
    # first pass: text/plain
    for part in parts:
        if part.get("mimeType") == "text/plain":
            data = part.get("body", {}).get("data")
            if data:
                return decode_base64url(data)
        # nested multipart
        if part.get("parts"):
            result = extract_body(part)
            if result:
                return result

    # second pass: text/html
    for part in parts:
        if part.get("mimeType") == "text/html":
            data = part.get("body", {}).get("data")
            if data:
                extractor = HTMLTextExtractor()
                extractor.feed(decode_base64url(data))
                return extractor.get_text()

    # fallback: direct body regardless of mimeType
    if body_data:
        return decode_base64url(body_data)

    return "(本文を取得できませんでした)"


def extract_headers(payload: dict) -> dict:
    headers = {}
    for h in payload.get("headers", []):
        headers[h["name"]] = h["value"]
    return headers


def format_message(payload: dict, index: int | None = None, total: int | None = None) -> str:
    headers = extract_headers(payload)
    body = extract_body(payload)

    if index is not None and total is not None:
        sep = f"━━━━ {index}/{total} ━━━━━━━━━━━━━━━"
    else:
        sep = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    return (
        f"{sep}\n"
        f"From: {headers.get('From', '')}  Date: {headers.get('Date', '')}\n"
        f"Subject: {headers.get('Subject', '')}\n"
        f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        f"{body}"
    )


def read_message(message_id: str) -> None:
    data = gws(
        "gmail", "users", "messages", "get",
        "--params", json.dumps({
            "userId": "me",
            "id": message_id,
            "format": "full",
            "fields": "id,payload(headers,body,parts,mimeType)",
        }),
    )
    print(format_message(data.get("payload", {})))


def read_thread(thread_id: str) -> None:
    data = gws(
        "gmail", "users", "threads", "get",
        "--params", json.dumps({
            "userId": "me",
            "id": thread_id,
            "format": "full",
            "fields": "id,messages(id,payload(headers,body,parts,mimeType))",
        }),
    )
    messages = data.get("messages", [])
    total = len(messages)
    for i, msg in enumerate(messages, 1):
        print(format_message(msg.get("payload", {}), i, total))
        if i < total:
            print()


def main() -> None:
    if len(sys.argv) < 3:
        print("Usage: read_email.py <message|thread> <ID>", file=sys.stderr)
        sys.exit(1)

    mode = sys.argv[1]
    target_id = sys.argv[2]

    if mode == "message":
        read_message(target_id)
    elif mode == "thread":
        read_thread(target_id)
    else:
        print(f"Unknown mode: {mode}. Use 'message' or 'thread'.", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
