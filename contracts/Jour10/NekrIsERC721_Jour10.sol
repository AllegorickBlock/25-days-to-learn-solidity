// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";


contract NftContract is ERC721, Ownable {

    using Counters for Counters.Counter;
    using Strings for uint;

    Counters.Counter private _tokenIds;

    enum Step {
        SalesNotStarted,
        WhiteList,
        PublicSale,
        SoldOut
    }

    Step public currentStep;

    bytes32 public merkleRoot;

    uint public constant maxSupply = 10;
    uint public constant maxWhiteList = 5;

    uint whitelListPrice = 0.05 ether;
    uint mintPrice = 0.07 ether;

    mapping(address =>uint) public amountMintByAddress;

    string public baseTokenURI;

    event newMint(address indexed sender, uint256 amount);
    event stepUpdated(Step currentStep);



    constructor(string memory _baseTokenURI, bytes32 _merkleRoot) ERC721 ('AllegoTest', 'ALTT') {
        baseTokenURI = _baseTokenURI;
        merkleRoot = _merkleRoot;
    }

    function updateNFT(string memory _baseTokenURI)external onlyOwner{
        baseTokenURI = _baseTokenURI;
    }

    function setTokenUri(string memory _tokenUri) external{
        baseTokenURI = _tokenUri;
    }

    function mint(uint _count, bytes32[] calldata _proof) external payable{
        require(currentStep == Step.WhiteList || currentStep == Step.PublicSale,"Le mint n'est pas en cour");
        uint currentMintPrice = getCurrentMintPrice();
        uint totalMinted = _tokenIds.current();

        require(totalMinted + _count <= maxSupply, "Max supply depassee");

        if(currentStep == Step.WhiteList){
            require(isWhiteListed(msg.sender,_proof),"Pas whitelist");
            require(amountMintByAddress[msg.sender] + _count == 1,"Limite de mint en whitelist depasse");

        }

        require(msg.value >= currentMintPrice * _count, "Pas assez de fond");

        for(uint i = 0; i < _count; i++){
            uint newTokenId = _tokenIds.current();
            _mint(msg.sender, newTokenId);
            _tokenIds.increment();
            amountMintByAddress[msg.sender]++;
        }

        emit newMint(msg.sender, _count);
    }

    function withdrawContract() public onlyOwner{
        require(address(this).balance > 0,"La balance du contract est vide");
        payable(msg.sender).transfer(address(this).balance);
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

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner{
        merkleRoot = _merkleRoot;
    }

    function _leaf(address _account) internal pure returns (bytes32){
        return keccak256(abi.encodePacked(_account));
    }

    function _verify(bytes32 leaf, bytes32[] memory proof) internal view returns(bool){
        return MerkleProof.verify(proof,merkleRoot,leaf);
    }

    function isWhiteListed(address _account, bytes32[] calldata proof) public view returns(bool){
        return _verify(_leaf(_account),proof);
    }

    function setStep(Step _step) external onlyOwner{
        currentStep = _step;
        emit stepUpdated(_step);
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId),"ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(baseTokenURI, _tokenId.toString()));
    }
}
