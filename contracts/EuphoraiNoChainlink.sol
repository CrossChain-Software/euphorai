// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import '@openzeppelin/contracts/utils/Counters.sol';


contract EuphoraiNoChainlink is ERC721Enumerable, Ownable {
    using SafeMath for uint;
    using Strings for uint;
    using Address for address;
    using Counters for Counters.Counter;
    
    uint256 public price;
    uint256 public immutable maxSupply;
    bool public mintingEnabled = true; // Prob OK to leave on but need to think about it
    bool public whitelistEnabled = false; // Same here ^
    uint256 public buyLimit;
    uint256 public walletLimit;
    mapping(address => bool) public whitelist;
    Counters.Counter private _tokenIds;
    uint8 private _totalSupply = 0;
    

    string private _baseURIPrefix;
    string private _baseExtension = ".json";
    address payable immutable dev;

    constructor (
        string memory _name, 
        string memory _symbol,
        uint256 _maxSupply, 
        uint256 _price, 
        uint256 _buyLimit, 
        string memory _uri, 
        address payable _dev
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
        require(totalMinted().add(quantity) <= maxSupply, "Max supply exceeded");
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