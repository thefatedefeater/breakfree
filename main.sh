#!/usr/bin/env sh
export GOPROXY="https://proxy.golang.org,direct"

git clone https://github.com/SagerNet/serenity
cd serenity && make install && cd ..
serenity run &
sleep 20

curl -fsS http://localhost:8080/servers > servers.json
curl -fsS http://localhost:8080/servers-lite > servers-lite.json

#quick-fix
sed -i s/\;mux\=true//g servers.json servers-lite.json
sed -i s/mux\=true\;//g servers.json servers-lite.json

python main.py servers.json template-ir.json ir.json
python main.py servers.json template-ir-sfw.json ir-sfw.json
python main.py servers-lite.json template-ir.json ir-lite.json
python main.py servers-lite.json template-ir-sfw.json ir-sfw-lite.json
echo "IR files exported!"

python main.py servers.json template-cn.json cn.json
python main.py servers.json template-cn-sfw.json cn-sfw.json
python main.py servers-lite.json template-cn.json cn-lite.json
python main.py servers-lite.json template-cn-sfw.json cn-sfw-lite.json
echo "CN files exported!"

git clone https://github.com/SagerNet/sing-box
cd sing-box && git checkout main && make install && cd ..

for i in ir*.json cn*.json; do sing-box -c "$i" check && echo "'$i' is OK!"; done

mv ir*.json cn*.json release/Sing-Box/
echo "SUCCESS!"
