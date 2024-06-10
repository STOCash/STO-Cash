// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Lockable is Ownable {
    constructor() Ownable(msg.sender) {

    }

    mapping(address => bool) private _blockStatus;

    function isLocked(address to) public view returns (bool) {
        return _blockStatus[to];
    }

    function lock(address to) public onlyOwner {
        require(to != owner(), 'cannot lock owner address');
        require(!isLocked(to), 'address already locked');
        _blockStatus[to] = true;
    }

    function unlock(address to) public onlyOwner {
        require(isLocked(to), 'address not locked');
        _blockStatus[to] = false;
    }
}

contract STOCash is ERC20, ERC20Burnable, Pausable, Ownable, Lockable {

    bool public mintFinished;

    constructor() ERC20("STO Cash", "STOC") {
        mintFinished = false;

        _mint(msg.sender, 10000000000 * 10 ** decimals());
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mintFinish() public onlyOwner {
        require(!mintFinished, 'Mint already finished');

        mintFinished = true;
    }


    function _update(address from, address to, uint256 amount) internal virtual override // Add virtual here!
    {
        if (from == address(0)) {
            require(!mintFinished, 'Mint was finished');
        }
        require(!isLocked(from), "from account was locked.");
        require(!isLocked(to), "to account was locked.");
        super._update(from, to, amount);
    }

    function symbol() public virtual view override returns (string memory)
    {
        return "STOC";
    }
}
