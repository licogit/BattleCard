
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./utils/Manageable.sol";
import "./interface/IGodNFT.sol";
import "./ERC721.sol";


contract GodNFT is IGodNFT, ERC721, Manageable {
    using Strings for uint256;

    mapping(uint256 => CAttributes_S) private _cAttributes;

    constructor (string memory _name, string memory _symbol, string memory _baseURI) ERC721(_name, _symbol)  {
        _setBaseURI(_baseURI); 
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) external onlyOwner {
        _setTokenURI(tokenId, _tokenURI);
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        _setBaseURI(baseURI_);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory uri = super.tokenURI(tokenId);
        return string(abi.encodePacked(uri, ".json"));
    }

    function mint(
        address _to, 
        uint256 _tokenId, 
        uint256 _nameIdx,  
        uint256 _campIdx,
        uint256 _godIdx, 
        uint256 _rarityIdx, 
        uint256 _skillID, 
        uint256[] memory _canCreate) external override onlyManager {
        _mint(_to, _tokenId);
        setBasicAttributes(_tokenId, _nameIdx, _campIdx, _godIdx, _rarityIdx, _skillID, _canCreate);

        string memory godid = _godIdx.toString();
        string memory tokenidstring = _tokenId.toString();
        string memory temp = "/";
        _setTokenURI(_tokenId, string(abi.encodePacked(godid, temp, tokenidstring)));
        
        emit Mint(_to, _tokenId, _nameIdx, _campIdx, _godIdx, _rarityIdx, _skillID, _canCreate);
    }

    function safeMint(
        address _to,
        uint256 _tokenId, 
        uint256 _nameIdx,  
        uint256 _campIdx, 
        uint256 _godIdx,
        uint256 _rarityIdx, 
        uint256 _skillID, 
        uint256[] memory _canCreate, 
        bytes memory _data) external override onlyManager {
        _safeMint(_to, _tokenId, _data);
        setBasicAttributes(_tokenId, _nameIdx, _campIdx, _godIdx, _rarityIdx, _skillID, _canCreate);

        emit Mint(_to, _tokenId, _nameIdx, _campIdx, _godIdx, _rarityIdx, _skillID, _canCreate);
    }

    function setBasicAttributes(uint256 _tokenId, uint256 _nameIdx,  uint256 _campIdx, uint256 _godIdx, uint256 _rarityIdx, uint256 _skillID, uint256[] memory _canCreate) public validToken(_tokenId) onlyManager {
        require(_canCreate.length > 0, "GodNFT: canCreate is empty");

        _cAttributes[_tokenId].nameIdx = _nameIdx;
        _cAttributes[_tokenId].campIdx = _campIdx;
        _cAttributes[_tokenId].godIdx = _godIdx;
        _cAttributes[_tokenId].rarityIdx = _rarityIdx;
        _cAttributes[_tokenId].skillID = _skillID;
        _cAttributes[_tokenId].canCreate = _canCreate;
    }

    function setBasicAttributes(uint256 _tokenId, uint8 _typeAttributes, uint256 _value, uint256[] memory _values) external override validToken(_tokenId) onlyManager {
        if(_typeAttributes == 1){
            _cAttributes[_tokenId].nameIdx = _value;
        }else if(_typeAttributes == 2){
            _cAttributes[_tokenId].campIdx = _value; 
        }else if(_typeAttributes == 3){
            _cAttributes[_tokenId].godIdx = _value;
        }else if(_typeAttributes == 4){
            _cAttributes[_tokenId].rarityIdx = _value;
        }else if(_typeAttributes == 5){
            _cAttributes[_tokenId].skillID = _value;
        }else if(_typeAttributes == 6){
            require(_values.length > 0, "GodNFT: canCreate is empty");
            _cAttributes[_tokenId].canCreate = _values;
        }

        emit SetBasicAttributes(_tokenId, _typeAttributes, _value, _values);
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

    function setExtendAttributes(uint256 _tokenId,uint256 _index,uint256 _value) external override validToken(_tokenId){
        require(_index < getExtendAttributesLength(_tokenId), "GodNFT: index out of range.");

        _cAttributes[_tokenId].extendsAttrs[_index] = _value;

        emit SetExtendAttributes(_tokenId, _index, _value);
    }
    
    function addExtendAttributes(uint256 _tokenId,uint256 _value) external override validToken(_tokenId) {
        _cAttributes[_tokenId].extendsAttrs.push(_value);

        emit AddExtendAttributes(_tokenId, _value);
    }


}