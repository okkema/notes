import requests


def _authors(message: dict) -> str:
    authors = message.get("author", [])
    return "; ".join(f"{a.get('family', '')}, {a.get('given', '')}" for a in authors)


def fetch_metadata(doi: str) -> dict:
    url = f"https://api.crossref.org/works/{doi}"
    response = requests.get(url, timeout=30)
    response.raise_for_status()
    message = response.json()["message"]
    return {
        "title": (message.get("title") or [""])[0],
        "authors": _authors(message),
        "journal": (message.get("container-title") or [""])[0],
        "year": message["issued"]["date-parts"][0][0],
    }
