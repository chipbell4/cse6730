#!/bin/bash

set -e

echo "Bundling"
tar czf bundle.tar.gz *
echo "Copying file"
scp bundle.tar.gz aprilandchip@aprilandchip.com:~/html/cse6730/bundle.tar.gz
echo "Unbundling"
ssh aprilandchip@aprilandchip.com "cd html/cse6730/ && tar xzf bundle.tar.gz"
