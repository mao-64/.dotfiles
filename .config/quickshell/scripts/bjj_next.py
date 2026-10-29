#!/usr/bin/env python3
"""Report the next Shark Pit BJJ class from the gym's public schedule feed."""

from __future__ import annotations

import json
import os
import sys
import tempfile
import time
import urllib.request
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

SCHEDULE_URL = "https://www.sharkpitbjj.com/_functions/schedule"
GYM_ZONE = ZoneInfo("America/New_York")
CACHE_TTL = 6 * 60 * 60
MAX_UPCOMING = 6
LOOKAHEAD_DAYS = 14

# The headline always shows the next class from this set.
ADULT_TYPES = {"gi", "nogi", "women", "kick", "wrest", "sc", "battodo", "openmat"}
# Add class types here to hide them entirely, e.g. {"kids"}.
EXCLUDE_TYPES: set[str] = set()

WEEKDAYS = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
]


def cache_path() -> str:
    base = os.environ.get("XDG_CACHE_HOME") or os.path.expanduser("~/.cache")
    return os.path.join(base, "quickshell", "bjj-schedule.json")


def load_cache() -> tuple[list, float] | None:
    try:
        with open(cache_path(), encoding="utf-8") as handle:
            payload = json.load(handle)
        return payload["items"], float(payload.get("fetchedAt", 0))
    except (OSError, ValueError, KeyError, TypeError):
        return None


def save_cache(items: list) -> None:
    path = cache_path()
    try:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        handle, temp_path = tempfile.mkstemp(dir=os.path.dirname(path))
        with os.fdopen(handle, "w", encoding="utf-8") as output:
            json.dump({"fetchedAt": time.time(), "items": items}, output)
        os.replace(temp_path, path)
    except OSError:
        pass


def fetch_items() -> list:
    request = urllib.request.Request(
        SCHEDULE_URL, headers={"User-Agent": "quickshell-bjj-widget/1.0"}
    )
    with urllib.request.urlopen(request, timeout=20) as response:
        payload = json.loads(response.read().decode("utf-8"))
    items = payload["items"]
    if not isinstance(items, list) or not items:
        raise ValueError("the schedule feed was empty")
    return items


def get_items(force: bool) -> list:
    cached = load_cache()
    if cached and not force and time.time() - cached[1] < CACHE_TTL:
        return cached[0]

    try:
        items = fetch_items()
    except Exception:
        if cached:
            return cached[0]
        raise

    save_cache(items)
    return items


def parse_clock(value: str) -> tuple[int, int]:
    hours, minutes = value.split(":")
    return int(hours), int(minutes)


def event_labels(start: datetime, end: datetime, now: datetime) -> tuple[str, str, str, str]:
    date = start.date()
    if date == now.date():
        day_label = "Today"
        row_day = "Today"
    elif date == now.date() + timedelta(days=1):
        day_label = "Tomorrow"
        row_day = "Tomorrow"
    else:
        day_label = date.strftime("%a, %b %-d")
        row_day = date.strftime("%a")

    start_label = start.strftime("%-I:%M %p")
    end_label = end.strftime("%-I:%M %p")
    when_label = f"{day_label} · {start_label} – {end_label}"
    row_label = f"{row_day} {start_label}"
    return when_label, row_label, start_label, end_label


def build_events(items: list, now: datetime) -> list:
    events = []
    for offset in range(LOOKAHEAD_DAYS):
        date = now.date() + timedelta(days=offset)
        for item in items:
            if WEEKDAYS.index(item["day"]) != date.weekday():
                continue
            if item.get("classType") in EXCLUDE_TYPES:
                continue

            start_hour, start_minute = parse_clock(item["startTime"])
            end_hour, end_minute = parse_clock(item["endTime"])
            start = datetime(
                date.year, date.month, date.day, start_hour, start_minute, tzinfo=GYM_ZONE
            )
            end = datetime(
                date.year, date.month, date.day, end_hour, end_minute, tzinfo=GYM_ZONE
            )
            if end <= now:
                continue

            when_label, row_label, start_label, end_label = event_labels(start, end, now)
            events.append(
                {
                    "title": item["title"],
                    "type": item.get("classType", ""),
                    "note": item.get("note", ""),
                    "dateISO": date.isoformat(),
                    "whenLabel": when_label,
                    "rowLabel": row_label,
                    "startLabel": start_label,
                    "endLabel": end_label,
                    "startEpoch": int(start.timestamp()),
                    "endEpoch": int(end.timestamp()),
                    "inSession": start <= now < end,
                    "adult": item.get("classType") in ADULT_TYPES,
                }
            )

    events.sort(key=lambda event: event["startEpoch"])
    return events


def main() -> int:
    force = "--force" in sys.argv[1:]
    now = datetime.now(GYM_ZONE)

    try:
        events = build_events(get_items(force), now)
    except Exception as error:
        json.dump({"ok": False, "error": f"Schedule unavailable: {error}"}, sys.stdout)
        return 1

    # Headline: the next class that is not a kids class.
    adult_events = [event for event in events if event["adult"]]
    next_event = adult_events[0] if adult_events else None

    # Small fragment: every upcoming class, kids classes included.
    now_epoch = int(now.timestamp())
    upcoming = []
    for event in events:
        if event["startEpoch"] <= now_epoch:
            continue
        if (
            next_event
            and event["startEpoch"] == next_event["startEpoch"]
            and event["title"] == next_event["title"]
        ):
            continue
        upcoming.append(event)
        if len(upcoming) == MAX_UPCOMING:
            break
    json.dump(
        {
            "ok": True,
            "source": SCHEDULE_URL,
            "timezone": GYM_ZONE.key,
            "generated": now.isoformat(timespec="minutes"),
            "next": next_event,
            "upcoming": upcoming,
        },
        sys.stdout,
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
