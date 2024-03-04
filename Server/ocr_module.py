#modul ami implemtentalja az OCR logikát a Tesseract használatával.

import pytesseract
from PIL import Image
from fastapi import UploadFile, HTTPException
import aiofiles
import os
import io



# Pillow csomag ->  segítségével olvashatod be a képeket, amelyekre a Tesseract alkalmazva lesz
# aiofiles -> A képek feldolgozásához ideiglenesen tárold őket a szerveren. 
# Az aiofiles segítségével aszinkron módon kezelheted a fájlműveleteket

# teszteld a rendszert lokálisan az uvicorn main:app --reload parancs futtatásával


async def extract_text_from_image(file: UploadFile):
    try:
        # A fájl tartalmának beolvasása az emlékezetbe
        contents = await file.read()
        image = Image.open(io.BytesIO(contents))
        
        # Kép előfeldolgozása, ha szükséges (pl. méretezés)
        # Itt hajtható végre esetleges kép előfeldolgozás
        
        # OCR feldolgozás
        text = pytesseract.image_to_string(image)
        print(text)
        return text
    except Exception as e:
        print(f"Error processing image: {e}")
        return None