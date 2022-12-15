// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin\contracts\utils\Strings.sol";

contract NftContract is ERC721, Ownable {

    using Counters for Counters.Conter;
    using Strings for uint;

    Counters.Counter private _tokenIds;

    enum Step {
        SalesNotStarted,
        WhiteList,
        PublicSale,
        SoldOut
    }

    Step public currentStep;

    bytes public merkleRoot;

    uint public constant maxSupply = 10;
    uint public constant maxWhiteList = 5;

    uint whitelListPrice = 0.05 ether;
    uint mintPrice = 0.07 ether;

    mapping(address =>uint) public amountMintByAddress;

    string public baseTokenURI;

    event newMint(address indexed sender, uint256 amount);
    event stepUpdated(Step currentStep);


    constructor(string memory _baseTokenURI, byte32 _merkleRoot) ERC721 ('AllegoTest', 'ALTT') {
        baseTokenURI = _baseTokenURI;
        merkleRoot = _merkleRoot;
    }

    function withdrawContract() public onlyOwner{
        require(address(this).balance > 0,"La balance du contract est vide");
        payable(message.sender).transfer(address(this).balance);
    }

    function getCurrentStep() public view returns (Step){
        return currentStep;
    }

    function getCurrentMintPrice() public view returns (uint){
        if(currentStep == Step.WhiteList) return whitelListPrice;
        else return mintPrice;
    }

    function changeWhiteListPrice(uint _newPrice) external onlyOwner{
        whitelListPrice = _newPrice;
    }

    function changeMintPrice(uint _newPrice) external onlyOwner{
        mintPrice = _newPrice;
    }

    //emit newMint(msg.sender, msg.value);

    //emit stepUpdated(_step);


}
