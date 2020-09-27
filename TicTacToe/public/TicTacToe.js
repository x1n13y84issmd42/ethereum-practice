
class TicTacToe {
	constructor(address, account) {
		this.account = account;
		let ABI = [{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"x","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"y","type":"uint256"},{"indexed":false,"internalType":"enum TicTacToe.CellState","name":"symbol","type":"uint8"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"Move","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"addr","type":"address"},{"indexed":false,"internalType":"string","name":"name","type":"string"},{"indexed":false,"internalType":"enum TicTacToe.CellState","name":"symbol","type":"uint8"}],"name":"PlayerJoined","type":"event"},{"anonymous":false,"inputs":[{"components":[{"internalType":"string","name":"name","type":"string"},{"internalType":"enum TicTacToe.CellState","name":"symbol","type":"uint8"},{"internalType":"address payable","name":"addr","type":"address"},{"internalType":"uint256","name":"bets","type":"uint256"}],"indexed":false,"internalType":"struct TicTacToe.Player","name":"winner","type":"tuple"}],"name":"Win","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"x1","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"y1","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"x2","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"y2","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"x3","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"y3","type":"uint256"}],"name":"WinRow","type":"event"},{"inputs":[{"internalType":"enum TicTacToe.GameState","name":"","type":"uint8"}],"name":"GameStateNames","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"OPlayer","outputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"enum TicTacToe.CellState","name":"symbol","type":"uint8"},{"internalType":"address payable","name":"addr","type":"address"},{"internalType":"uint256","name":"bets","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"XPlayer","outputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"enum TicTacToe.CellState","name":"symbol","type":"uint8"},{"internalType":"address payable","name":"addr","type":"address"},{"internalType":"uint256","name":"bets","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"_own","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"board","outputs":[{"internalType":"enum TicTacToe.CellState","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"claimPrize","outputs":[],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getBoard","outputs":[{"internalType":"enum TicTacToe.CellState[9]","name":"","type":"uint8[9]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"name","type":"string"}],"name":"joinO","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string","name":"name","type":"string"}],"name":"joinX","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"x","type":"uint256"},{"internalType":"uint256","name":"y","type":"uint256"}],"name":"move","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"state","outputs":[{"internalType":"enum TicTacToe.GameState","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"verify","outputs":[],"stateMutability":"nonpayable","type":"function"}];
		this.contract = new web3.eth.Contract(ABI, address);
	}
	
	onMove(cb) {
		this.contract.events.Move({fromBlock: 'latest'}).on('data', (e) => cb(e.returnValues.x, e.returnValues.y, e.returnValues.symbol, e.returnValues.amount));
	}

	onPlayerJoined(cb) {
		this.contract.events.PlayerJoined({fromBlock: 'latest'}).on('data', (e) => cb(e.returnValues.addr, e.returnValues.name, e.returnValues.symbol));
	}

	onWin(cb) {
		this.contract.events.Win({fromBlock: 'latest'}).on('data', (e) => cb(e.returnValues.winner));
	}

	onWinRow(cb) {
		this.contract.events.WinRow({fromBlock: 'latest'}).on('data', (e) => cb(e.returnValues.x1, e.returnValues.y1, e.returnValues.x2, e.returnValues.y2, e.returnValues.x3, e.returnValues.y3));
	}

	async GameStateNames() {
		let r = await this.contract.methods.GameStateNames().call({from: this.account.address});
		return r;
	}

	async OPlayer() {
		let r = await this.contract.methods.OPlayer().call({from: this.account.address});
		return {name: r.name, symbol: r.symbol, addr: r.addr, bets: r.bets};
	}

	async XPlayer() {
		let r = await this.contract.methods.XPlayer().call({from: this.account.address});
		return {name: r.name, symbol: r.symbol, addr: r.addr, bets: r.bets};
	}

	async _own() {
		try {
			// First call allows to get the message from the Solidity's require() statements.
			await this.contract.methods._own().call({from: this.account.address});
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
		let r = await this.contract.methods._own().send({from: this.account.address});
		return {};
	}

	async board() {
		let r = await this.contract.methods.board().call({from: this.account.address});
		return r;
	}

	async claimPrize() {
		let r = await this.contract.methods.claimPrize().call({from: this.account.address});
		return {};
	}

	async getBoard() {
		let r = await this.contract.methods.getBoard().call({from: this.account.address});
		return r;
	}

	async joinO(name) {
		try {
			// First call allows to get the message from the Solidity's require() statements.
			await this.contract.methods.joinO(name).call({from: this.account.address});
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
		let r = await this.contract.methods.joinO(name).send({from: this.account.address});
		return {};
	}

	async joinX(name) {
		try {
			// First call allows to get the message from the Solidity's require() statements.
			await this.contract.methods.joinX(name).call({from: this.account.address});
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
		let r = await this.contract.methods.joinX(name).send({from: this.account.address});
		return {};
	}

	async move(x, y) {
		try {
			// First call allows to get the message from the Solidity's require() statements.
			await this.contract.methods.move(x, y).call({from: this.account.address});
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
		let r = await this.contract.methods.move(x, y).send({from: this.account.address});
		return {};
	}

	async state() {
		let r = await this.contract.methods.state().call({from: this.account.address});
		return r;
	}

	async verify() {
		try {
			// First call allows to get the message from the Solidity's require() statements.
			await this.contract.methods.verify().call({from: this.account.address});
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
		let r = await this.contract.methods.verify().send({from: this.account.address});
		return {};
	}
}