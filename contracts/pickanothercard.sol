 
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

interface IVerifier {
    function verifyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[2] memory input
    ) external view returns (bool);
}

contract PickAnotherCard {
    address public verifierAddr;

    constructor(address _verifierAddr) {
        verifierAddr = _verifierAddr;
    }

    function verifyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[2] memory input
    ) public view returns (bool) {
        return IVerifier(verifierAddr).verifyProof(a, b, c, input);
    }

    function verifyPickAnotherCard(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[2] memory input
    ) public view returns (bool) {
        require(
            verifyProof(a, b, c, input),
            "Filed proof check"
        );
        return true;
    }
}
