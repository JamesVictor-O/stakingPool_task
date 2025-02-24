pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import {BronToken} from "../src/Bron.sol";

contract BronDeploymentScript is Script{
      function setUp() public {}

      function run() public{
            uint deployerPrivateKey=vm.envUint("ACCOUNT_PRIVATE_KEY");
            vm.startBroadcast(deployerPrivateKey);

            BronToken bron = new BronToken("Bron","BON");

            console.log("Token deployed at:", address(bron));
            console.log("Token name:", bron.name());
            console.log("Token symbol:", bron.symbol());
            console.log("Total supply:", bron.totalSupply());

            vm.stopBroadcast();
      }
}
