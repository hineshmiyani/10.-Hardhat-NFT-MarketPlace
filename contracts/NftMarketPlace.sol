// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/* Error */
error NftMarketPlace__PriceMustBeAbouvZero();
error NftMarketPlace__NotApprovedForMarketPlace();
error NftMarketPlace__AlreadyListed(address nftAddress, uint256 tokenId);
error NftMarketPlace__NotOwner();
error NftMarketPlace__NotListed(address nftAddress, uint256 tokenId);
error NftMarketPlace__PriceNotMet(
  address nftAddress,
  uint256 tokenId,
  uint256 price
);
error NftMarketPlace__NoProceeds();
error NftMarketPlace__TransferFailed();

/* Contract */
contract NftMarketPlace {
  struct Listing {
    uint256 price;
    address seller;
  }

  /* Events */
  event ItemListed(
    address indexed seller,
    address indexed nftAddress,
    uint256 indexed tokenId,
    uint256 price
  );

  event ItemBought(
    address indexed buyer,
    address indexed nftAddress,
    uint256 indexed tokenId,
    uint256 price
  );

  event ItemCanceled(
    address indexed seller,
    address indexed nftAddress,
    uint256 indexed tokenId
  );

  // NFT contract Address => tokenId => Listing
  mapping(address => mapping(uint256 => Listing)) private s_listings;

  // Seller Address => Amount Earned
  mapping(address => uint256) private s_proceeds;

  /* Modifiers */
  modifier notListed(
    address nftAddress,
    uint256 tokenId,
    address owner
  ) {
    Listing memory listing = s_listings[nftAddress][tokenId];
    if (listing.price > 0) {
      revert NftMarketPlace__AlreadyListed(nftAddress, tokenId);
    }
    _;
  }

  modifier isOwner(
    address nftAddress,
    uint256 tokenId,
    address spender
  ) {
    IERC721 nft = IERC721(nftAddress);
    address owner = nft.ownerOf(tokenId);
    if (spender != owner) {
      revert NftMarketPlace__NotOwner();
    }
    _;
  }

  modifier isListed(address nftAddress, uint256 tokenId) {
    Listing memory listing = s_listings[nftAddress][tokenId];
    if (listing.price <= 0) {
      revert NftMarketPlace__NotListed(nftAddress, tokenId);
    }
    _;
  }

  /* Main Functions */
  /**
   * @notice Method for listing your NFT on the marketplace
   * @param nftAddress : Address of the NFT
   * @param tokenId : The Token ID of the NFT
   * @param price : sale price of the listed NFT
   * @dev Technically , we could have the contract be the escrow for the NFTS
   * but this way people can still hold their NFTs when listed .
   */
  function listItem(
    address nftAddress,
    uint256 tokenId,
    uint256 price
  )
    external
    // Challange : Have this contract accept payment in a subset of tokens as well
    // Hint: Use Chainlink Price Feeds to convert the price of the tokens between each other.
    notListed(nftAddress, tokenId, msg.sender)
    isOwner(nftAddress, tokenId, msg.sender)
  {
    if (price <= 0) {
      revert NftMarketPlace__PriceMustBeAbouvZero();
    }

    // Two way to list NFTs
    // 1. Send the NFT to the contract . Transfer => Contract "hold" the NFT.
    // 2. Owners can still hold their NFT , and give the marketplace approval
    // to sell the NFT for them.

    IERC721 nft = IERC721(nftAddress);
    if (nft.getApproved(tokenId) != address(this)) {
      revert NftMarketPlace__NotApprovedForMarketPlace();
    }
    s_listings[nftAddress][tokenId] = Listing(price, msg.sender);

    emit ItemListed(msg.sender, nftAddress, tokenId, price);
  }

  function buyItem(address nftAddress, uint256 tokenId)
    external
    payable
    isListed(nftAddress, tokenId)
  {
    Listing memory listedItem = s_listings[nftAddress][tokenId];
    if (msg.value < listedItem.price) {
      revert NftMarketPlace__PriceNotMet(nftAddress, tokenId, listedItem.price);
    }

    // We don't just send the seller the money...?
    // Sending the money to the user ❌
    // Have them withdraw the money ✅
    s_proceeds[listedItem.seller] = s_proceeds[listedItem.seller] + msg.value;
    delete (s_listings[nftAddress][tokenId]);

    IERC721(nftAddress).safeTransferFrom(
      listedItem.seller, // Seller
      msg.sender, // Buyer
      tokenId
    );

    // check to make sure the NFT was transfered
    emit ItemBought(msg.sender, nftAddress, tokenId, listedItem.price);
  }

  function cancelListing(address nftAddress, uint256 tokenId)
    external
    isOwner(nftAddress, tokenId, msg.sender)
    isListed(nftAddress, tokenId)
  {
    delete (s_listings[nftAddress][tokenId]);
    emit ItemCanceled(msg.sender, nftAddress, tokenId);
  }

  function updateListing(
    address nftAddress,
    uint256 tokenId,
    uint256 newPrice
  )
    external
    isOwner(nftAddress, tokenId, msg.sender)
    isListed(nftAddress, tokenId)
  {
    s_listings[nftAddress][tokenId].price = newPrice;
    emit ItemListed(msg.sender, nftAddress, tokenId, newPrice);
  }

  function withdrawProceeds() external {
    uint256 proceeds = s_proceeds[msg.sender];
    if (proceeds <= 0) {
      revert NftMarketPlace__NoProceeds();
    }
    s_proceeds[msg.sender] = 0;
    (bool success, ) = payable(msg.sender).call{value: proceeds}("");
    if (!success) {
      revert NftMarketPlace__TransferFailed();
    }
  }

  /* Getter Functions */
  function getListing(address nftAddress, uint256 tokenId)
    external
    view
    returns (Listing memory)
  {
    return s_listings[nftAddress][tokenId];
  }

  function getProceeds(address seller) external view returns (uint256) {
    return s_proceeds[seller];
  }
}

// Todos:
// ✅ 1. `listItem` : List NFTS on the marketplace
// ✅ 2. `buyItem` : Buy the NFTs
// ✅ 3. `cancelItem` : Cancel a listing
// ✅ 4. `updateListing` : Update Price
// ✅ 5. `withdrawProceeds` : Withdraw payment for my bought NFTS
