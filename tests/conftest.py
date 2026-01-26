"""
Pytest configuration and shared fixtures for the test suite.
"""

import pytest


@pytest.fixture(autouse=True)
def reset_environment():
    """Reset environment variables before each test."""
    # Add any cleanup or setup needed before/after tests
    yield
    # Cleanup after test
