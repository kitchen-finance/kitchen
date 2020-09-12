pragma solidity =0.5.4;

import "TRC20.sol";
import "TRC20Detail.sol";
import "remedy.sol";

contract KIT is TRC20, TRC20Detailed, AdminRemedy {
    constructor () TRC20Detailed("Kitchen", "KIT", 18) public {
        super._mint(msg.sender, 420000 * 10**18);
    }

    function burn(uint256 amount) public returns (bool) {
        super._burn(_msgSender(), amount);
        return true;
    }
}
