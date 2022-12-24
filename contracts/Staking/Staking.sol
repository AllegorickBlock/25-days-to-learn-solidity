// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../Jour14/AllegoERC20.sol";
import "../Jour10/NekrIsERC721_Jour10.sol";

contract Staking {

    AllegoToken token;
    NftContract nft;

    uint totalStaked;

    struct StakingStruct{
        uint nftId;
        uint startTimestamp;
        address owner;
    }

    mapping(uint => StakingStruct) public structById;

    uint rewardPerHour = 0.5 * 10 ** 18;

    event staked(address indexed owner, uint256 nftId, uint timeStamp);
    event unstaked(address indexed owner, uint256 nftId, uint timeStamp);
    event claim(address indexed owner, uint reward);

    constructor(AllegoToken _token , NftContract _nft){
        token = _token;
        nft = _nft;
    }

    function staking(uint[] calldata tokenIds) external {
        for(uint i = 0; i< tokenIds.length; i++){
            require(msg.sender == nft.ownerOf(tokenIds[i]),"Vous n'etes pas le propriétaire de ce nft");
            require(structById[tokenIds[i]].startTimestamp == 0,"Already staked");
            nft.transferFrom(msg.sender, address (this),tokenIds[i]);
            emit staked(msg.sender,tokenIds[i],block.timestamp);

            structById[tokenIds[i]] = StakingStruct({
                nftID: tokenIds[i],
                startTimestamp: block.timestamp,
                owner: msg.sender
            });
        }
        totalStaked += tokenIds.length;
    }
}
