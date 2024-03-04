#modul ami implemtentalja az OCR logikát a Tesseract használatával.

import pytesseract
from PIL import Image
from fastapi import UploadFile
import aiofiles
import os


# Pillow csomag ->  segítségével olvashatod be a képeket, amelyekre a Tesseract alkalmazva lesz
# aiofiles -> A képek feldolgozásához ideiglenesen tárold őket a szerveren. 
# Az aiofiles segítségével aszinkron módon kezelheted a fájlműveleteket

# teszteld a rendszert lokálisan az uvicorn main:app --reload parancs futtatásával


async def extract_text_from_image(file: UploadFile):
    try:
        # Az ideiglenes fájl kiterjesztésének megfelelő beállítása
        suffix = os.path.splitext(file.filename)[1]
        async with aiofiles.tempfile.NamedTemporaryFile(delete=True, suffix=suffix) as temp_file:
            await temp_file.write(await file.read())
            await temp_file.seek(0)
            
            # Kép előfeldolgozása, ha szükséges (pl. méretezés)
            image = Image.open(temp_file.name)
            # Itt hajtható végre esetleges kép előfeldolgozás
            
            # OCR feldolgozás
            text = pytesseract.image_to_string(image)
            return text
    except Exception as e:
        print(f"Error processing image: {e}")
        return None

