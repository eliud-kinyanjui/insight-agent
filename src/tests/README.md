# Tests

This directory contains the test suite for the Insight Agent application.

## Test Structure

- `test_main.py` - Main test file containing all test cases for the FastAPI application
- `conftest.py` - Pytest configuration and shared fixtures
- `__init__.py` - Package initialization

## Running Tests

### Run all tests
```bash
pytest tests/ -v
```

### Run tests with coverage
```bash
pytest tests/ --cov=. --cov-report=term-missing
```

### Run specific test class
```bash
pytest tests/test_main.py::TestHealthEndpoint -v
```

### Run specific test
```bash
pytest tests/test_main.py::TestHealthEndpoint::test_health_check_returns_200 -v
```

## Test Coverage

The test suite covers:

- ✅ Health check endpoint
- ✅ Text analysis endpoint with various input scenarios:
  - Simple text
  - Empty strings (validation)
  - Missing fields (validation)
  - Single words
  - Multiple spaces
  - Numbers
  - Special characters
  - Long text
  - Newlines
  - Unicode characters
- ✅ App metadata (title, version, docs)

Current coverage: **94%**

## Test Classes

### TestHealthEndpoint
Tests for the `/health` endpoint to ensure the service is responding correctly.

### TestAnalyzeEndpoint
Comprehensive tests for the `/analyze` endpoint covering various text input scenarios and edge cases.

### TestAppMetadata
Tests for application metadata and API documentation endpoints.

## Requirements

Testing dependencies are listed in `requirements-dev.txt`:
- pytest
- pytest-cov
- httpx (for TestClient)
- flake8
- black
- isort
- pylint
