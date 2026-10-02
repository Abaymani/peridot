#!/usr/bin/env python3
# Builds emoji.json for the emoji picker: order, names and groups from
# Unicode's emoji-test.txt, keywords from CLDR's English annotations. Leaves
# out skin-tone variants, components and emoji newer than the installed emoji
# font can draw. Unicode data: Unicode License v3.
#
#     python3 generate.py [font file]
import json, os, re, subprocess, sys, urllib.request

EMOJI_TEST = "https://www.unicode.org/Public/emoji/latest/emoji-test.txt"
CLDR = "https://raw.githubusercontent.com/unicode-org/cldr-json/main/cldr-json/"
ANNOTATIONS = CLDR + "cldr-annotations-full/annotations/en/annotations.json"
DERIVED = CLDR + "cldr-annotations-derived-full/annotationsDerived/en/annotations.json"
SKIN_TONES = set(range(0x1F3FB, 0x1F400))


def fetch(url):
    with urllib.request.urlopen(url) as response:
        return response.read().decode("utf-8")


def font_codepoints(path):
    ranges = subprocess.run(["fc-query", "--format=%{charset}", path], capture_output=True, text=True, check=True).stdout
    points = set()
    for part in ranges.split():
        start, _, end = part.partition("-")
        points.update(range(int(start, 16), int(end or start, 16) + 1))
    return points


def parse_emoji_test(text):
    entries, group = [], None
    for line in text.splitlines():
        if line.startswith("# group:"):
            group = line.split(":", 1)[1].strip()
            continue
        match = re.match(r"^([0-9A-F ]+?)\s*; fully-qualified\s*# (\S+) E(\d+\.\d+) (.+)$", line)
        if not match:
            continue
        codepoints = [int(cp, 16) for cp in match.group(1).split()]
        if group == "Component" or SKIN_TONES & set(codepoints):
            continue
        entries.append({"char": match.group(2), "codepoints": codepoints, "version": float(match.group(3)),
                        "name": match.group(4), "group": group})
    return entries


# The newest emoji version whose single-codepoint emoji are all in the font,
# along with every older version's.
def supported_version(entries, codepoints):
    complete = {}
    for entry in entries:
        singles = [cp for cp in entry["codepoints"] if cp != 0xFE0F]
        if len(singles) == 1:
            complete[entry["version"]] = complete.get(entry["version"], True) and singles[0] in codepoints
    supported = 0.0
    for version in sorted(complete):
        if not complete[version]:
            break
        supported = version
    return supported


def main():
    font = sys.argv[1] if len(sys.argv) > 1 else subprocess.run(
        ["fc-match", "-f", "%{file}", "emoji:color"], capture_output=True, text=True, check=True).stdout
    entries = parse_emoji_test(fetch(EMOJI_TEST))
    version = supported_version(entries, font_codepoints(font))
    keywords = json.loads(fetch(ANNOTATIONS))["annotations"]["annotations"]
    keywords.update(json.loads(fetch(DERIVED))["annotationsDerived"]["annotations"])

    groups = {}
    for entry in entries:
        if entry["version"] > version:
            continue
        name_words = set(entry["name"].lower().replace(":", "").split())
        words = keywords.get(entry["char"].replace("️", ""), {}).get("default", [])
        extra = []
        for word in " ".join(words).lower().replace("|", " ").split():
            if word not in name_words and word not in extra:
                extra.append(word)
        groups.setdefault(entry["group"], []).append([entry["char"], entry["name"], " ".join(extra)])

    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "emoji.json")
    with open(out, "w", encoding="utf-8") as f:
        f.write('{"version": %s, "font": %s, "categories": [\n' % (json.dumps(str(version)), json.dumps(os.path.basename(font))))
        f.write(",\n".join(
            '{"name": %s, "emoji": [\n%s\n]}' % (json.dumps(name), ",\n".join(json.dumps(e, ensure_ascii=False) for e in emoji))
            for name, emoji in groups.items()))
        f.write("\n]}\n")
    print(f"{out}: {sum(len(e) for e in groups.values())} emoji up to {version}, in {len(groups)} categories")


if __name__ == "__main__":
    main()
