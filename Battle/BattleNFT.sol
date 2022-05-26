// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./interface/IBattleNFT.sol";
import "./utils/Manageable.sol";
import "./ERC721.sol";


contract BattleNFT is IBattleNFT, ERC721, Manageable {
    using Strings for uint256;
    
    uint256 internal tokenID;

    mapping(uint256 => CAttributes_S) private _cAttributes;

    constructor (string memory _name, string memory _symbol, string memory _baseURI) ERC721(_name, _symbol)  {
        _setBaseURI(_baseURI); 
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public onlyOwner {
        _setTokenURI(tokenId, _tokenURI);
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        _setBaseURI(baseURI_);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory uri = super.tokenURI(tokenId);
        return string(abi.encodePacked(uri, ".json"));
    }

    function mint(address _to, uint256[] memory _basicAttrs, uint256[] memory _skillIds, uint256[] memory _battleAttrs) external override onlyManager {
        tokenID++;
        _mint(_to, tokenID);
        setBasicAttributes(tokenID, _basicAttrs, _skillIds, _battleAttrs);
        string memory cardid = _cAttributes[tokenID].cardIdx.toString();
        string memory tokenidstring = tokenID.toString();
        string memory temp = "/";
        _setTokenURI(tokenID, string(abi.encodePacked(cardid, temp, tokenidstring)));

        emit Mint(_to,tokenID,_basicAttrs[0],_basicAttrs[1],_basicAttrs[2],_basicAttrs[3],_basicAttrs[4],_basicAttrs[5],_basicAttrs[6],_skillIds,_battleAttrs);
    }

    function safeMint(address _to, uint256[] memory _basicAttrs,uint256[] memory _skillIds,uint256[] memory _battleAttrs,bytes memory _data) external override onlyManager {
        tokenID++; 
        _safeMint(_to, tokenID, _data);
        setBasicAttributes(tokenID, _basicAttrs, _skillIds, _battleAttrs);

        emit Mint(_to,tokenID,_basicAttrs[0],_basicAttrs[1],_basicAttrs[2],_basicAttrs[3],_basicAttrs[4],_basicAttrs[5],_basicAttrs[6],_skillIds,_battleAttrs);
    }

    function setBasicAttributes(uint256 _tokenId, uint256[] memory _basicAttrs, uint256[] memory _skillIds, uint256[] memory _battleAttrs) internal validToken(_tokenId) {
        require(_basicAttrs.length == 7, "BattleNFT: WRONG_BASIC_ATTRIBUTE");
        require(_basicAttrs[6] > 0, "BattleNFT: WRONG_GENTERATION");
        require(_skillIds.length > 0, "BattleNFT: EMPTY_SKILLS");
        require(_battleAttrs.length == 6, "BattleNFT: WRONG_BATTLE_ATTRIBUTE");

        _cAttributes[_tokenId].nameIdx = _basicAttrs[0];
        _cAttributes[_tokenId].campIdx = _basicAttrs[1];
        _cAttributes[_tokenId].cardIdx = _basicAttrs[2] ;
        _cAttributes[_tokenId].jobIdx  = _basicAttrs[3] ;
        _cAttributes[_tokenId].classLevel = _basicAttrs[4] ;
        _cAttributes[_tokenId].attrIdx = _basicAttrs[5] ;
        _cAttributes[_tokenId].generation = _basicAttrs[6];

        _cAttributes[_tokenId].skillIds = _skillIds;
        _cAttributes[_tokenId].battleAttrs = _battleAttrs;
    }

    function setBasicAttributes(uint256 _tokenId, uint8 _typeAttributes, uint256 _value, uint256[] memory _values) external override validToken(_tokenId) onlyManager {
        if(_typeAttributes == 1){
            _cAttributes[_tokenId].cardIdx = _value;
        }else if(_typeAttributes == 2){
            _cAttributes[_tokenId].campIdx = _value; 
        }else if(_typeAttributes == 3){
            _cAttributes[_tokenId].cardIdx = _value;
        }else if(_typeAttributes == 4){
            _cAttributes[_tokenId].jobIdx = _value;
        }else if(_typeAttributes == 5){
             _cAttributes[_tokenId].classLevel = _value;
        }else if(_typeAttributes == 6) {
            _cAttributes[_tokenId].attrIdx = _value;
        }else if(_typeAttributes == 7) {
            require(_value > 0, "BattleNFT: WRONG_GENERATION");
            _cAttributes[_tokenId].generation = _value;
        }else if(_typeAttributes == 8) {
            require(_values.length >0, "BattleNFT: WRONT_SKILL");
            _cAttributes[_tokenId].skillIds = _values;
        }else if(_typeAttributes == 9) {
            require(_values.length == 6, "BattleNFT: WRONG_BATTLE_ATTRIBUTE");
            _cAttributes[_tokenId].battleAttrs = _values;
        }

        emit SetBasicAttributes(_tokenId, _typeAttributes, _value, _values);
    }

    function burn(uint256 _tokenId) external override onlyManager {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "BattleNFT: NOT_OWNER_OR_APPROVED");
        _burn(_tokenId);
    }

    function cAttributes(uint256 _tokenId) external view override validToken(_tokenId) returns(CAttributes_S memory) {
        return  _cAttributes[_tokenId];
    }

    function getExtendAttributesLength(uint256 _tokenId) public view override validToken(_tokenId) returns(uint256){
        return _cAttributes[_tokenId].extendsAttrs.length;
    }
    
    function getExtendAttributesValuebyIndex(uint256 _tokenId, uint256 _index) public view override validToken(_tokenId) returns(uint256){
        return _cAttributes[_tokenId].extendsAttrs[_index];
    }

    function setExtendAttributes(uint256 _tokenId,uint256 _index,uint256 _value) external override validToken(_tokenId) {
        require(_index < getExtendAttributesLength(_tokenId), "BattleNFT: OUT_OF_RANGE");

        _cAttributes[_tokenId].extendsAttrs[_index] = _value;

        emit SetExtendAttributes(_tokenId, _index, _value);
    }
    
    function addExtendAttributes(uint256 _tokenId,uint256 _value) external override validToken(_tokenId) {
        _cAttributes[_tokenId].extendsAttrs.push(_value);

        emit AddExtendAttributes(_tokenId, _value);
    }

    function viewTokenID() view public override returns(uint256){
        return tokenID;
    }

}