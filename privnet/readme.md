## Genesis block
Init genesis block for all three nodes using the json file from the `privnet` folder in this repo.
```
gethx privnode 1 init ~/ethpractice/privnode/genesis.json
gethx privnode 2 init ~/ethpractice/privnode/genesis.json
gethx privnode 3 init ~/ethpractice/privnode/genesis.json
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
gethx privnode 1 --networkid=1001 --bootnodes=enode://7fbe8ff924beeb345fd5905218d575a2f61f7bbf6692cda82153d3c5de4b7ebe3ad994c000759143f3dfc0d809d65ad97117c00120d29bf2a468ae23fc141b85@127.0.0.1:0?discport=30301 -http --http.port "8545" --targetgaslimit 16233158 --rpc.gascap=25000000000000
```

## A miner node
```
gethx privnode 2 --networkid=1001 --bootnodes=enode://7fbe8ff924beeb345fd5905218d575a2f61f7bbf6692cda82153d3c5de4b7ebe3ad994c000759143f3dfc0d809d65ad97117c00120d29bf2a468ae23fc141b85@127.0.0.1:0?discport=30301 --mine --minerthreads=1 --etherbase=0xa8DE3aA8Ba20dA49A337616C998c4f8cDDC20fFC --port=30304
```

## Another node just in case
```
gethx privnode 3 --networkid=1001 --bootnodes=enode://7fbe8ff924beeb345fd5905218d575a2f61f7bbf6692cda82153d3c5de4b7ebe3ad994c000759143f3dfc0d809d65ad97117c00120d29bf2a468ae23fc141b85@127.0.0.1:0?discport=30301 --targetgaslimit 16233158 --rpc.gascap=25000000000000 --port=30305
```

