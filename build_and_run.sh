#!/bin/bash
docker build -t my-ocsp .
docker stop ocsp 2>/dev/null && docker rm ocsp 2>/dev/null
docker run -d --name ocsp -p 2560:2560 -v ~/ca:/root/ca my-ocsp