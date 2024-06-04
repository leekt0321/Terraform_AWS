#!/bin/bash

cat << EOF > index.html
<h1><center> My Web Server </center></h1>
EOF

nohup busybox httpd -f -p 80&