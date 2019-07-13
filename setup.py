#!/usr/bin/env python

from distutils.core import setup

setup(
    name='decompress',
    version='0.1.0',
    packages=['decompress',],
    install_requires=[
        'boto3==1.9.137',
        'botocore==1.12.137',
        'Click==7.0',
    ],
    entry_points={
        'console_scripts': [
	        'decompress=decompress:main',
        ],
    },
)