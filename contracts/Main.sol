//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
//import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Main is Ownable {
    using SafeERC20 for IERC20;
    uint public price = 1 ether;
    uint public id = 1;
    uint public odds = 10;
    address FEE_RECIPIENT;
    constructor() {
        FEE_RECIPIENT = msg.sender;
    }
    function withdrawTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
    }

    function setFeeRecipient(address to) public onlyOwner {
        FEE_RECIPIENT = to;
    }

    function setPrice(uint v) public onlyOwner {
        price = v;
    }

    event OnFlip(address user, uint id, uint premium);

    function flip(uint id) external payable {

        require(msg.value >= price, "invalid amount set");

        uint lastWinnerPremium;

        uint[2] memory sides;
        sides[0] = 0;
        sides[1] = 1;

        (uint _previousBlockNumber, bytes32 _previousBlockHash) = moreRand();
        uint256 _mod = 2;
        uint256 _randomNumber;
        bytes32 _structHash = keccak256(abi.encode(msg.sender, block.difficulty, gasleft(),
            block.timestamp, _previousBlockNumber, _previousBlockHash));
        _randomNumber = uint256(_structHash);
        assembly {_randomNumber := mod(_randomNumber, _mod)}
        uint value = address(this).balance;
        if( sides[_randomNumber] == 1 && value > 0 ){
            uint fee = value / 10;
            lastWinnerPremium = value - fee;
            msg.sender.call{value : lastWinnerPremium}("");
            FEE_RECIPIENT.call{value : fee}("");
        }
        emit OnFlip(msg.sender, id, lastWinnerPremium);

    }

    function moreRand() public view returns (uint, bytes32) {
        uint _previousBlockNumber;
        bytes32 _previousBlockHash;
        _previousBlockNumber = uint(block.number - 1);
        _previousBlockHash = bytes32(blockhash(_previousBlockNumber));
        return (_previousBlockNumber, _previousBlockHash);
    }
}
