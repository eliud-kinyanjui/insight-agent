from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
import uvicorn
import os

# Initialize FastAPI app
app = FastAPI(
    title="Insight Agent - PawaIT Assessment",
    description="App to analyze customer feedback.",
    version="1.0.1"
)

# Pydantic model for request body
class AnalysisRequest(BaseModel):
    text: str = Field(
        min_length=1,
        description="Customer feedback text to be analyzed.",
        json_schema_extra={"example": "I love cloud engineering!"}
    )


# Endpoint to analyze text
@app.post("/analyze")
async def analyze_text(request: AnalysisRequest):
    if not request.text:
        raise HTTPException(status_code=400, detail="Text field cannot be empty")

    # Simple analysis: word count and character count
    word_count = len(request.text.split())
    char_count = len(''.join(request.text.split()))

    return {
        "original_text": request.text,
        "word_count": word_count,
        "character_count": char_count
    }

# Health check endpoint
@app.get("/health")
async def health_check():
    return {"status": "healthy"}


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port)