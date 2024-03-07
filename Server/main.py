from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from ocr_module_tesseract import extract_text_from_image
import logging

logger = logging.getLogger("ocr_logger")
logging.basicConfig(level=logging.INFO)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/upload/")
async def create_upload_file(file: UploadFile = File(...)):
    try:
        logger.info(f"Processing file: {file.filename}")
        text = await extract_text_from_image(file)
        if text is None or text.strip() == "":
            raise HTTPException(status_code=400, detail="No text found in the image.")
        return {"text": text}
    except Exception as e:
        logger.error(f"Error processing file: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
