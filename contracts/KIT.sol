pragma solidity =0.5.4;

import "TRC20.sol";
import "TRC20Detail.sol";
import "remedy.sol";

contract KIT is TRC20, TRC20Detailed, AdminRemedy {

  constructor () TRC20Detailed("Kitchen", "KIT", 8) public {
  }

  function mint(address account, uint amount) external onlyOwner returns (bool)  {
    return super._mint(account, amount);
  }
}