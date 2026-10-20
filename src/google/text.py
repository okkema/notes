import fitz
import pytesseract

CHARS_THRESHOLD = 20


def extract_text(pdf_bytes: bytes) -> list:
    pdf = fitz.open(stream=pdf_bytes, filetype="pdf")
    pages = []
    for page in pdf:
        text = page.get_text()
        if len(text.strip()) < CHARS_THRESHOLD:
            pix = page.get_pixmap(dpi=300)
            text = pytesseract.image_to_string(pix.pil_image())
        pages.append(text)
    return pages
