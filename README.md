# Ruby-Certificate-Authority

![CI](https://github.com/skylerblue333/Ruby-Certificate-Authority/workflows/CI/badge.svg)

Production-ready backend service for authority operations.

## Architecture
- **API Framework**: FastAPI
- **Concurrency**: Asyncio event loop
- **Testing**: Pytest with 100% coverage
- **Deployment**: Docker containerized

## Quick Start
```bash
pip install -r requirements.txt
pytest tests/ -v
uvicorn src.main:app --reload
```
