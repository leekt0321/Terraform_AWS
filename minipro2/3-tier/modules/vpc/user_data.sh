#!/bin/bash

cat << EOF > index.html
<h1><center> My Web Server </center></h1>
<p>DB addressL ${db_address}</p>
<p>DB port: ${db_port}</p>
EOF

nohup busybox httpd -f -p 80&