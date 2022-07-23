// SPDX-License-Identifier: MIT
import "./IERC721.sol";

pragma solidity ^0.8.9;

contract Market {
    // 1 List of tokens
    // 2 Buy tokens
    // 3 Chatting

    enum ListingStatus {
        Active,
        Sold,
        Cancelled
    }

    struct Listing {
        ListingStatus status;   
        address seller;
        address token;
        uint tokenId;
        uint price;
    }

    event Recieve (
        address,
        uint 
    );

    event Listed(
        uint listingId,
        address seller,
        address token,
        uint tokenId,
        uint price
    );

    event Sale(
        uint listingId,
        address buyer,
        address token,
        uint tokenId,
        uint price
    );


    event Cancel(
        uint ListindId,
        address seller
    );

    uint256 private _listingId = 0;
    mapping(uint => Listing) private _listings;

    function listToken(address token, uint tokenId, uint price) public {
        IERC721(token).transferFrom(msg.sender, address(this), tokenId);

        Listing memory listing = Listing(
            ListingStatus.Active,
            msg.sender,
            token,
            tokenId,
            price * 1 ether
        );
        _listingId++;

        _listings[_listingId] = listing;

        emit Listed(
            _listingId,
            msg.sender,
            token,
            tokenId,
            price
        );
    } 


    function getListing(uint listingId) public view returns (Listing memory) {
        return _listings[listingId];
    }


    function buyToken(uint listingId) payable external {
        Listing memory listing = _listings[listingId];
        
        require(msg.sender != listing.seller, "Seller can not be buyer");

        require(listing.status == ListingStatus.Active, "Listing is not active");
        
        require(msg.value > listing.price, "Insufficient payment");
        
        IERC721(listing.token).transferFrom(address(this), msg.sender, listing.tokenId);
        payable(listing.seller).transfer(listing.price);

        emit Sale(
            listingId,
            msg.sender,
            listing.token,
            listing.tokenId,
            listing.price
        );

    }

    function cancel(uint listingId) public {
        Listing storage listing = _listings[listingId];

        require(listing.status == ListingStatus.Active, "Listing is not active");
        require(msg.sender == listing.seller, "Only seller can cancel listing");

        listing.status = ListingStatus.Cancelled;
        

        IERC721(listing.token).transferFrom(address(this), msg.sender, listing.tokenId);

        emit Cancel(listingId, listing.seller);
    }
}