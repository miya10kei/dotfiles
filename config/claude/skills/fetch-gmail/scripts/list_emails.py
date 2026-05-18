#!/usr/bin/env python3
"""Gmail検索 → メタデータ取得 → スレッドグルーピング → 一覧表示."""

import json
import subprocess
import sys
from collections import defaultdict


def gws(*args: str) -> dict:
    result = subprocess.run(
        ["gws", *args],
        capture_output=True,
        text=True,
    )
    lines = result.stdout.strip().split("\n")
    # skip "Using keyring backend: keyring"
    json_start = next(
        (i for i, l in enumerate(lines) if l.strip().startswith("{")),
        -1,
    )
    if json_start < 0:
        return {}
    return json.loads("\n".join(lines[json_start:]))


def search(query: str, max_results: int) -> list[dict]:
    data = gws(
        "gmail", "users", "messages", "list",
        "--params", json.dumps({
            "userId": "me",
            "q": query,
            "maxResults": max_results,
            "fields": "messages(id,threadId)",
        }),
    )
    return data.get("messages", [])


def get_thread_metadata(thread_id: str) -> dict:
    data = gws(
        "gmail", "users", "threads", "get",
        "--params", json.dumps({
            "userId": "me",
            "id": thread_id,
            "format": "metadata",
            "metadataHeaders": ["Subject", "From", "Date"],
            "fields": "id,messages(id,payload/headers)",
        }),
    )
    return data


def extract_headers(payload: dict) -> dict:
    headers = {}
    for h in payload.get("headers", []):
        headers[h["name"]] = h["value"]
    return headers


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: list_emails.py <query> [max_results]", file=sys.stderr)
        sys.exit(1)

    query = sys.argv[1]
    max_results = int(sys.argv[2]) if len(sys.argv) > 2 else 20

    messages = search(query, max_results)
    if not messages:
        print("該当するメールが見つかりませんでした。")
        sys.exit(0)

    # group by threadId
    threads: dict[str, list[str]] = defaultdict(list)
    order: list[str] = []
    for m in messages:
        tid = m["threadId"]
        if tid not in threads:
            order.append(tid)
        threads[tid].append(m["id"])

    print(f"検索結果: {len(messages)}件 ({len(order)}スレッド)\n")

    for i, tid in enumerate(order, 1):
        meta = get_thread_metadata(tid)
        msgs = meta.get("messages", [])
        total = len(msgs)
        oldest = extract_headers(msgs[0].get("payload", {}))
        newest = extract_headers(msgs[-1].get("payload", {}))

        newest_id = msgs[-1]["id"]
        if total == 1:
            print(f"  {i}. {oldest.get('Date', '')}  {oldest.get('From', '')}")
            print(f"     {oldest.get('Subject', '')}")
            print(f"     id:{newest_id}  thread:{tid}")
        else:
            print(f"  {i}. [スレッド: {total}通] {oldest.get('Subject', '')}")
            print(f"     最新: {newest.get('Date', '')}  {newest.get('From', '')}")
            print(f"     開始: {oldest.get('Date', '')}  {oldest.get('From', '')}")
            print(f"     latest_id:{newest_id}  thread:{tid}")
        print()


if __name__ == "__main__":
    main()
