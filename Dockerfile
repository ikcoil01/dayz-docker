#docker build -t dayz-test --build-arg STEAM_USER=****** --build-arg STEAM_PASSWORD=********* .
#docker run -p 2302:2302/udp -p 2303:2303/udp -p 2304:2304/udp -p 2305:2305/udp -p 27016:27016/udp -t dayz-test
FROM redhat/ubi9
ARG STEAM_USER
ARG STEAM_PASSWORD
RUN yum install glibc.i686 libstdc++.i686 wget -y
RUN mkdir -p ~/servers/steamcmd && cd ~/servers/steamcmd
RUN wget "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
RUN cp steamcmd_linux.tar.gz /root/servers/steamcmd/
WORKDIR /root/servers/steamcmd
RUN tar zxvf /root/servers/steamcmd/steamcmd_linux.tar.gz
RUN ~/servers/steamcmd/steamcmd.sh +force_install_dir ~/servers/dayz-server/ +login ${STEAM_USER} ${STEAM_PASSWORD} +app_update 223350 +quit
WORKDIR /root/servers/dayz-server/
RUN tee modstemp.txt <<EOF
@ShutdownOnFailedCommand 1
@NoPromptForPassword 0
force_install_dir /root/servers/dayz-server/mods
login ${STEAM_USER} ${STEAM_PASSWORD}
workshop_download_item 221100 1559212036
quit
EOF
RUN mkdir /root/servers/dayz-server/mods
RUN ~/servers/steamcmd/steamcmd.sh +runscript /root/servers/dayz-server/modstemp.txt
RUN mv /root/servers/dayz-server/mods/steamapps/workshop/content/221100/1559212036 /root/servers/dayz-server/@CF
RUN mv /root/servers/dayz-server/@CF/keys/Jacob_Mango_V3.bikey /root/servers/dayz-server/keys
EXPOSE 2302/udp
EXPOSE 2303/udp
EXPOSE 2304/udp
EXPOSE 2305/udp
EXPOSE 27016/udp
COPY serverDZ.cfg /root/servers/dayz-server
CMD /root/servers/dayz-server/DayZServer -config=serverDZ.cfg -port=2305 -BEpath=battleye -profiles=profiles -dologs -adminlog -netlog -freezecheck -mod=@CF;
