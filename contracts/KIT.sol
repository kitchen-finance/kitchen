pragma solidity =0.5.4;

import "TRC20.sol";
import "TRC20Detail.sol";
import "admin.sol";

contract Liquor is TRC20, TRC20Detailed, Admin {

  constructor () TRC20Detailed("Kitchen", "KIT", 8) public {
    owner = msg.sender;
  }

  function mint(address account, uint amount) external onlyOwner returns (bool)  {
    return super._mint(account, amount);
  }
}