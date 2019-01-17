pragma solidity ^0.4.24;

import "./API/oraclizeAPI_0.5.sol";
import "./Utils/Strings.sol";
import "./Utils/Integers.sol";

contract RandomOracle is usingOraclize {

    using Strings for string;
    using Integers for uint;

    uint public parsedResult;
    uint public serialNumberUint;
    uint public randomNumberUint;

    mapping(bytes32 => bool) validIds;
    uint constant gasLimitForOraclize = 175000;

    event LogOraclizeQuery(string description);
    event LogResultReceived(uint number);

    constructor() public {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        oraclize_setCustomGasPrice(1000000000 wei);
    }

    function getRandomNumber() public payable {
        require(msg.value >= 0.000175 ether);
        bytes32 queryId = oraclize_query(
          "nested",
          "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random[\"serialNumber\",\"data\"]', '\\n{\"jsonrpc\": \"2.0\", \"method\": \"generateSignedIntegers\", \"params\": { \"apiKey\": \"00000000-0000-0000-0000-000000000000\", \"n\": 1, \"min\": 1, \"max\": 100000, \"replacement\": true, \"base\": 10 }, \"id\": 14215 }']",
          gasLimitForOraclize);
        emit LogOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        validIds[queryId] = true;
    }

    function __callback(bytes32 queryId, string result, bytes proof) public {
        require(msg.sender == oraclize_cbAddress());
        require(validIds[queryId]);

        parsedResult = parseInt(result);

        parseSerialNumber(parsedResult);
        parseRandomNumber(parsedResult);

        emit LogResultReceived(parsedResult);
        validIds[queryId] = false;
    }

    function parseSerialNumber(uint _result) internal {
        uint uintToParseForSerialNum = _result;
        string memory parsedResultString = uintToParseForSerialNum.toString();
        serialNumberUint = parseInt(parsedResultString.substring(7));
    }

    function parseRandomNumber(uint _result) internal {
        uint uintToParseForRandomNum = _result;
        string memory parsedResultUint = uintToParseForRandomNum.toString();
        randomNumberUint = parseInt(parsedResultUint._substring(5,7));
    }
}
