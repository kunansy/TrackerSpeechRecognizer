from pydantic import BaseModel, ConfigDict, field_validator


class TranscriptTextResponse(BaseModel):
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)

    transcript: str
    confidence: float

    @field_validator("transcript")
    def capitalize_transcript(cls, transcript: str) -> str:
        return transcript.capitalize()

    @field_validator("confidence")
    def convert_to_percent(cls, value: float) -> float:
        return round(value * 100, 2)
