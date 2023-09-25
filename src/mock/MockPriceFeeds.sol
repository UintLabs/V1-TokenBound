// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MockAggregatorV3 {
  function decimals() external pure returns (uint8){
    return uint8(8);
  }

  function description() external view returns (string memory){}

  function version() external view returns (uint256){}

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound){}

  function latestRoundData()
    external
    pure
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound){
        roundId = 18446744073709558066;
        answer = 157366323098;
        startedAt = 1695636420;
        updatedAt = 1695636420;
        answeredInRound = 18446744073709558066;
    }
}
