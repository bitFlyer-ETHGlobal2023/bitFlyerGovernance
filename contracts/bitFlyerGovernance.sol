// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract bitFlyerGovernance is ERC721, Ownable {
    bytes32 public merkleRoot;
    mapping (address => bool) public claimed;
    mapping (uint => uint256) public lockedAmount;
    mapping (uint => uint256) public lockedUntilTime;
    mapping (uint => string) public lockedToken;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("bitFlyerGovernance", "bFGovernance") {
    }


    function setMerkleRoot(bytes32 merkleRootExternal) external onlyOwner {
        merkleRoot = merkleRootExternal;
    }
        
    function mint (string calldata token, uint256 amount, uint256 timestamp, bytes32[] calldata proof) 
        external 
        isValidMerkleProof(token, amount, timestamp, proof, merkleRoot) {
        require(!claimed[msg.sender], "bitFlyerGovernance: NFT already minted.");
        uint256 tokenId = _tokenIds.current();
        _safeMint(msg.sender, tokenId);

        // Set metadata.
        tokenURI(tokenId);

        // Update state
        claimed[msg.sender] = true;
        lockedAmount[tokenId] = amount;
        lockedUntilTime[tokenId] = timestamp;
        lockedToken[tokenId] = token;

        // Increment tokenId
        _tokenIds.increment();
    }

    function _leaf (address account, string memory token, uint256 amount, uint256 timestamp) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(account, "-", token, "-", amount, "-", timestamp));
    }

    modifier isValidMerkleProof(string memory token, uint256 amount, uint256 timestamp, bytes32[] calldata proof, bytes32 root) {
        require(
            MerkleProof.verify(proof, root, _leaf(msg.sender, token, amount, timestamp)),
            "bitFlyerGovernance: Invalid proof."
        );
        _;
    }

    // TODO: Update tokenURI method after backend done.
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        /*
        string memory baseURI = "https://www.<backend>.com/metadata/";
        string memory currentToken = lockedToken[tokenId];
        return string(abi.encodePacked(baseURI, currentToken, "/", tokenId));
        */

        return "https://www.jsonkeeper.com/b/2SMS";
    }

    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "bitFlyerGovernance: caller is not owner nor approved");
        _burn(tokenId);

        // Update state
        claimed[msg.sender] = false;
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public override {
    // Disable transfers by throwing an exception
    revert("Transfers are disabled");
    }
}

