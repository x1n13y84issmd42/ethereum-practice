// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.6.8;

contract Ownable {
	address payable _owner;
	
	modifier only_owner() {
		if (_owner == msg.sender) {
			_;
		}
	}
	
	function _own() public {
		_owner = msg.sender;
	}
}

contract TicTacToe is Ownable {
	// TYPES
	struct Player {
		string name;
		CellState symbol;
		address payable addr;
		uint bets;
	}
	
	
	enum CellState {
		Empty,
		X,
		O
	}
	
	enum GameState {
		Created,
		XMove,
		OMove,
		XWins,
		OWins,
		Draw       // Everyone gets their bets back.
	}
	
	// PROPERTIES
	//................................................................
	CellState[9] public board;
	
	Player public XPlayer;
	Player public OPlayer;
	
	GameState public state;

	mapping(GameState => string) public GameStateNames;
	
	// EVENTS
	//................................................................
	event PlayerJoined(address addr, string name, CellState symbol);
	event Move(uint x, uint y, CellState symbol, uint amount);
	
	// METHODS
	//................................................................
	constructor() {
		_own();
		state = GameState.Created;
		
		// For nicer messages from at_state modifier.
		GameStateNames[GameState.Created] = "Created";
		GameStateNames[GameState.XMove] = "X player move";
		GameStateNames[GameState.OMove] = "O player move";
		GameStateNames[GameState.XWins] = "X player wins";
		GameStateNames[GameState.OWins] = "O player wins";
		GameStateNames[GameState.Draw] = "Draw";
	}
	
	modifier only_player() {
		if (state == GameState.XMove) {
			require(msg.sender == XPlayer.addr, "Only the X player is allowed to move.");
		} else if (state == GameState.OMove) {
			require(msg.sender == OPlayer.addr, "Only the O player is allowed to move.");
		}
		
		_;
	}
	
	modifier at_state(GameState s) {
		 require(state == s, string(abi.encodePacked(
			"Operation is possible only in the ",
			GameStateNames[s],
			" state. Currently it is ",
			GameStateNames[state],
			"."
		)));
		
		_;
	}
	
	modifier only_at_game_state() {
		require(state == GameState.XMove || state == GameState.OMove, "This action is only possible when the game is in progress.");
		
		_;
	}
	
	function getBoard() public view returns (CellState[9] memory) {
		return board;
	}
	
	function joinX(string memory name) at_state(GameState.Created) public {
		require(XPlayer.addr == address(0), "The X player slot is already taken.");
		require(OPlayer.addr != msg.sender, "Playing with yourself is uncool. Go get some friends you loser.");
		XPlayer.addr = msg.sender;
		XPlayer.name = name;
		XPlayer.symbol = CellState.X;
		emit PlayerJoined(msg.sender, name, CellState.X);
		
		if (OPlayer.addr != address(0)) {
			state = GameState.XMove;
		}
	}
	
	function joinO(string memory name) at_state(GameState.Created) public {
		require(OPlayer.addr == address(0), "The O player slot is already taken.");
		require(XPlayer.addr != msg.sender, "Playing with yourself is uncool. Go get some friends you loser.");
		OPlayer.addr = msg.sender;
		OPlayer.name = name;
		OPlayer.symbol = CellState.O;
		emit PlayerJoined(msg.sender, name, CellState.O);
		
		if (XPlayer.addr != address(0)) {
			state = GameState.XMove;
		}
	}
	
	function move(uint x, uint y) external payable only_at_game_state only_player {
		require(x >= 0 && x < 3, "X is out of bounds.");
		require(y >= 0 && y < 3, "Y is out of bounds.");
		require(board[x + y * 3] == CellState.Empty, "This cell is already taken.");
		
		if (msg.sender == XPlayer.addr) {
			board[x + y * 3] = CellState.X;
			state = GameState.OMove;
		} else {
			board[x + y * 3] = CellState.O;
			state = GameState.XMove;
		}
		
		emit Move(x, y, board[x + y * 3], msg.value);
		
		verify();
	}
	
	function verify() public {
		verifyRow(0, 0, 0, 1, 0, 2);
		verifyRow(1, 0, 1, 1, 1, 2);
		verifyRow(2, 0, 2, 1, 2, 2);

		verifyRow(0, 0, 1, 0, 2, 0);
		verifyRow(0, 1, 1, 1, 2, 1);
		verifyRow(0, 2, 1, 2, 2, 2);

		verifyRow(0, 0, 1, 1, 2, 2);
		verifyRow(2, 0, 1, 1, 0, 2);
		
		// TODO: verify the draw scenario
	}
	
	function verifyRow(uint x1, uint y1, uint x2, uint y2, uint x3, uint y3) only_at_game_state /*only_player*/ private {
		CellState cs;
		cs = board[x1+y1*3];
		if (cs != CellState.Empty && cs == board[x2+y2*3] && cs == board[x3+y3*3]) {
			if (cs == CellState.X) {
				state = GameState.XWins;
			} else {
				state = GameState.OWins;
			}
		}
	}
	
	function claimPrize() /*only_player*/ public view {
		if (state == GameState.Draw) {
			// TODO: transfer their bets
			return;
		}
		
		if (msg.sender == XPlayer.addr && state == GameState.XWins) {
			// TODO: transfer all funds
			return;
		}

		if (msg.sender == OPlayer.addr && state == GameState.OWins) {
			// TODO: msg.sender.transfer()
			return;
		}
	}
}

contract Game {
	event GameStarted(address game);

	function newGame() external returns(address) {
		TicTacToe g = new TicTacToe();
		emit GameStarted(address(g));
		return address(g);
	}
}
