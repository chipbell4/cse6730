#!/bin/bash

set -e

tar czvf bundle.tar.gz *
scp bundle.tar.gz aprilandchip@aprilandchip.com:~/html/math6730
