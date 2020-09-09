pragma solidity =0.5.4;

import "ITRC20.sol";
import "remedy.sol";
import "SafeMath.sol";

contract Vote is ITRC20, AdminRemedy {
  using SafeMath for uint256;

  uint256 public start;
  uint256 public end;
  bool public stoped;

  ITRC20 trc20;

  bytes32[] public options;
  uint256 public length;
  mapping(address=>uint256) public userVoteCount;
  mapping(uint256=>uint256) public proposalsVoteCount;

  constructor(uint256 _start, uint256 _end, address trc20Address, bytes32[] memory proposals) public AdminRemedy(8 hours) {
    start = _start;
    end = _end;
    trc20 = ITRC20(trc20Address);
    length = proposals.length;
    for (uint256 i = 0; i < proposals.length; i++) {
      options.push(proposals[i]);
    }
  }

  function stop() public onlyOwner returns (bool) {
    stoped = true;
    return true;
  }

  modifier whenStart {
    require(canVote(), "NOT START");
    _;
  }

  modifier whenEnd {
    uint256 _now = blocktime();
    require(stoped || _now >= end, "NOT END");
    _;
  }

  function canVote() public view returns (bool) {
    uint256 _now = blocktime();
    return !stoped && start <= _now && _now <= end;
  }

  function blocktime() private view returns (uint256) {
    return block.timestamp;
  }

  function vote(uint256 option, uint256 count) public whenStart returns (bool) {
    require(option < length, "INVALID OPTION");
    require(trc20.transferFrom(_msgSender(), address(this), count), "REQUIRE TRANSFER SUCCESS");
    uint256 voted = userVoteCount[_msgSender()];
    userVoteCount[_msgSender()] = voted.add(count);
    uint256 optionVoted = proposalsVoteCount[option];
    proposalsVoteCount[option] = optionVoted.add(count);
    return true;
  }

  function exit() public whenEnd returns (bool) {
    uint256 voted = userVoteCount[_msgSender()];
    require(trc20.transfer(_msgSender(), voted), "REQUIRE TRANSFER SUCCESS");
    userVoteCount[_msgSender()] = 0;
    return true;
  }
}
