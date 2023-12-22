#!/usr/bin/env sh

git clone https://github.com/SagerNet/serenity.git
cd serenity
git checkout "ca68443caecfee4debf364b8ec992b91c8644cab"
go install -ldflags "-s -w" ./cmd/serenity
sleep 60
./serenity run &
cd ..
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

go install github.com/sagernet/sing-box/cmd/sing-box@latest

for i in `ls ir* cn*`; do sing-box -c "$i" check && echo "$i is OK!"; done
echo "SUCCESS!"
