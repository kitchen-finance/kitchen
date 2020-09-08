pragma solidity =0.5.4;

import 'owner.sol';

contract Admin is Ownable {
    address payable public timeLockedAdmin;
    uint256 public effectTime;
    uint256 public delay;

    constructor(uint256 _delay) public {
        delay = _delay;
    }

    modifier onlyAdmin {
        require(isAdmin(), "REQUIRE ADMIN");
        _;
    }

    function setAdmin() public onlyOwner returns (bool) {
        timeLockedAdmin = _msgSender();
        effectTime = block.timestamp + delay;

        return true;
    }

    function renounceAdmin() public onlyAdmin returns (bool) {
        timeLockedAdmin = address(0);
        effectTime = block.timestamp + delay;

        return true;
    }

    function isAdmin() public view returns (bool) {
        return timeLockedAdmin == owner() && block.timestamp >= effectTime;
    }
}