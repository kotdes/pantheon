"""Give every page a short description from its first paragraph.

Social cards and the `<meta name="description">` tag read `page.meta["description"]`. Most pages
have no description in their front matter, so this hook takes the first paragraph of plain text.
A description in the front matter always wins.
"""

import re

from mkdocs.plugins import event_priority

MAX_LENGTH = 100


def first_paragraph(markdown: str) -> str | None:
    """Return the first paragraph of plain text, or None if the page has none."""
    in_fence = False
    paragraph: list[str] = []
    for line in markdown.splitlines():
        stripped = line.strip()
        if stripped.startswith("```"):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        if not stripped:
            if paragraph:
                break
            continue
        # Skip headings, notes (and their indented text), HTML, tables, lists, quotes and images.
        if (
            line.startswith((" ", "\t"))
            or stripped.startswith(("#", "!!!", "???", "<", "|", "-", "*", "+", ">", "!["))
            or re.match(r"\d+\.\s", stripped)
            or stripped.startswith("[") and stripped.endswith("){ .md-button }")
            or stripped.startswith("[") and "{ .md-button" in stripped
        ):
            if paragraph:
                break
            continue
        paragraph.append(stripped)
    if not paragraph:
        return None
    text = " ".join(paragraph)
    text = re.sub(r"\[([^\]]+)\]\([^)]*\)", r"\1", text)  # links
    text = re.sub(r"`([^`]*)`", r"\1", text)  # code
    text = re.sub(r"(\*\*|__|\*|_)(.+?)\1", r"\2", text)  # emphasis
    text = re.sub(r"\{[^}]*\}|:[a-z0-9_+-]+:|\s+", lambda m: " " if m.group(0).isspace() else "", text)
    text = text.strip()
    # A last sentence that ends in a colon introduces a list or code, so leave it out.
    sentences = [part for part in re.split(r"(?<=[.!?])\s+", text) if part]
    if len(sentences) > 1 and sentences[-1].endswith(":"):
        sentences.pop()
    return " ".join(sentences).rstrip(":") or None


def shorten(text: str) -> str:
    """Keep whole sentences while they fit, else cut a long one at a comma or a word."""
    if len(text) <= MAX_LENGTH:
        return text
    sentences = re.split(r"(?<=[.!?])\s+", text)
    short = sentences[0]
    for sentence in sentences[1:]:
        if len(short) + 1 + len(sentence) > MAX_LENGTH:
            break
        short += " " + sentence
    if len(short) <= MAX_LENGTH:
        return short
    # One long sentence: stop at the last comma that leaves enough of it, else at a word.
    head = short[: MAX_LENGTH - 1]
    comma = head.rfind(",")
    if comma >= MAX_LENGTH // 2:
        return head[:comma] + "."
    return head.rsplit(" ", 1)[0].rstrip(",;:") + "…"


# Run before the social plugin, which reads the description while it makes the card.
@event_priority(100)
def on_page_markdown(markdown, page, config, files):
    if not page.meta.get("description"):
        paragraph = first_paragraph(markdown)
        if paragraph:
            page.meta["description"] = shorten(paragraph)
    return markdown
