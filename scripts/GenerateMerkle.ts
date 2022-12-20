const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');
const whitelist = require('../assets/whitelist.json');

function GenerateMerkle() {
    let wlTab = []; // Tableau des adresses de la whitelist

    // Itération sur toutes les adresses de la whitelist pour les ajouter au tableau
    whitelist.map(a => {
        wlTab.push(a.address);
    })

    // Création des feuilles de l'arbre de merkle
    const leaves = wlTab.map(a => keccak256(a));

    // Création de l'arbre de merkle
    const tree = new MerkleTree(leaves, keccak256, { sort: true });

    // Récupération de la racine de l'arbre de merkle
    const root = tree.getHexRoot();
    console.log("Whitelist root :", root);

    const addressToCheck = "0x76945B4FEA08f6d14F69d18d4A263E30f3b4721A";
    // Vérification de l'existence d'une adresse dans l'arbre de merkle
    const proof = tree.getHexProof(keccak256(addressToCheck));
    console.log('Merkle proof for', addressToCheck, ':', proof);
}

GenerateMerkle();

