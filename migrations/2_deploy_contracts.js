var erc20 = artifacts.require("./erc20.sol");

module.exports = function(deployer) {

  deployer.deploy(erc20);

};
