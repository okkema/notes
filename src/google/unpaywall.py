import requests


class NoOpenAccessPDFException(Exception):
    pass


def download_pdf(doi: str, email: str) -> bytes:
    url = f"https://api.unpaywall.org/v2/{requests.utils.quote(doi)}?email={email}"
    response = requests.get(url, timeout=30)
    response.raise_for_status()
    location = response.json().get("best_oa_location") or {}
    pdf_url = location.get("url_for_pdf")
    if not pdf_url:
        raise NoOpenAccessPDFException(doi)
    pdf = requests.get(pdf_url, timeout=120)
    pdf.raise_for_status()
    return pdf.content
