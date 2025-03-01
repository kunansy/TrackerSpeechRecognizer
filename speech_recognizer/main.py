from typing import Annotated

from fastapi import Body, FastAPI
from fastapi.exceptions import HTTPException
from fastapi.responses import ORJSONResponse

from speech_recognizer import recognizer, schemas, settings
from speech_recognizer.logger import logger


app = FastAPI(
    title="Tracker Speech Recognizer",
    version=settings.API_VERSION,
    debug=settings.API_DEBUG,
    default_response_class=ORJSONResponse,
)


@app.get("/liveness", include_in_schema=False)
async def liveness():
    return ORJSONResponse(content={"status": "ok"})


@app.get("/readiness", include_in_schema=False)
async def readiness():
    return ORJSONResponse(content={"status": "ok"})


@app.post("/transcript", response_model=schemas.TranscriptTextResponse)
async def transcript_speech(data: Annotated[bytes, Body()]):
    file = recognizer.get_file_content(data)
    path = recognizer.dump(file)
    recognizer.fix_file_format(path)

    logger.info("Start reading file")
    audio = recognizer.read_file(path)
    recognizer.remove(path)

    logger.info("File read, start recognition")
    if not (result := recognizer.recognize(audio)):
        raise HTTPException(status_code=400, detail="Could not recognize speech")

    logger.debug("Result got: %s", result)
    best = recognizer.get_best_result(result)

    logger.info("Transcript got: %s", best)

    return best
