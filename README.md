whiteboard
==========


FAQ
---

Q: I HAVE NO IDEA HOW TO RUN THIS!


A: Run `npm install` in the root folder, and make sure you have something similar in your nginx.conf file:
```
server {
        listen       0.0.0.0:80;
        server_name  localhost;

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        charset utf-8;

        location / {
            root    D:/Projects/whiteboard/static/;
            index   index.html index.htm;
        }

        location /socket.io {
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header Host $http_host;
          proxy_set_header X-NginX-Proxy true;

          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";

          proxy_pass http://localhost:5666/socket.io;
          proxy_redirect off;
        }
    }
```

Then run ```node app.js```