const { ethers } = require("hardhat");
export {};
async function main() {
    // COMMANDE À LANCER : yarn hardhat run .\scripts\HelloWorld.deploy.ts --network polygonMumbai

    // On récupère le contrat via son nom
    const contract = await ethers.getContractFactory("AllegoToken");
    // On le déploie
    const Contract = await contract.deploy();
    console.log("Deploying contract...");
    // On attend que le contrat soit déployé
    await Contract.deployed();
    console.log("Contract deployed to:", Contract.address);
    // Commande pour vérifier le contrat déployé sur l'explorateur de blocs
    console.log("hardhat verify --network polygonMumbai", Contract.address); // verify the contract
}

main().then();
