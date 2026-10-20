from urllib.parse import quote

HOST = "https://private.notes.okkema.org"


def build(doi: str, metadata: dict, pages: list) -> str:
    slug = quote(doi, safe="/")
    frontmatter = "\n".join([
        "---",
        f'title: "{metadata["title"]}"',
        f'authors: "{metadata["authors"]}"',
        f'journal: "{metadata["journal"]}"',
        f"year: {metadata['year']}",
        f'doi: "{doi}"',
        f"url: https://doi.org/{slug}",
        f"pdf: {HOST}/doi/{slug}.pdf",
        "---",
    ])
    sections = "\n\n".join(
        f"## Page {index + 1}\n\n{page.strip()}"
        for index, page in enumerate(pages)
    )
    return f"{frontmatter}\n\n{sections}\n"
