# POP SERVER
## @edt ASIX M11-SAD Curs 2018-2019
## Franlin colque s. isx27423760

Podeu trobar les imatges docker al Dockehub de [francs2](https://hub.docker.com/u/francs2/)
Podeu trobar els repositoris de l'examen [isx27423760](https://github.com/isx27423760/exampop)


Primer de tot entrem a una maquina de AWS:
```
[isx27423760@i16 ~]$ ssh -i .ssh/mykey.pem fedora@35.178.244.131
```

Un cop a dins:  
Creem la xarxe interna per al pop
```
[fedora@ip-172-31-23-25 ~]$ docker network create popnet
```

descarreguem del nostre github del docker per crea la nostra imatge:
```
[fedora@ip-172-31-23-25 ~]$ git clone https://github.com/isx27423760/exampop.git
```

Contruim la imatge de popserver:
```
[fedora@ip-172-31-23-25 popserver:19]$ docker build -t francs2/m11franlin .
```

#### Execució
Execucio amb els ports de pop i pop segur ja mapejats, el container estara en segon pla (datach).
```
docker run -p 110:110 -p 995:995 --rm --name popserver -h popserver --net popnet -d francs2/m11franlin 
```
**NOTA : IMPORTANT**

Obrir al securiy GROUP de AWS els ports per fer la consulta desde el host de l'aula 
mes concretament els ports ssh (per conectarnos a nuestra maquina de aws) , y el 110 (POP3) y 995(POP3s).

#### Comprovacio que els ports estan mapejats.
Veime quina ip te el container docker
```
[isx27423760@i16 exampop]$ docker network inspect popnet 
"IPv4Address": "172.19.0.2/16",
```

Veure quins ports esta oberts
```
[isx27423760@i16 exampop]$ nmap 172.19.0.2
PORT     STATE SERVICE
110/tcp  open  pop3
995/tcp  open  pop3s
....
....
```

Veure desde fora si els ports estan mapejats:
```
[fedora@ip-172-31-23-25 popserver:19]$ nmap localhost
.....
PORT    STATE SERVICE
22/tcp  open  ssh
110/tcp open  pop3
995/tcp open  pop3s
```

Com em obert els porta 110 i 995 del securyto group de la nostra maquina de amazon, 
llavors podem fer consultas desde la escola directament a la ip publica de la AMI de AWS. 

#### Comprovacio text pla

Desde el host de l'escola fem :
- Coprovacio en text pla de un mbox de pere
```
	[isx27423760@i16 ~]$ telnet 35.178.244.131 110
	Trying 35.178.244.131...
	Connected to 35.178.244.131.
	Escape character is '^]'.
	+OK POP3 popserver 2007f.104 server ready
	USER pere
	+OK User name accepted, password please
	PASS pere
	+OK Mailbox open, 1 messages
	LIST
	+OK Mailbox scan listing follows
	1 179
	.
	RETR 1
	+OK 179 octets
	Received: from ... by ... with ESMTP;
	Subject: Prueba
	From: <pere@edt-orgcom>
	To: <junkdtectr@carolina.rr.com>
	Status: RO
	
	>Esto es una prueba de bustia de correo de pere.
	.
	QUIT
	+OK Sayonara
	Connection closed by foreign host.
```

- Coprovacio en text pla de un mbox de marta
```
	[isx27423760@i16 ~]$ telnet 35.178.244.131 110
	Trying 35.178.244.131...
	Connected to 35.178.244.131.
	Escape character is '^]'.
	+OK POP3 popserver 2007f.104 server ready
	USER marta
	+OK User name accepted, password please
	PASS marta
	+OK Mailbox open, 1 messages
	RETR 1
	+OK 181 octets
	Received: from ... by ... with ESMTP;
	Subject: Prueba
	From: <marta@edt-orgcom>
	To: <junkdtectr@carolina.rr.com>
	Status: RO
	
	>Esto es una prueba de bustia de correo de MARTA.
	.
	
	-ERR Null command
	QUIT
	+OK Sayonara
	Connection closed by foreign host.
```

#### Comprovacio segura
Amb telnet no es pot llavor ho fem ha openssl_client que hem treballat a classe.

```
[isx27423760@i16 ~]$ openssl s_client -connect 35.178.244.131:995
CONNECTED(00000003)
depth=0 C = --, ST = SomeState, L = SomeCity, O = SomeOrganization, OU = SomeOrganizationalUnit, CN = localhost.localdomain, emailAddress = root@localhost.localdomain
verify error:num=18:self signed certificate
verify return:1
depth=0 C = --, ST = SomeState, L = SomeCity, O = SomeOrganization, OU = SomeOrganizationalUnit, CN = localhost.localdomain, emailAddress = root@localhost.localdomain
verify return:1
---
Certificate chain
 0 s:/C=--/ST=SomeState/L=SomeCity/O=SomeOrganization/OU=SomeOrganizationalUnit/CN=localhost.localdomain/emailAddress=root@localhost.localdomain
   i:/C=--/ST=SomeState/L=SomeCity/O=SomeOrganization/OU=SomeOrganizationalUnit/CN=localhost.localdomain/emailAddress=root@localhost.localdomain
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIETjCCAzagAwIBAgIJANSLg0TG90aCMA0GCSqGSIb3DQEBCwUAMIG7MQswCQYD
VQQGEwItLTESMBAGA1UECAwJU29tZVN0YXRlMREwDwYDVQQHDAhTb21lQ2l0eTEZ
MBcGA1UECgwQU29tZU9yZ2FuaXphdGlvbjEfMB0GA1UECwwWU29tZU9yZ2FuaXph
dGlvbmFsVW5pdDEeMBwGA1UEAwwVbG9jYWxob3N0LmxvY2FsZG9tYWluMSkwJwYJ
KoZIhvcNAQkBFhpyb290QGxvY2FsaG9zdC5sb2NhbGRvbWFpbjAeFw0xOTA1MDMw
OTUwMDdaFw0yMDA1MDIwOTUwMDdaMIG7MQswCQYDVQQGEwItLTESMBAGA1UECAwJ
U29tZVN0YXRlMREwDwYDVQQHDAhTb21lQ2l0eTEZMBcGA1UECgwQU29tZU9yZ2Fu
aXphdGlvbjEfMB0GA1UECwwWU29tZU9yZ2FuaXphdGlvbmFsVW5pdDEeMBwGA1UE
AwwVbG9jYWxob3N0LmxvY2FsZG9tYWluMSkwJwYJKoZIhvcNAQkBFhpyb290QGxv
Y2FsaG9zdC5sb2NhbGRvbWFpbjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
ggEBAMEhUzKT+ZbN3au64qYiQzZplrXGS0G9ztyrYTj0QYX/sR/WVVRw+v3yG0yU
ZBc4bSSLMjOmkwWqOxZBvdakS6cXnYVbVczy3Gg56NvbiaLO0/ACBN4PHnXlwPNZ
nuZALqvaeWszCDKdD0xFKNIMOBFa94rKRjyg6+Oa8iW1PkmmrgVp8rbiVQtxEox8
V2je+RYGm49vetn83sN8beKIkayfie5tm64QsiBFPLCabge7JUHzbCCNPfxz8uCx
58Q46pml8XPpTAt3JMIwRWhpRDjFB/QPp5cBY3eR1xJ18lasoxydCoPNUFJDHkXp
6krD69v1Mstuehq0vspqdqzgOMUCAwEAAaNTMFEwHQYDVR0OBBYEFLqj18Nr7E7h
NqRYYzfaeFtq+RX7MB8GA1UdIwQYMBaAFLqj18Nr7E7hNqRYYzfaeFtq+RX7MA8G
A1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBAAI+FL/6U+GXMSZsD5M4
c5bvXFlacMcNAo1ozoISfx4arSeZK0gu0ZSl1A3Qaht8ElvWLv8LlZY7btgTSfPo
rJjEDcvkiB4FZj+NVi/eFvfXRB0c6wFExipge5sdtttPlHRHb4hRhebhxDn4WgvJ
/K9HXO+9hCdwd3w7KZdOB4HZ+G9AWk0nLWc/iiBHkJJs82koO7nNXc0SFCIsen08
gW1FkKWd75tSqAGDzhfQNUwDFz7YwDrs1TAX6oUaosbpUAJ3hukRngg4cocc6dGe
QqCHZmpYdQ0VlapM58O5IZ1j9P6CcS3Wz+X8FX0ua3zLzIcN/qwjB6EuV5eoFPHW
ZII=
-----END CERTIFICATE-----
subject=/C=--/ST=SomeState/L=SomeCity/O=SomeOrganization/OU=SomeOrganizationalUnit/CN=localhost.localdomain/emailAddress=root@localhost.localdomain
issuer=/C=--/ST=SomeState/L=SomeCity/O=SomeOrganization/OU=SomeOrganizationalUnit/CN=localhost.localdomain/emailAddress=root@localhost.localdomain
---
No client certificate CA names sent
Peer signing digest: SHA512
Server Temp Key: X25519, 253 bits
---
SSL handshake has read 1731 bytes and written 347 bytes
Verification error: self signed certificate
---
New, TLSv1.2, Cipher is ECDHE-RSA-AES256-GCM-SHA384
Server public key is 2048 bit
Secure Renegotiation IS supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
SSL-Session:
    Protocol  : TLSv1.2
    Cipher    : ECDHE-RSA-AES256-GCM-SHA384
    Session-ID: 00836704A00132B191CD65FEB33BF98EB10D708F8B5C3853F3AA4A9B8DD7EF06
    Session-ID-ctx: 
    Master-Key: E64C82135343568AF45C06E3CC33FE0246FA5D86D13AF779250763B3743C38F6664385B73F4DB5CCFFDD86703382DD2E
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    TLS session ticket lifetime hint: 7200 (seconds)
    TLS session ticket:
    0000 - 04 f2 58 5c b1 f3 26 00-bf ef 28 f8 05 04 4c 12   ..X\..&...(...L.
    0010 - d0 fa aa 57 65 0e 6d a9-b0 5d b2 a5 6a 34 57 a3   ...We.m..]..j4W.
    0020 - cf 97 46 16 7e 1b ae 0e-51 c4 70 1f 40 f2 a3 ca   ..F.~...Q.p.@...
    0030 - d8 be 96 79 66 6d f1 8e-2f 7b ea 20 23 d2 dc 2c   ...yfm../{. #..,
    0040 - 60 56 84 11 8f d5 25 42-af 1f 08 21 74 3e e9 10   `V....%B...!t>..
    0050 - b9 8a c3 d4 64 88 03 81-00 af 4e ca 89 97 66 c2   ....d.....N...f.
    0060 - dd bc 50 71 9e 8e 73 f6-47 2a f1 c5 75 be 45 64   ..Pq..s.G*..u.Ed
    0070 - b3 19 c8 77 ff 67 70 1d-c4 da 4a 99 4a bc ac ac   ...w.gp...J.J...
    0080 - 6f 0f 7b cb b8 84 5f 93-49 ce f1 a8 41 e4 c8 b2   o.{..._.I...A...
    0090 - 05 56 9d aa 01 b2 29 ba-ce 43 71 4e 75 ee 76 ca   .V....)..CqNu.v.

    Start Time: 1556878101
    Timeout   : 7200 (sec)
    Verify return code: 18 (self signed certificate)
    Extended master secret: yes
---
+OK POP3 popserver 2007f.104 server ready
USER pere
+OK User name accepted, password please
PASS pere
+OK Mailbox open, 1 messages
RETR 1
RENEGOTIATING
depth=0 C = --, ST = SomeState, L = SomeCity, O = SomeOrganization, OU = SomeOrganizationalUnit, CN = localhost.localdomain, emailAddress = root@localhost.localdomain
verify error:num=18:self signed certificate
verify return:1
depth=0 C = --, ST = SomeState, L = SomeCity, O = SomeOrganization, OU = SomeOrganizationalUnit, CN = localhost.localdomain, emailAddress = root@localhost.localdomain
verify return:1
```

Per marta :
```
[isx27423760@i16 ~]$ openssl s_client -connect 35.178.244.131:995
CONNECTED(00000003)
depth=0 C = --, ST = SomeState, L = SomeCity, O = SomeOrganization, OU = SomeOrganizationalUnit, CN = localhost.localdomain, emailAddress = root@localhost.localdomain
verify error:num=18:self signed certificate
verify return:1
depth=0 C = --, ST = SomeState, L = SomeCity, O = SomeOrganization, OU = SomeOrganizationalUnit, CN = localhost.localdomain, emailAddress = root@localhost.localdomain
verify return:1
---
Certificate chain
 0 s:/C=--/ST=SomeState/L=SomeCity/O=SomeOrganization/OU=SomeOrganizationalUnit/CN=localhost.localdomain/emailAddress=root@localhost.localdomain
   i:/C=--/ST=SomeState/L=SomeCity/O=SomeOrganization/OU=SomeOrganizationalUnit/CN=localhost.localdomain/emailAddress=root@localhost.localdomain
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIETjCCAzagAwIBAgIJANSLg0TG90aCMA0GCSqGSIb3DQEBCwUAMIG7MQswCQYD
VQQGEwItLTESMBAGA1UECAwJU29tZVN0YXRlMREwDwYDVQQHDAhTb21lQ2l0eTEZ
MBcGA1UECgwQU29tZU9yZ2FuaXphdGlvbjEfMB0GA1UECwwWU29tZU9yZ2FuaXph
dGlvbmFsVW5pdDEeMBwGA1UEAwwVbG9jYWxob3N0LmxvY2FsZG9tYWluMSkwJwYJ
KoZIhvcNAQkBFhpyb290QGxvY2FsaG9zdC5sb2NhbGRvbWFpbjAeFw0xOTA1MDMw
OTUwMDdaFw0yMDA1MDIwOTUwMDdaMIG7MQswCQYDVQQGEwItLTESMBAGA1UECAwJ
U29tZVN0YXRlMREwDwYDVQQHDAhTb21lQ2l0eTEZMBcGA1UECgwQU29tZU9yZ2Fu
aXphdGlvbjEfMB0GA1UECwwWU29tZU9yZ2FuaXphdGlvbmFsVW5pdDEeMBwGA1UE
AwwVbG9jYWxob3N0LmxvY2FsZG9tYWluMSkwJwYJKoZIhvcNAQkBFhpyb290QGxv
Y2FsaG9zdC5sb2NhbGRvbWFpbjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
ggEBAMEhUzKT+ZbN3au64qYiQzZplrXGS0G9ztyrYTj0QYX/sR/WVVRw+v3yG0yU
ZBc4bSSLMjOmkwWqOxZBvdakS6cXnYVbVczy3Gg56NvbiaLO0/ACBN4PHnXlwPNZ
nuZALqvaeWszCDKdD0xFKNIMOBFa94rKRjyg6+Oa8iW1PkmmrgVp8rbiVQtxEox8
V2je+RYGm49vetn83sN8beKIkayfie5tm64QsiBFPLCabge7JUHzbCCNPfxz8uCx
58Q46pml8XPpTAt3JMIwRWhpRDjFB/QPp5cBY3eR1xJ18lasoxydCoPNUFJDHkXp
6krD69v1Mstuehq0vspqdqzgOMUCAwEAAaNTMFEwHQYDVR0OBBYEFLqj18Nr7E7h
NqRYYzfaeFtq+RX7MB8GA1UdIwQYMBaAFLqj18Nr7E7hNqRYYzfaeFtq+RX7MA8G
A1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBAAI+FL/6U+GXMSZsD5M4
c5bvXFlacMcNAo1ozoISfx4arSeZK0gu0ZSl1A3Qaht8ElvWLv8LlZY7btgTSfPo
rJjEDcvkiB4FZj+NVi/eFvfXRB0c6wFExipge5sdtttPlHRHb4hRhebhxDn4WgvJ
/K9HXO+9hCdwd3w7KZdOB4HZ+G9AWk0nLWc/iiBHkJJs82koO7nNXc0SFCIsen08
gW1FkKWd75tSqAGDzhfQNUwDFz7YwDrs1TAX6oUaosbpUAJ3hukRngg4cocc6dGe
QqCHZmpYdQ0VlapM58O5IZ1j9P6CcS3Wz+X8FX0ua3zLzIcN/qwjB6EuV5eoFPHW
ZII=
-----END CERTIFICATE-----
subject=/C=--/ST=SomeState/L=SomeCity/O=SomeOrganization/OU=SomeOrganizationalUnit/CN=localhost.localdomain/emailAddress=root@localhost.localdomain
issuer=/C=--/ST=SomeState/L=SomeCity/O=SomeOrganization/OU=SomeOrganizationalUnit/CN=localhost.localdomain/emailAddress=root@localhost.localdomain
---
No client certificate CA names sent
Peer signing digest: SHA512
Server Temp Key: X25519, 253 bits
---
SSL handshake has read 1731 bytes and written 347 bytes
Verification error: self signed certificate
---
New, TLSv1.2, Cipher is ECDHE-RSA-AES256-GCM-SHA384
Server public key is 2048 bit
Secure Renegotiation IS supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
SSL-Session:
    Protocol  : TLSv1.2
    Cipher    : ECDHE-RSA-AES256-GCM-SHA384
    Session-ID: B1D0A5555085CA44B0DD9FA5A3EFF026C2E92F11B7B3075B0AF727BADE3013AB
    Session-ID-ctx: 
    Master-Key: 4948F0D838CBA129AC62997029DD102268DA26C9C5772AD12B7E1E86F91628CE1188DD575C216F237F97B6E3FD0F7933
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    TLS session ticket lifetime hint: 7200 (seconds)
    TLS session ticket:
    0000 - fb 6c 25 57 06 f6 61 84-f8 2c f8 20 08 63 ab 55   .l%W..a..,. .c.U
    0010 - f5 31 1e e3 32 95 03 1c-89 7c 22 c0 17 ff 81 6f   .1..2....|"....o
    0020 - 34 ed f4 9a 0e 99 ca 1a-19 e3 79 c2 07 93 9a d2   4.........y.....
    0030 - 07 47 52 23 dc b2 b0 18-90 ce d5 53 24 61 ab 65   .GR#.......S$a.e
    0040 - 86 b0 83 e6 8e 5d 53 90-0a 59 0a 7c ff fa 86 6b   .....]S..Y.|...k
    0050 - 63 80 eb ab 19 03 5f c6-54 e5 89 89 71 39 09 a7   c....._.T...q9..
    0060 - f7 2f 38 78 ca 2f 61 3e-e3 a3 21 ec c9 15 5d 9c   ./8x./a>..!...].
    0070 - 2b fc 33 ac 3b 6f 40 88-74 a7 c7 89 97 4e 7a c4   +.3.;o@.t....Nz.
    0080 - e6 e2 51 b5 54 dc 16 24-9c c0 16 38 29 e9 c0 e4   ..Q.T..$...8)...
    0090 - f4 17 b0 66 da c4 14 af-0e 62 e0 4c 45 81 8d ac   ...f.....b.LE...

    Start Time: 1556878295
    Timeout   : 7200 (sec)
    Verify return code: 18 (self signed certificate)
    Extended master secret: yes
---
+OK POP3 popserver 2007f.104 server ready
USER pere
+OK User name accepted, password please
PASS pere
+OK Mailbox open, 1 messages
LIST
+OK Mailbox scan listing follows
1 179
.
```

#### Per guardar al nostre github el popserver:

[isx27423760@i16 popserver:19]$ git add .
[isx27423760@i16 exampop]$ git commit -am "examfranlin" 
Pujem al nostre repository
[isx27423760@i16 exampop]$ git push 
Username for 'https://github.com': isx27423760
Password for 'https://isx27423760@github.com': 


##### Per guardar al dockerhub:

[isx27423760@i16 popserver:19]$docker login 
[isx27423760@i16 popserver:19]$docker push francs2/m11franlin
Creem un tag per a la versio definitiva
[isx27423760@i16 popserver:19]$docker tag francs2/m11franlin francs2/m11franlin:v1  
pujem al dockerhub
[isx27423760@i16 popserver:19]$docker push francs2/m11franlin:v1









