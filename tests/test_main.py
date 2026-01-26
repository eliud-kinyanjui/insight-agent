import pytest
from fastapi.testclient import TestClient
from main import app


@pytest.fixture
def client():
    """Create a test client for the FastAPI app."""
    return TestClient(app)


class TestHealthEndpoint:
    """Test cases for the health check endpoint."""

    def test_health_check_returns_200(self, client):
        """Test that health check returns 200 status code."""
        response = client.get("/health")
        assert response.status_code == 200

    def test_health_check_returns_healthy_status(self, client):
        """Test that health check returns healthy status."""
        response = client.get("/health")
        assert response.json() == {"status": "healthy"}


class TestAnalyzeEndpoint:
    """Test cases for the analyze endpoint."""

    def test_analyze_simple_text(self, client):
        """Test analyzing simple text."""
        request_data = {"text": "I love cloud engineering!"}
        response = client.post("/analyze", json=request_data)
        
        assert response.status_code == 200
        data = response.json()
        assert data["original_text"] == "I love cloud engineering!"
        assert data["word_count"] == 4
        assert data["character_count"] == 22

    def test_analyze_empty_string(self, client):
        """Test that empty string returns 422 validation error."""
        request_data = {"text": ""}
        response = client.post("/analyze", json=request_data)
        assert response.status_code == 422

    def test_analyze_missing_text_field(self, client):
        """Test that missing text field returns 422 validation error."""
        request_data = {}
        response = client.post("/analyze", json=request_data)
        assert response.status_code == 422

    def test_analyze_single_word(self, client):
        """Test analyzing single word."""
        request_data = {"text": "Hello"}
        response = client.post("/analyze", json=request_data)
        
        assert response.status_code == 200
        data = response.json()
        assert data["original_text"] == "Hello"
        assert data["word_count"] == 1
        assert data["character_count"] == 5

    def test_analyze_text_with_multiple_spaces(self, client):
        """Test analyzing text with multiple spaces between words."""
        request_data = {"text": "Hello    world    test"}
        response = client.post("/analyze", json=request_data)
        
        assert response.status_code == 200
        data = response.json()
        assert data["original_text"] == "Hello    world    test"
        assert data["word_count"] == 3
        # character_count excludes spaces
        assert data["character_count"] == 14

    def test_analyze_text_with_numbers(self, client):
        """Test analyzing text with numbers."""
        request_data = {"text": "I have 123 items"}
        response = client.post("/analyze", json=request_data)
        
        assert response.status_code == 200
        data = response.json()
        assert data["word_count"] == 4
        assert data["character_count"] == 13

    def test_analyze_text_with_special_characters(self, client):
        """Test analyzing text with special characters."""
        request_data = {"text": "Hello! How are you?"}
        response = client.post("/analyze", json=request_data)
        
        assert response.status_code == 200
        data = response.json()
        assert data["word_count"] == 4
        assert data["character_count"] == 16

    def test_analyze_long_text(self, client):
        """Test analyzing longer text."""
        long_text = "This is a much longer piece of text that contains multiple sentences. " \
                   "It should be analyzed correctly and return accurate word and character counts."
        request_data = {"text": long_text}
        response = client.post("/analyze", json=request_data)
        
        assert response.status_code == 200
        data = response.json()
        assert data["original_text"] == long_text
        assert data["word_count"] == 24
        assert data["character_count"] == 125

    def test_analyze_text_with_newlines(self, client):
        """Test analyzing text with newline characters."""
        request_data = {"text": "Line one\nLine two\nLine three"}
        response = client.post("/analyze", json=request_data)
        
        assert response.status_code == 200
        data = response.json()
        assert data["word_count"] == 6

    def test_analyze_unicode_text(self, client):
        """Test analyzing text with unicode characters."""
        request_data = {"text": "Hello 世界 🌍"}
        response = client.post("/analyze", json=request_data)
        
        assert response.status_code == 200
        data = response.json()
        assert data["original_text"] == "Hello 世界 🌍"
        assert data["word_count"] == 3


class TestAppMetadata:
    """Test cases for app metadata."""

    def test_app_has_correct_title(self, client):
        """Test that app has the correct title."""
        response = client.get("/openapi.json")
        assert response.status_code == 200
        data = response.json()
        assert data["info"]["title"] == "Insight Agent - PawaIT Assessment"

    def test_app_has_correct_version(self, client):
        """Test that app has the correct version."""
        response = client.get("/openapi.json")
        assert response.status_code == 200
        data = response.json()
        assert data["info"]["version"] == "1.0.1"

    def test_docs_endpoint_accessible(self, client):
        """Test that docs endpoint is accessible."""
        response = client.get("/docs")
        assert response.status_code == 200

    def test_openapi_endpoint_accessible(self, client):
        """Test that OpenAPI endpoint is accessible."""
        response = client.get("/openapi.json")
        assert response.status_code == 200
