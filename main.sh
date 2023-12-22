#!/usr/bin/env sh
export GOPROXY="https://proxy.golang.org,direct"

git clone https://github.com/SagerNet/serenity
cd serenity && make install && cd ..
sleep 60
serenity run &
sleep 20

curl -fsS http://localhost:8080/servers > servers.json
curl -fsS http://localhost:8080/servers-lite > servers-lite.json

python main.py servers.json template-ir.json ir.json
python main.py servers.json template-ir-sfw.json ir-sfw.json
python main.py servers-lite.json template-ir.json ir-lite.json
python main.py servers-lite.json template-ir-sfw.json ir-sfw-lite.json

python main.py servers.json template-cn.json cn.json
python main.py servers.json template-cn-sfw.json cn-sfw.json
python main.py servers-lite.json template-cn.json cn-lite.json
python main.py servers-lite.json template-cn-sfw.json cn-sfw-lite.json

git clone https://github.com/SagerNet/sing-box
cd sing-box && make install && cd ..
sleep 60

for i in `ls ir* cn*`; do sing-box -c "$i" check && echo "'$i' is OK!"; done
echo "SUCCESS!"
