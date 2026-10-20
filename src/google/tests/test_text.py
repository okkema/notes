from unittest.mock import patch

import fitz

from text import extract_text


def _pdf_with_text() -> bytes:
    doc = fitz.open()
    page = doc.new_page()
    page.insert_text((72, 72), "Hello extracted text")
    return doc.tobytes()


def _blank_pdf() -> bytes:
    doc = fitz.open()
    doc.new_page()
    return doc.tobytes()


def test_extract_text_uses_embedded_text():
    pages = extract_text(_pdf_with_text())
    assert "Hello extracted text" in pages[0]


@patch("text.pytesseract")
def test_extract_text_ocrs_blank_pages(mock_tesseract):
    mock_tesseract.image_to_string.return_value = "OCR result"
    pages = extract_text(_blank_pdf())
    assert pages[0] == "OCR result"
    mock_tesseract.image_to_string.assert_called_once()
