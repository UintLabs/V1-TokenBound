// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract MockAggregatorV3 {
    function decimals() external pure returns (uint8) {
        return uint8(8);
    }

    function description() external view returns (string memory) { }

    function version() external view returns (uint256) { }

    function getRoundData(uint80 _roundId)
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    { }

    function latestRoundData()
        external
        pure
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        roundId = 18_446_744_073_709_558_066;
        answer = 157_366_323_098;
        startedAt = 1_695_636_420;
        updatedAt = 1_695_636_420;
        answeredInRound = 18_446_744_073_709_558_066;
    }
}
