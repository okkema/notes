import os

import functions_framework
from flask import Request

import bucket
import doi
import markdown
import text
import unpaywall
from function import http


@functions_framework.http
@http(method="POST")
def ocr_paper(request: Request):
    doi_value = (request.form.get("doi") or "").strip()
    if not doi_value:
        return "Missing doi", 400
    file = request.files.get("file")
    if file:
        pdf = file.read()
    else:
        try:
            pdf = unpaywall.download_pdf(doi_value, os.getenv("UNPAYWALL_EMAIL"))
        except unpaywall.NoOpenAccessPDFException:
            return "No open access PDF found, upload the file", 422

    pages = text.extract_text(pdf)
    metadata = doi.fetch_metadata(doi_value)
    contents = markdown.build(doi_value, metadata, pages)
    bucket.upload(f"private/doi/{doi_value}.md", contents.encode())
    bucket.upload(f"private/doi/{doi_value}.pdf", pdf)
    return "OK", 201
