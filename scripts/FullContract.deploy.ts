import {run} from "hardhat";
import {GetMerkleRoot} from "./GetMerkleRoot";


async function FullContract(){

    const token = await ethers.getContractFactory("AllegoToken");
    const nft = await ethers.getContractFactory("NftContract");
    const staking = await ethers.getContractFactory("Staking");

    const merkleRoot = GetMerkleRoot();
    const uri = "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/";

    const Token = await token.deploy({gasPrice: 60000000000});
    await Token.deployed();
    await delay(5000);

    try{
        await run(`verify:verify`, {
            address: Token.address,
            constructorArguments: [],
        })
        console.log("Token veirifed");
    } catch(error){
        console.log("Already verified");
    }

    const NFT = await nft.deploy(uri,merkleRoot,{gasPrice:60000000000});
    await NFT.deployed();
    await delay(5000);
 
    try{
        await run('verify:verify',{
            address: NFT.address,
            constructorArguments: [uri,merkleRoot],
        })
        console.log("Token veirifed");
    } catch(error){
        console.log("Already verified");
    }

    const Staking = await staking.deploy(Token.address,NFT.address,{gasPrice: 600000000000});
    await Staking.deployed();
    try{
        await run('verify:verify',{
            address: Staking.address,
            constructorArguments: [Token.address,NFT.address],
        })
        console.log("Token veirifed");
    } catch(error){
        console.log("Already verified");
    }
    await Token.addAdmin(Staking.address);


    console.log("Resume : ")
    console.log("Token address :", Token.address);
    console.log("NFT address :", NFT.address);
    console.log("Staking address :", Staking.address);

}

FullContract().then();

const delay = ms => new Promise(res => setTimeout(res,ms));
