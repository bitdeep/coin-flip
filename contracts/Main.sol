//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Main is Ownable {
    using SafeERC20 for IERC20;
    uint public minAmount = 0.01 ether;
    uint public multiplier = 2;
    uint public odds = 2;
    address FEE_RECIPIENT;

    struct Flip {
        address sender;
        uint amount;
        uint datetime;
        uint premium;
    }

    mapping(uint => Flip) public flips;
    uint public flipCount;
    constructor() {
        FEE_RECIPIENT = msg.sender;
    }
    function withdrawTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
    }

    function setFeeRecipient(address to) public onlyOwner {
        FEE_RECIPIENT = to;
    }

    function setMinAmount(uint v) public onlyOwner {
        minAmount = v;
    }
    function setMultiplier(uint v) public onlyOwner {
        multiplier = v;
    }
    function setOdds(uint v) public onlyOwner {
        odds = v;
    }

    event OnFlip(address user, uint premium);

    function flip() external payable {

        require(msg.value >= minAmount, "invalid amount sent");

        uint lastWinnerPremium;

        uint[] memory sides = new uint[](odds);
        sides[1] = 1;

        (uint _previousBlockNumber, bytes32 _previousBlockHash) = moreRand();
        uint256 _randomNumber;
        bytes32 _structHash = keccak256(abi.encode(msg.sender, block.difficulty, gasleft(),
            block.timestamp, _previousBlockNumber, _previousBlockHash, flipCount));
        _randomNumber = uint256(_structHash);
        uint _mod = odds;
        assembly {_randomNumber := mod(_randomNumber, _mod)}
        uint value = msg.value * multiplier;
        console.log('o=%s rnd=%s side=%s', odds, _randomNumber, sides[_randomNumber]);
        if( value > address(this).balance )
            value = address(this).balance;
        if (sides[_randomNumber] == 1 && value > 0) {
            uint fee = value / 10;
            lastWinnerPremium = value - fee;
            msg.sender.call{value : lastWinnerPremium}("");
            FEE_RECIPIENT.call{value : fee}("");
        }
        flips[flipCount++] = Flip(msg.sender, msg.value, block.timestamp, lastWinnerPremium);
        emit OnFlip(msg.sender, lastWinnerPremium);

    }

    function moreRand() public view returns (uint, bytes32) {
        uint _previousBlockNumber;
        bytes32 _previousBlockHash;
        _previousBlockNumber = uint(block.number - 1);
        _previousBlockHash = bytes32(blockhash(_previousBlockNumber));
        return (_previousBlockNumber, _previousBlockHash);
    }

    function getFlip(uint id) public view returns (Flip memory){
        return flips[id];
    }

}
