docker-compose stop

rm -rf logs/*
rm -rf cert/*.pem
rm -rf cert/*.csr
cd cert
cfssl gencert -initca ca-csr.json | cfssljson -bare ca -

echo '{"CN":"tidb-server","hosts":[""],"key":{"algo":"rsa","size":2048}}' | cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server -hostname="172.18.0.8,tidb,127.0.0.1" - | cfssljson -bare tidb-server &&  echo '{"CN":"tikv-server","hosts":[""],"key":{"algo":"rsa","size":2048}}' | cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server -hostname="172.18.0.5,172.18.0.6,172.18.0.7,tikv0,tikv1,tikv2,127.0.0.1" - | cfssljson -bare tikv-server && echo '{"CN":"pd-server","hosts":[""],"key":{"algo":"rsa","size":2048}}' | cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server -hostname="172.18.0.2,172.18.0.3,172.18.0.4,pd0,pd1,pd2,127.0.0.1" - | cfssljson -bare pd-server

cd ..

docker-compose up -d
