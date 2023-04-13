// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC_721 is ERC721 {

    address  _MarketAddress;

    constructor() ERC721("MyToken1", "MTK") {}

    function safeMint(address to, uint256 tokenId) public {
        require(_MarketAddress == msg.sender,"Only Market Can Mint");
        _safeMint(to, tokenId);
    }

    function Setter721(address MarketAddress) external  
    {
       _MarketAddress = MarketAddress;
    }

}

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC_1155 is ERC1155 {

    address public _MarketAddress;

    constructor() ERC1155("") {}


    function mint(address account, uint256 id, uint256 amount, bytes memory data) public
    {
        require(msg.sender == _MarketAddress,"Only Market Can Mint");
        _mint(account, id, amount, data);
    }

    function Setter1155(address MarketAddress) external
    {
        _MarketAddress = MarketAddress;
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts,bytes memory data) public
    {
        _mintBatch(to, ids, amounts, data);
    }
}



contract NFTMarketPlace
{
    uint Time;
    address marketAddress = address(this); 

    uint tokenId;
    ERC_1155 token2 = new ERC_1155();
    ERC_721 token1 = new ERC_721();

    struct Details{

        string ERCType;
        address Owner ;
        uint OnSellTokenId; 
        uint OnSellAmountsOfTokens;
        uint RemainingAmountOfTokens;
        uint TokenSellPrice;

    }

    mapping(address => mapping(uint => Details)) public details;
    mapping(address => mapping(uint => uint)) public MarketPlace;
    mapping(uint  => address) private TokenOwner;
    mapping(address => mapping(uint  => uint)) private NftTokenPrice;


    constructor(address ERC1155Address, address ERC721Address)
    {
        token2 = ERC_1155(ERC1155Address);
        token1 = ERC_721(ERC721Address);
        token1.Setter721(marketAddress);
        token2.Setter1155(marketAddress);
    }


    function Mint(address _owner ,uint256 _quantity) public
    {
        uint _tokenId = tokenId++;

        require(msg.sender == _owner,"Owner Authorization needed");

        Details memory detail = details[msg.sender][_tokenId];

        detail.Owner = _owner;

        if(_quantity == 1 && _quantity >0)
        {
            detail.ERCType = "721";

            token1.safeMint(_owner,_tokenId);

            TokenOwner[_tokenId] = _owner;
        }
        else
        {
            detail.ERCType = "1155";

            token2.mint(_owner,_tokenId,_quantity,"");

            detail.RemainingAmountOfTokens = token2.balanceOf(_owner,_tokenId);

            TokenOwner[_tokenId] = _owner;

        }

        details[msg.sender][_tokenId] = detail;
        
    }



    function SetOnSell(address _owner,uint _tokenId ,uint _tokenPrice,uint _quantity) public
    {
        if(_quantity == 1 && _quantity >0)
        {
            require(msg.sender == token1.ownerOf(_tokenId),"Owner Authorization Needed");

            require(token1.ownerOf(_tokenId) == _owner,"Enter Valid tokenId");

            Details memory detail = details[msg.sender][_tokenId];

            NftTokenPrice[_owner][_tokenId] = _tokenPrice;

            detail.TokenSellPrice = NftTokenPrice[_owner][_tokenId];

            detail.OnSellAmountsOfTokens = _quantity;

            detail.OnSellTokenId = _tokenId;
            
            details[msg.sender][_tokenId] = detail;
        }
        else{

            require(msg.sender == details[msg.sender][_tokenId].Owner,"Owner Authorization Needed");

            require(TokenOwner[_tokenId] == _owner,"Enter Valid tokenId");

            require(token2.balanceOf(_owner,_tokenId) >= _quantity,"Insufficient balance to set On sell");

            Details memory detail = details[msg.sender][_tokenId];

            NftTokenPrice[_owner][_tokenId] = _tokenPrice;

            detail.TokenSellPrice = NftTokenPrice[_owner][_tokenId];

            detail.OnSellAmountsOfTokens = _quantity;

            detail.OnSellTokenId = _tokenId;

            details[msg.sender][_tokenId] = detail;
            
        }

    }

    function VestNft(uint _tokenId , uint _quantity , uint timeInMinute)  public
    {
        require(TokenOwner[_tokenId] == msg.sender,"Enter Valid tokenId");

        require( NftTokenPrice[msg.sender][_tokenId] > 0,"Not in sell");

        require(details[msg.sender][_tokenId].OnSellAmountsOfTokens >= _quantity ,"This much amount not set in sell");

        MarketPlace[address(this)][_tokenId] = _quantity;

        Details memory detail = details[msg.sender][_tokenId];

        detail.OnSellTokenId -= _tokenId;

        detail.OnSellAmountsOfTokens -= _tokenId;

        uint _time  = block.timestamp + timeInMinute*1 minutes;

        Time = _time ;

        details[msg.sender][_tokenId] = detail;
        
    }


    function Redeam(address _owner , uint _tokenId) public
    {
            uint _quantity = MarketPlace[address(this)][_tokenId];
            
            require(TokenOwner[_tokenId] == _owner,"Enter Valid tokenId");

            require(Time  <= block.timestamp,"Locked");

            MarketPlace[address(this)][_tokenId] -= _quantity;

            Details memory detail = details[_owner][_tokenId];

            detail.OnSellTokenId  += _tokenId;

            detail.OnSellAmountsOfTokens += _quantity;

            details[_owner][_tokenId] = detail;

    }
         

}
