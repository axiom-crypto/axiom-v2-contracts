// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/// @title  AxiomProxy
/// @notice Proxy to an Axiom contract.
contract AxiomProxy is ERC1967Proxy {
    /// @notice Construct a new AxiomProxy contract.
    /// @param  implementation The address of the initial implementation.
    /// @param  _data The data to send to the implementation when initializing.
    constructor(address implementation, bytes memory _data) ERC1967Proxy(implementation, _data) { }
}
