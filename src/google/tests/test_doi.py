from unittest.mock import Mock, patch

from doi import fetch_metadata


@patch("requests.get")
def test_fetch_metadata_parses_crossref_response(mock_get):
    mock_response = Mock()
    mock_response.json.return_value = {"message": {
        "title": ["An Example Paper"],
        "author": [
            {"given": "Ada", "family": "Lovelace"},
            {"given": "Grace", "family": "Hopper"},
        ],
        "container-title": ["Example Journal"],
        "issued": {"date-parts": [[2021, 3, 1]]},
    }}
    mock_get.return_value = mock_response

    result = fetch_metadata("10.1000/example")

    assert result == {
        "title": "An Example Paper",
        "authors": "Lovelace, Ada; Hopper, Grace",
        "journal": "Example Journal",
        "year": 2021,
    }
    mock_get.assert_called_once()
