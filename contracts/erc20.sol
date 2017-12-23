pragma solidity ^0.4.4;

contract YourOwnCoin {

  mapping (address => uint256) public balances;
  mapping (address => mapping (address => uint256)) allowances;
  uint256 public total_supply;

  bytes32 public _name;
  uint8 public _decimals;
  bytes32 public _symbols;

  address public main_minter;

  modifier only_minter() {
    if(msg.sender != main_minter){
      throw;
    }
    else {
      _;
    }
  }

  uint256 public buy_Price;
  uint256 public sell_Price;

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  function YourOwnCoin(uint256 _initial_Amount, bytes32 name, uint8 decimals, bytes32 symbol) {
    balances[msg.sender] = _initial_Amount;
    total_supply = _initial_Amount;
    _name = name;
    _decimals = decimals;
    _symbols = symbol;
  }

  function balanceOf(address _address) constant returns (uint256 balance) {
    return  balances[_address];
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return  allowances[_owner][_spender];
  }

  function transfer(address _to, uint256 _value) returns (bool success) {
    if(balances[msg.sender] < _value) {
      throw;
    }
    if(balances[_to] + _value < balances[_to]) {
      throw;
    }
    balances[msg.sender] = balances[msg.sender] - _value;
    balances[_to] = balances[_to] + _value;
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) returns (bool success) {
    allowances[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function transferFrom(address _owner, address _to, uint256 _value) returns (bool success) {
    if(balances[msg.sender] < _value) {
      throw;
    }
    if(balances[_to] + _value < balances[_to]) {
      throw;
    }
    if(allowances[_owner][msg.sender] < _value) {
      throw;
    }
    balances[_owner] = balances[_owner] - _value;
    balances[_to] = balances[_to] + _value;
    allowances[_owner][msg.sender] = allowances[_owner][msg.sender] - _value;
    Transfer(_owner, _to, _value);
    return true;
  }

  function mint(uint256 amount_To_Mint) only_minter() {
    balances[main_minter] = balances[main_minter] + amount_To_Mint;
    total_supply = total_supply + amount_To_Mint;
    Transfer(this, main_minter, amount_To_Mint);
  }

  function change_minter(address _new_Minter) only_minter() {
    main_minter = _new_Minter;
  }

  function set_Prices(uint256 new_sell, uint256 new_buy) only_minter() {
    sell_Price = new_sell;
    buy_Price = new_buy;
  }

  function buy() payable returns (uint amount) {
    amount = msg.value / buy_Price;
    if(balances[main_minter] < amount){
      throw;
    }
    balances[main_minter] = balances[main_minter] - amount;
    balances[msg.sender] = balances[msg.sender] + amount;
    Transfer(main_minter, msg.sender, amount);
    return amount;
  }

  function sell(uint _amount) returns (uint revenue) {
    if(balances[msg.sender] < _amount){
      throw;
    }
    balances[main_minter] = balances[main_minter] + _amount;
    balances[msg.sender] = balances[msg.sender] - _amount;
    revenue = _amount * sell_Price;
    if(!msg.sender.send(revenue)){
      throw;
    }
    else {
      Transfer(msg.sender, main_minter, _amount);
      return revenue;
    }
  }

}
