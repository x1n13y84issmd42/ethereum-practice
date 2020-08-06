var ethx = {
	authenticate: function() {
		return personal.unlockAccount(eth.accounts[0], 'fubared');
	},

	run: function(contractPath) {
		var slugs = contractPath.split(":");
		var fname = slugs[0].replace(".sol", ".js");
		var contractName = contractPath.split('/', 2)[1]

		loadScript(fname);
		ethx.execute(TheContract, contractName)
	},

	execute: function(contractData, contractName, options) {
		var compiled = web3.eth.contract(JSON.parse(contractData.contracts[contractName].abi));

		// console.log('Estimating gas...');
		// var gas = eth.estimateGas({
		// 	code: "0x" + contractData.contracts[contractName].bin,
		// });
		// console.log("The contract " + contractName + " requires " + gas + " gas.");

		var input = {
			from: eth.accounts[0],
			data: "0x" + contractData.contracts[contractName].bin,
			gas: 1000,
			gasPrice: 500,
		};

		var inst = compiled.new(
			input,
			function (e, contract) {
				console.log(e, contract);

				if(!contract.address) {
					console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");
				} else {
					console.log("Contract mined! Address: " + contract.address);
					console.log(contract);
				}
			}
		);
	},
};
