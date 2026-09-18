import os

AWS_REGION = os.getenv("AWS_REGION", "us-east-2")

JWT_SECRET = os.getenv("JWT_SECRET")

if not JWT_SECRET:
    raise RuntimeError("JWT_SECRET environment variable is not configured")

JWT_ALGORITHM = "HS256"
