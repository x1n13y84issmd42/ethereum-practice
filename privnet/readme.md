## Accounts
Create few accounts.

## Genesis block
Add accounts' keys to the `genesis.json`.

Init genesis block for all nodes using the json file from the `privnet` folder in this repo.
```
gethx privnode miner init ~/ethpractice/privnet/genesis.json
gethx privnode rpc init ~/ethpractice/privnet/genesis.json
gethx privnode n1 init ~/ethpractice/privnet/genesis.json
gethx privnode n2 init ~/ethpractice/privnet/genesis.json
```

## Accounts' keys
Copy them from wherever the accounts were created.
```
cp .ethereum/privnet/keystore/* .ethereum/privnode_miner/keystore/ 
cp .ethereum/privnet/keystore/* .ethereum/privnode_rpc/keystore/ 
cp .ethereum/privnet/keystore/* .ethereum/privnode_n1/keystore/ 
cp .ethereum/privnet/keystore/* .ethereum/privnode_n2/keystore/ 
```

## A bootnode
It is used in development for node discovery. Other nodes use a bootnode's `enode` URL.
```
bootnode --nodekey=.ethereum/privnet/bootnode.key
```

Generate the key if you don't have one.
```
bootnode --genkey=.ethereum/privnet/bootnode.key
```

## An HTTP RPC node
MetaMask will connect there.

```
gethx privnode rpc --networkid=1001 --bootnodes=enode://7fbe8ff924beeb345fd5905218d575a2f61f7bbf6692cda82153d3c5de4b7ebe3ad994c000759143f3dfc0d809d65ad97117c00120d29bf2a468ae23fc141b85@127.0.0.1:0?discport=30301 -http --http.port "8545" --targetgaslimit 16233158 --rpc.gascap=25000000000000
```

## A miner node
```
gethx privnode miner --networkid=1001 --bootnodes=enode://7fbe8ff924beeb345fd5905218d575a2f61f7bbf6692cda82153d3c5de4b7ebe3ad994c000759143f3dfc0d809d65ad97117c00120d29bf2a468ae23fc141b85@127.0.0.1:0?discport=30301 --mine --minerthreads=1 --etherbase=0xa8DE3aA8Ba20dA49A337616C998c4f8cDDC20fFC --port=30304
```

## Another couple of nodes just in case
```
gethx privnode n1 --networkid=1001 --bootnodes=enode://7fbe8ff924beeb345fd5905218d575a2f61f7bbf6692cda82153d3c5de4b7ebe3ad994c000759143f3dfc0d809d65ad97117c00120d29bf2a468ae23fc141b85@127.0.0.1:0?discport=30301 --targetgaslimit 16233158 --rpc.gascap=25000000000000 --port=30305
```

```
gethx privnode n2 --networkid=1001 --bootnodes=enode://7fbe8ff924beeb345fd5905218d575a2f61f7bbf6692cda82153d3c5de4b7ebe3ad994c000759143f3dfc0d809d65ad97117c00120d29bf2a468ae23fc141b85@127.0.0.1:0?discport=30301 --targetgaslimit 16233158 --rpc.gascap=25000000000000 --port=30305
```

