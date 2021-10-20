// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import "hardhat/console.sol";

/// @notice A keeper pushes a price of token
/// @dev Find out the avg price of token for a time interval without iterating in for-loop
contract Strips is Ownable, Pausable {

    using SafeMath for uint256;

    // ==========State variables====================================

    // struct definition
    struct Price {
        uint256 currentPrice;   // current price at a timestamp
        uint256 totalPrice;     // total Price yet from 1st timestamp to till date
        bool exist;             // to check if the timestamp is valid
        uint256 index;          // index of timestamp/price. This is to get the total count 
    }

    // mapping of token address & mapping of timestamp & Price struct
    mapping( address => mapping(uint256 => Price) ) public mapTstampPrice;

    // total price till date
    uint256 public totalPrice;

    // next available index
    uint256 public availableIndex;


    // ==========Events=============================================
    event SetPrice(address indexed keeper, address indexed token, )

    // ==========Constructor========================================
    constructor() {}

    // ==========Functions==========================================
    function setPrice(address _token, uint256 _timestamp, uint256 _price) external whenNotPaused {
        require( _token != address(0), "token address must not be zero" );
        require( _timestamp > 0, "timestamp must be positive" );
        require( _price > 0, "price must be positive" );

        mapTstampPrice[_token][_timestamp].currentPrice = _price;
        mapTstampPrice[_token][_timestamp].exist = true;
        mapTstampPrice[_token][_timestamp].index = availableIndex;

        // add the current price to totalPrice
        totalPrice = totalPrice.add(_price);

        mapTstampPrice[_token][_timestamp].totalPrice = totalPrice;

        // increment the index of price/timestamp
        availableIndex = availableIndex.add(1);


    }

    /// @notice Get Average Price of a token with address for a time range
    function getAvgPrice(address _token, uint256 _startTimestampRange, uint256 _finishTimestampRange) external view returns (uint256) {
        require( _token != address(0), "token address must not be zero" );
        require (mapTstampPrice[_token][_startTimestampRange].exist, "Invalid start timestamp range");
        require (mapTstampPrice[_token][_finishTimestampRange].exist, "Invalid finish timestamp range");
        require (_startTimestampRange < _finishTimestampRange, "start timestamp must be less than finish timestamp range");

        uint256 avgPrice = 0;
        uint256 rangeTotalPrice = mapTstampPrice[_token][_finishTimestampRange].totalPrice
                                        .sub(mapTstampPrice[_token][_startTimestampRange].totalPrice);


        uint256 count = mapTstampPrice[_token][_finishTimestampRange].index
                                        .sub(mapTstampPrice[_token][_startTimestampRange].index);


        avgPrice = rangeTotalPrice.div(count);


        return avgPrice;

    }

}
