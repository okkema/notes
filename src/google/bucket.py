import os
from io import BytesIO

import boto3
from botocore.config import Config

BUCKET = os.getenv("BUCKET")

config = Config(client_context_params={
    "request_checksum_calculation": "WHEN_REQUIRED",
    "response_checksum_validation": "WHEN_REQUIRED",
})

s3 = boto3.client(
    service_name="s3",
    endpoint_url=os.getenv("BUCKET_URL"),
    config=config,
)


def upload(key: str, content: bytes):
    s3.upload_fileobj(BytesIO(content), BUCKET, key)
