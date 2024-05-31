#!/bin/bash

cat << EOF > index.html
<h1><center>My Web Server</center></h1>
<p>DB address: ${db_address}</p>
<p>DB port: ${db_port}</p>
EOF

nohup busybox httpd -f -p 8080&