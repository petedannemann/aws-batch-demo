#!/usr/bin/env python

from distutils.core import setup

setup(
    name='decompress-decrypt',
    version='0.1.0',
    packages=['decompress_decrypt'],
    install_requires=[
        'boto3==1.9.137',
        'botocore==1.12.137',
        'Click==7.0',
        'cryptography==3.2',
        'smart-open==1.8.4'
    ],
    entry_points={
        'console_scripts': [
	        'decompress-decrypt=decompress_decrypt:main',
        ],
    },
)