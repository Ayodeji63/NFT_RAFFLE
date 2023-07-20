// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import "./eip4671/ERC4671.sol";

contract Ticket is ERC4671 {
    constructor() ERC4671("Raffle_Ticket", "RFT") {}
}
