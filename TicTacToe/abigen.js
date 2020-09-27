let fs = require('fs');

let fileABI = process.argv[2];
let contractName = fileABI.split('.')[0];
let fileOut = process.argv[3] || `${contractName}.js`;

let ABI = JSON.parse(fs.readFileSync(fileABI));

let gen = {
	argsProto: (inputs) => {
		return inputs.map(a => a.name).join(', ');
	},

	argsCall: (inputs) => {
		return inputs.map(a => a.name).join(', ');
	},

	fnView: (fName, inputs, outputs) => {
		return `
	async ${fName}(${gen.argsProto(inputs)}) {
		let r = await this.contract.methods.${fName}(${gen.argsCall(inputs)}).call({from: this.account.address});
		return ${gen.fnReturn(outputs)};
	}`
	},
	
	fn: (fName, inputs, outputs) => {
		return `
	async ${fName}(${gen.argsProto(inputs)}) {
		try {
			// First call allows to get the message from the Solidity's require() statements.
			await this.contract.methods.${fName}(${gen.argsCall(inputs)}).call({from: this.account.address});
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
		let r = await this.contract.methods.${fName}(${gen.argsCall(inputs)}).send({from: this.account.address});
		return ${gen.fnReturn(outputs)};
	}`
	},

	fnReturn: (outputs) => {
		outputs = outputs || [];
		if (outputs.length == 1) {
			return 'r';
		} else {
			return '{' + outputs.map(o => `${o.name}: r.${o.name}`).join(', ') + '}';
		}
	},

	evtHandler: (evtName, evtArgs) => {
		let eArgs = evtArgs.map(a => `e.returnValues.${a.name}`).join(', ');
		return `
	on${evtName}(cb) {
		this.contract.events.${evtName}({fromBlock: 'latest'}).on('data', (e) => cb(${eArgs}));
	}`
	},

	classContract: (cName, ABI) => {
		let classContents = [];

		for (let i of ABI) {
			switch(i.type) {
				case 'function':
					if (i.stateMutability == 'view' || i.stateMutability == 'pure') {
						classContents.push(gen.fnView(i.name, i.inputs, i.outputs));
					} else {
						classContents.push(gen.fn(i.name, i.inputs, i.outputs));
					}
				break;
		
				case 'event':
					classContents.push(gen.evtHandler(i.name, i.inputs));
				break;
			}
		}

		return `
class ${cName} {
	constructor(address, account) {
		this.account = account;
		let ABI = ${JSON.stringify(ABI)};
		this.contract = new web3.eth.Contract(ABI, address);
	}
	${classContents.join('\n')}
}`;
	}, 
};

fs.writeFileSync(fileOut, gen.classContract(contractName, ABI));
console.log(`Saved as ${fileOut}`);
