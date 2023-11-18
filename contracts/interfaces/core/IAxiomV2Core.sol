// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IAxiomV2Verifier } from "./IAxiomV2Verifier.sol";
import { IAxiomV2Update } from "./IAxiomV2Update.sol";
import { IAxiomV2State } from "./IAxiomV2State.sol";
import { IAxiomV2Events } from "./IAxiomV2Events.sol";

/// @title The interface for the core Axiom V2 contract
/// @notice The Axiom V2 contract stores a continually updated cache of all historical block hashes
/// @dev The interface is broken up into many smaller pieces
interface IAxiomV2Core is IAxiomV2Events, IAxiomV2State, IAxiomV2Update, IAxiomV2Verifier { }
