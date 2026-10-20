from unittest.mock import Mock, patch

import pytest

from unpaywall import NoOpenAccessPDFException, download_pdf


@patch("requests.get")
def test_download_pdf_returns_pdf_bytes(mock_get):
    mock_api = Mock()
    mock_api.json.return_value = {
        "best_oa_location": {"url_for_pdf": "https://example.org/paper.pdf"},
    }
    mock_pdf = Mock()
    mock_pdf.content = b"%PDF-1.4 fake"
    mock_get.side_effect = [mock_api, mock_pdf]

    result = download_pdf("10.1000/example", "me@example.org")

    assert result == b"%PDF-1.4 fake"


@patch("requests.get")
def test_download_pdf_raises_without_oa_location(mock_get):
    mock_api = Mock()
    mock_api.json.return_value = {"best_oa_location": None}
    mock_get.side_effect = [mock_api]

    with pytest.raises(NoOpenAccessPDFException):
        download_pdf("10.1000/example", "me@example.org")
