// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract LuckyDip is IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    //Token Parameters
    string private constant _name = "TestToken";
    string private constant _symbol = "TST";
    uint8 private constant _decimals = 18;

    //Total Supply
    uint256 private _totalSupply = 100000000 * 10**_decimals;

    //Tax Receiving adresses
    address public constant developerWallet = 0x000000000000000000000000000000000000dead;
    address public constant lotteryFundWallet = 0x000000000000000000000000000000000000dead;

    //Tax amounts in percentage
    uint256 private _taxFeePercent = 1;
    uint256 private _lotteryFundFeePercent = 4;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor() {
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    // ERC-20 internal functions

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 taxFee = amount.mul(_taxFeePercent).div(100);
        uint256 lotteryFundFee = amount.mul(_lotteryFundFeePercent).div(100);
        uint256 finalAmount = amount.sub(taxFee).sub(lotteryFundFee);

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(finalAmount);

        _balances[developerWallet] = _balances[developerWallet].add(taxFee);
        _balances[lotteryFundWallet] = _balances[lotteryFundWallet].add(lotteryFundFee);

        emit Transfer(sender, recipient, finalAmount);
        emit Transfer(sender, developerWallet, taxFee);
        emit Transfer(sender, lotteryFundWallet, lotteryFundFee);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
