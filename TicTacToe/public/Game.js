
class Game {
	constructor(address, account) {
		this.account = account;
		let ABI = [{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"game","type":"address"}],"name":"GameStarted","type":"event"},{"inputs":[],"name":"newGame","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"nonpayable","type":"function"}];
		this.contract = new web3.eth.Contract(ABI, address);
	}
	
	onGameStarted(cb) {
		this.contract.events.GameStarted({fromBlock: 'latest'}).on('data', (e) => cb(e.returnValues.game));
	}

	async newGame() {
		try {
			// First call allows to get the message from the Solidity's require() statements.
			await this.contract.methods.newGame().call({from: this.account.address});
		} catch(err) {
			err = JSON.parse(err.message.substr(25));
			for (let pn in err.data) {
				if (pn.substr(0, 2) == '0x') {
					alert(err.data[pn].reason);
				}
			}
			return
		}

		// Second send() is to actually execute the transaction.
		let r = await this.contract.methods.newGame().send({from: this.account.address});
		return r;
	}
}