pragma solidity ^0.4.24;


library BMT {
  // TODO: remove recursive call
  function getRoot(bytes32[] memory level)
    internal
    view
    returns (bytes32)
  {
    if (level.length == 1) return level[0];

    bytes32[] memory nextLevel = new bytes32[]((level.length + 1) / 2);
    uint i;

    for(; i + 1 < level.length; i += 2) {
      nextLevel[i/2] = keccak256(abi.encodePacked(level[i], level[i+1]));
    }

    if (level.length % 2 == 1) {
      nextLevel[i/2] = keccak256(
        abi.encodePacked(level[level.length - 1], level[level.length - 1])
      );
    }

    return getRoot(nextLevel);
  }

  function checkMembership(bytes32 leaf, uint256 index, bytes32 rootHash, bytes proof)
      internal
      pure
      returns (bool)
  {
      require(proof.length == 512);
      bytes32 proofElement;
      bytes32 computedHash = leaf;

      for (uint256 i = 32; i <= 512; i += 32) {
          assembly {
              proofElement := mload(add(proof, i))
          }
          if (index % 2 == 0) {
              computedHash = keccak256(computedHash, proofElement);
          } else {
              computedHash = keccak256(proofElement, computedHash);
          }
          index = index / 2;
      }
      return computedHash == rootHash;
  }
}
