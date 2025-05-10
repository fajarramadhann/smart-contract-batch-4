// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

interface IAave {
    function supply(address asset, uint256 amount, address onBehalfOf, uint16 refferalCode) external;
    function borrow(address asset, uint256 amount, uint256 interestRateMode, uint16 refferalCode, address onBehalfOf) external;
}

interface IFlashloan {
    function flashLoan(address recipient, address[] memory tokens, uint256[] memory amounts, bytes calldata userData) external;
}

contract Flashloan {
    address uniswapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address weth = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address usdc = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address aave = 0x794a61358D6845594F94dc1DB02A252b5b4814aD;
    address balancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

    function loopingSupply(uint256 supplyAmount, uint256 borrowAmount) external {
        IERC20(weth).transferFrom(msg.sender, address(this), supplyAmount);

        address[] memory tokens = new address[](1);
        tokens[0] = usdc;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = borrowAmount;

        IFlashloan(balancerVault).flashLoan(address(this), tokens, amounts, abi.encode(supplyAmount, borrowAmount));
    }

    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory data
        ) external {
            
        (uint256 supplyAmount, uint256 borrowAmount) = abi.decode(data, (uint256, uint256));

        IERC20(usdc).approve(uniswapRouter, borrowAmount);
        // IERC20(weth).approve(uniswapRouter, borrowAmount);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: usdc, // token yang mau di swap
            tokenOut: weth, // token yang mau diterima
            fee: 3000, // fee 0.3%
            recipient: address(this), // penerima token
            deadline: block.timestamp, // deadline swap
            amountIn: borrowAmount, // jumlah token yang mau di swap
            amountOutMinimum: 0, // jumlah minimum token yang mau diterima
            sqrtPriceLimitX96: 0 // tidak perlu diisi
        });

        uint256 outputWeth = ISwapRouter(uniswapRouter).exactInputSingle(params);

        uint256 totalEth = supplyAmount + outputWeth;

        IERC20(weth).approve(aave, totalEth);
        IAave(aave).supply(weth, totalEth, address(this), 0);

        IAave(aave).borrow(usdc, borrowAmount, 2, 0, address(this));

        IERC20(usdc).approve(balancerVault, borrowAmount);
        IERC20(usdc).transfer(balancerVault, borrowAmount);
        }

}
