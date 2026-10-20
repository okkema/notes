from markdown import build


def test_build_includes_frontmatter_and_pdf_link():
    metadata = {
        "title": "An Example Paper",
        "authors": "Lovelace, Ada",
        "journal": "Example Journal",
        "year": 2021,
    }
    pages = ["Page one text", "Page two text"]

    result = build("10.1000/example", metadata, pages)

    assert 'title: "An Example Paper"' in result
    assert 'doi: "10.1000/example"' in result
    assert "url: https://doi.org/10.1000/example" in result
    assert "pdf: https://private.notes.okkema.org/doi/10.1000/example.pdf" in result
    assert "## Page 1" in result and "Page one text" in result
    assert "## Page 2" in result and "Page two text" in result
