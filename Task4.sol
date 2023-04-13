// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC721{
    constructor() ERC721("MyToken", "MTK") {}

    function safeMint(address owner, uint256 tokenId) public{
        _safeMint(owner, tokenId);
    }
}

contract NftMarketPlace
{
    uint private HighestPrice;

    address User ;

    uint TokenId;

    struct Details{
        address Owner ;
        uint TokenId;
        uint Wallet; 

    }

    struct Details2{
        uint TokenId;
        uint PriceAmount;
    }

    MyToken token = new MyToken();

    mapping(address => mapping(uint => Details)) public details;
    mapping(address => Details2) public NftToken;
    mapping(address => mapping(uint => uint )) Bidder;

    constructor(address MyTokenAddress)
    {
        token = MyToken(MyTokenAddress);
    }

    

    function Mint(address _owner , uint tokenId) public
    {
        Details memory detail = details[_owner][tokenId];

        detail.Owner = _owner;

        require(msg.sender == _owner,"Owner Authorization Needed");
        token.safeMint(_owner,tokenId);

        detail.TokenId = tokenId;

        details[_owner][tokenId] = detail;



    }



    function SetNftOnBid(address _owner,uint tokenId ,uint _tokenPrice) public
    {
        require(msg.sender == token.ownerOf(tokenId),"Owner Authorization Needed");
        require( token.ownerOf(tokenId) == _owner,"Enter Valid tokenId");

        Details2 memory detail = NftToken[_owner];

        detail.PriceAmount = _tokenPrice;
        detail.TokenId = tokenId;

        NftToken[_owner] = detail;

    }


     

    function BidOnNft(address user , uint Amount, uint tokenId) public
    {  require(msg.sender == token.ownerOf(tokenId),"Owner Authorization needed");
       require(Amount != HighestPrice,"Price given");
       require(NftToken[msg.sender].TokenId == tokenId,"Token is not in Bid");
       require(Amount >= NftToken[msg.sender].PriceAmount,"Amount must be Greater than");
       require(user != token.ownerOf(tokenId),"Owner can not Bid his Own Nft");

        User = user;
        TokenId =tokenId;
        if(Amount > HighestPrice)
        {
            HighestPrice = Amount;
        }

    }

    function FetchHighestBit() public view returns(uint)
    {
        return HighestPrice;
    }

    function EndAuction() public
    {
            Details memory detail= details[User][TokenId];
            require(msg.sender == token.ownerOf(TokenId),"Only token owner can End Auction");
            detail.TokenId= 0;

            detail.Owner =  0x0000000000000000000000000000000000000000;

            detail.Wallet += HighestPrice;

            details[User][TokenId] = detail;

            NftToken[User].TokenId = 0;
            NftToken[User].PriceAmount = 0;

            Details memory detail2 = details[User][TokenId];

            detail2.TokenId = TokenId;
            detail2.Owner = User;
            
            details[User][TokenId] = detail2;
    }

}