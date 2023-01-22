const { ethers } = require("hardhat");+
import {GetMerkleRoot} from "./GetMerkleRoot";
export {};
async function main() {
    // COMMANDE À LANCER : yarn hardhat run .\scripts\HelloWorld.deploy.ts --network polygonMumbai

    // On récupère le contrat via son nom
    const merkleRoot = GetMerkleRoot();
        const uri = "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq";

    const nft = await ethers.getContractFactory("NftContract");
    // On le déploie


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



    //console.log("Deploying contract...");
    // On attend que le contrat soit déployé
    //await Contract.deployed();
   // console.log("Contract deployed to:", Contract.address);
    // Commande pour vérifier le contrat déployé sur l'explorateur de blocs
   // console.log("hardhat verify --network polygonMumbai", Contract.address); // verify the contract
}

main().then();
