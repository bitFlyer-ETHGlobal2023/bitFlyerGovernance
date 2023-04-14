// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract bitFlyerGovernance is Ownable {
    bytes32 public merkleRoot;
    mapping (address => bool) public claimed;

    function setMerkleRoot(bytes32 merkleRootExternal) external onlyOwner {
        merkleRoot = merkleRootExternal;
    }
        
    function mint (uint256 amount, uint256 timestamp, bytes32[] calldata proof) 
        external 
        isValidMerkleProof(amount, timestamp, proof, merkleRoot) {
        require(!claimed[msg.sender], "MerkleDistributor: Drop already claimed.");
        //_mint(msg.sender, amount, timestamp);
        claimed[msg.sender] = true;
    }

    function _leaf (address account, uint256 amount, uint256 timestamp) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(account, "-", amount, "-", timestamp));
    }

        modifier isValidMerkleProof(uint256 amount, uint256 timestamp, bytes32[] calldata proof, bytes32 root) {
        require(
            MerkleProof.verify(proof, root, _leaf(msg.sender, amount, timestamp)),
            "MerkleDistributor: Invalid proof."
        );
        _;
    }


    // When burn set claimed to false;
}

