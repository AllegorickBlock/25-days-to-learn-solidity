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
    event claimed(address indexed owner, uint reward);

    constructor(AllegoToken _token , NftContract _nft){
        token = _token;
        nft = _nft;
    }

    function staking(uint[] calldata tokenIds) external {
        uint totalStaked;

        for(uint i = 0; i< tokenIds.length; i++){
            require(msg.sender == nft.ownerOf(tokenIds[i]),"Vous n'etes pas le proprietaire de ce nft");
            require(structById[tokenIds[i]].startTimestamp == 0,"Already staked");
            nft.transferFrom(msg.sender, address (this),tokenIds[i]);
            emit staked(msg.sender,tokenIds[i],block.timestamp);

            structById[tokenIds[i]] = StakingStruct({
                nftId: tokenIds[i],
                startTimestamp: block.timestamp,
                owner: msg.sender
            });
        }
        totalStaked += tokenIds.length;
    }

    function getRewardsPending(address _owner,uint[] calldata tokenIds) external view returns(uint){
        uint totalReward;
        for(uint i = 0;i< tokenIds.length;i++){
            require(structById[tokenIds[i]].owner == _owner,"Pas le meme proprietaire");

            uint startTime = structById[tokenIds[i]].startTimestamp;

            totalReward += (block.timestamp-startTime) / 3600 * rewardPerHour;
        }

        return totalReward;
    }

    function claim(uint[] calldata tokenIds) external {
        _claim(msg.sender,tokenIds,false);
    }

    //Bool : @param  1 unstake , 0 keep staked
    function _claim(address _owner, uint[] calldata tokenIds,bool _unstake) internal {
        uint totalReward;
        for(uint i = 0;i< tokenIds.length;i++){
            require(structById[tokenIds[i]].owner == _owner,"Pas le meme proprietaire");

            uint startTime = structById[tokenIds[i]].startTimestamp;

            totalReward += (block.timestamp-startTime) / 3600 * rewardPerHour;

            if(_unstake)structById[tokenIds[i]].startTimestamp = block.timestamp;
            //structById[tokenIds[i]] = StakingStruct({
            //    nftID: tokenIds[i],
            //    startTimestamp: block.timestamp,
            //    owner: msg.sender
            //});
        }

        token.mint(_owner,totalReward);

        if(_unstake){
            _unstakeNFT(_owner,tokenIds);
        }

        emit claimed(_owner,totalReward);

    }

    function unstake(uint[] calldata tokenIds) external {
        _claim(msg.sender,tokenIds,true);
    }

    function _unstakeNFT(address _owner, uint[] calldata tokenIds) internal {
        uint totalStaked;
        for(uint i = 0;i< tokenIds.length;i++){
            require(_owner == structById[tokenIds[i]].owner,"Pas le proprio des nft");
            delete structById[tokenIds[i]];

            nft.transferFrom(address(this),_owner,tokenIds[i]);

            emit unstaked(_owner,tokenIds[i],block.timestamp);
        }
        totalStaked -= tokenIds.length;
    }

    function tokenByOwner(address _owner) external view returns(uint[] memory){
        uint maxSupply = nft.maxSupply();
        uint[] memory tempList = new uint[](maxSupply);
        uint stakedCount = 0;

        for(uint i = 0;i< maxSupply;i++){
            if(structById[i].owner == _owner){
                tempList[i]=i;
                stakedCount++;
            }
        }

        uint[] memory nftList = new uint[](stakedCount);
        for(uint i = 0;i<stakedCount;i++){
            nftList[i]=tempList[i];
        }

        return nftList;
    }
}
