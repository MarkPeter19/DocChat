# tests/test_ocr_module.py

import pytest
from ocr_module_tesseract import extract_text_from_image
from fastapi import UploadFile
import io



async def create_upload_file(filename: str) -> UploadFile:
    with open(filename, 'rb') as f:
        content = f.read()
    # Itt csak a fajlnev es a tartalom szukseges
    return UploadFile(filename=filename, file=io.BytesIO(content))

@pytest.mark.asyncio
async def test_extract_text_from_image():
    test_file = await create_upload_file("tests/TesztAnalizis1.png")
    result_text = await extract_text_from_image(test_file)
    print("\n\nExtracted text:\n\n", result_text)
    #assert "Every path is \nthe right path. \n" in result_text
    
    
