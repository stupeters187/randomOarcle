const RandomOracle = artifacts.require('./RandomOracle.sol');
const Strings = artifacts.require('./Utils/Strings.sol');
const Integers = artifacts.require('./Utils/Integers.sol');


module.exports = function(deployer) {
  deployer.deploy(Strings);
  deployer.deploy(Integers);
  deployer.link(Integers, RandomOracle);
  deployer.link(Strings, RandomOracle);
  deployer.deploy(RandomOracle);

}
