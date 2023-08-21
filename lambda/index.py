#!/usr/bin/env python3

import os
import logging
import boto3
import urllib3
from datetime import datetime
import json


LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

# DST_BUCKET = os.environ.get('DST_BUCKET')
DST_BUCKET = "destination-s3-bucket-sftp"
REGION = os.environ.get('REGION')

s3 = boto3.resource('s3', region_name=REGION)

http = urllib3.PoolManager()

def handler(event, context):
    LOGGER.info('Event structure: %s', event)
    LOGGER.info('DST_BUCKET: %s', DST_BUCKET)

    for record in event['Records']:    
        src_bucket = record['s3']['bucket']['name']
        src_key = record['s3']['object']['key']
        file_name = str(src_key)

        username = file_name.split('/')[0]
        file_name = file_name.split('/')[-1]    
        LOGGER.info('copy_source: %s', file_name)
        if file_name != "":
            try:
                
                datetime.strptime(file_name.replace(".pdf", ""), '%Y%m')
                
                copy_source = {
                        'Bucket': src_bucket,
                        'Key': src_key
                    }
                LOGGER.info('copy_source: %s', copy_source)
                LOGGER.info('src_key: %s', src_key)
                LOGGER.info('file_neme_contains:  %s', '.pdf' in file_name)
                bucket = s3.Bucket(DST_BUCKET)
                bucket.copy(copy_source, src_key)
            except ValueError:
                LOGGER.info('src_key: %s', src_key)
                url = "https://hooks.slack.com/services/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"
                notify_text = {
                    "text": "The user '"+username+"' has uploaded a file named '"+file_name +"' but it does not meet the specified conditions"
                }
                response = http.request('POST',
                            url,
                            body = json.dumps(notify_text),
                            headers = {'Content-Type': 'application/json'},
                            retries = False)
    return {
        'status': 'ok'
    }