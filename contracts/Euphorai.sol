// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import '@openzeppelin/contracts/utils/Counters.sol';
// import "@chainlink/contracts/src/v0.8/dev/VRFConsumerBaseV2.sol"; // Need to use 0.8 to compile with our contract
                                                                  // It doesnt like something with it when you compile

// /**
//   @title 721 contract with lottery logic for minters
//   @author Bradley Woolf and Eric Davis
//   @dev Off-chain storage can be moved to a Merkle Tree for the addresses
  
//   @dev These are the inputs for Rinkeby Testnet, will provide an additional comment for mainnet
//   @param _vrfCoordinator	0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
//   @param _link	0x01BE23585060835E02B77ef475b0Cc51aA1e0709
//   @param _keyHash	0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311
//   @param _fee	0.1 LINK
//  */

contract Euphorai is ERC721Enumerable, Ownable {
    using SafeMath for uint;
    using Strings for uint;
    using Address for address;
    using Counters for Counters.Counter;

    uint256 public price;
    uint256 public immutable maxSupply;
    bool public mintingEnabled;
    bool public whitelistEnabled = true;
    uint256 public buyLimit;
    uint256 public walletLimit;
    mapping(address => bool) public whitelist;
    Counters.Counter private _tokenIds;
    uint8 private _totalSupply = 0;
    

    string private _baseURIPrefix;
    string private _baseExtension = ".json";
    address payable immutable dev;

    // chainlink
    bytes32 keyHash; 
    uint256 fee;
    uint256 public randomResult;

    // winners
    address[] public minters;

    constructor (
        string memory _name, 
        string memory _symbol, 
        uint256 _maxSupply, 
        uint256 _price, 
        uint256 _buyLimit, 
        string memory _uri, 
        address payable _dev
    //    address _vrfCoordinator,
    //    address _linkToken,
    //    bytes32 _keyHash,
    //    uint256 _fee
    ) 
    ERC721(_name, _symbol) {
        maxSupply = _maxSupply;
        price = _price;
        buyLimit = _buyLimit;
        _baseURIPrefix = _uri;
        dev = _dev;
        for (uint i=0; i < 5; i++) { // Mint 200 for ourselves, could probably recycle this to 3 different addresses
          _tokenIds.increment();
          uint256 newItemId = _tokenIds.current();
          _totalSupply += 1;
          _safeMint(_dev, newItemId);
        }
    }

    ///**
    //@param minters An array to store the minters that we select a winner from
    //@dev Can be replaced with a merkle tree for search optimization for O(log(n)) search
    //*/
    // function selectWinner(uint256 userProvidedSeed, address[] minters) onlyOwner {
    //     require(LINK.balanceOf(address(this)) > fee, "Not enough LINK - fill contract with LINK");
    //     bytes32 requestId = requestRandomness(keyHash, fee, userProvidedSeed);

    //     // return the address
    //     return minters[requestId];
    // }

    // function fulfillRandomness(bytes32 requestId, uint256 randomness) { // we might need to cut the second argument because this is standardized by ChainLink
    //     // uint256 randomResult = randomness; 
    //     uint256 randomResult = randomness.mod(minters.length).add(1);
    // }

    function tokenURI(uint256 tokenId) override view public returns (string memory) {
        return bytes(_baseURIPrefix).length > 0 ? string(abi.encodePacked(_baseURIPrefix, tokenId.toString(), _baseExtension)) : "";
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseURIPrefix;
    }

    function setBaseURI(string memory newUri) external onlyOwner {
        _baseURIPrefix = newUri;
    }

    function toggleWhitelist() external onlyOwner {
        whitelistEnabled = !whitelistEnabled;
    }

    function setWhitelist(address[] calldata newAddresses) external onlyOwner {
        for (uint256 i = 0; i < newAddresses.length; i++)
            whitelist[newAddresses[i]] = true;
    }

    function removeWhitelist(address[] calldata currentAddresses) external onlyOwner {
        for (uint256 i = 0; i < currentAddresses.length; i++)
            delete whitelist[currentAddresses[i]];
    }

    function checkWhitelist(address _wallet) view public returns (bool) {
        return whitelist[_wallet];
    }

    function setPrice(uint256 newPrice) external onlyOwner {
        price = newPrice;
    }

    function setBuyLimit(uint256 newBuyLimit) external onlyOwner {
        buyLimit = newBuyLimit;
    }

    function setWalletLimit(uint256 newWalletLimit) external onlyOwner {
        walletLimit = newWalletLimit;
    }

    function toggleMinting() external onlyOwner {
        mintingEnabled = !mintingEnabled;
    }

    function totalMinted() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function mintNFTs(uint256 quantity) external payable {
        require(totalSupply().add(quantity) <= maxSupply, "Max supply exceeded");
        if (_msgSender() != owner()) {
            require(mintingEnabled, "Minting has not been enabled");
            
            if (whitelistEnabled)
                require(whitelist[_msgSender()], "Not whitelisted");
                
            require(quantity <= buyLimit, "Buy limit exceeded");
        }
        require(quantity > 0, "Invalid quantity");
        require(msg.value >= price * quantity, "Incorrect ETH value");
        require(!_msgSender().isContract(), "Contracts are not allowed");

        for (uint i=0; i < quantity; i++) {
          _tokenIds.increment();
          uint256 newItemId = _tokenIds.current();
          _totalSupply += 1;
          _safeMint(msg.sender, newItemId);
          minters.push(_msgSender());
        }
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        uint256 devFee = balance.div(100);
        uint256 amount = balance.sub(devFee);

        dev.transfer(devFee);
        payable(owner()).transfer(amount);
    }
}