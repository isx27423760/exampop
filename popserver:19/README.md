# POP SERVER
## @edt ASIX M11-SAD Curs 2018-2019

Podeu trobar les imatges docker al Dockehub de [francs2](https://hub.docker.com/u/francs2/)

Creem la xarxe interna per al pop
[isx27423760@i16 popserver:19]$ docker network create popnet

Contruim la imatge de pop
[isx27423760@i16 popserver:19]$ docker build -t francs2/exampop .

Per a amzon poden executar amb els porta mapejats
#### Execució
```
docker run --rm --name popserver -h popserver --net popnet -d francs2/exampop
```
