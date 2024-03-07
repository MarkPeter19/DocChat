#modul ami implemtentalja az OCR logikát a Tesseract használatával.

import pytesseract
from PIL import Image
from fastapi import UploadFile, HTTPException
import aiofiles
import io
import re



# Pillow csomag ->  segítségével olvashatod be a képeket, amelyekre a Tesseract alkalmazva lesz
# aiofiles -> A képek feldolgozásához ideiglenesen tárold őket a szerveren. 
# Az aiofiles segítségével aszinkron módon kezelheted a fájlműveleteket

# teszteld a rendszert lokálisan az uvicorn main:app --reload parancs futtatásával


# A szövegfeldolgozásra és strukturálásra szolgáló függvény
def parse_blood_test_results(text):
    """ Feldolgozza a szöveget és kinyeri a releváns adatokat a vérvizsgálati eredményekből. """
    results = {}
    pattern = re.compile(r"\d+\.\d+|\d+")
    current_section = None  # Alapértelmezett érték hozzáadása

    for line in text.split('\n'):
        if ":" in line:  # Új szekció kezdete
            current_section = line.split(':')[0].strip()
            results[current_section] = {}
        elif pattern.search(line) and current_section is not None:  # Az ellenőrzés, hogy current_section nem None
            try:
                key, value = line.split(maxsplit=1)
                results[current_section][key] = value
            except ValueError as e:
                print(f"Error processing line: {line}, error: {e}")

    return results


async def extract_text_from_image(file: UploadFile):
    try:
        contents = await file.read()
        image = Image.open(io.BytesIO(contents))
        
        # Tesseract konfiguráció beállítása
        custom_config = r'--oem 3 --psm 6'
        
        # OCR feldolgozás a képre a beállított konfigurációval
        text = pytesseract.image_to_string(image, lang='eng', config=custom_config)

        # Az eredmények visszaadása
        return {"results": text}
    except Exception as e:
        print(f"Error processing image: {e}")
        raise HTTPException(status_code=500, detail=str(e))
