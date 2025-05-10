// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract Swap {
    address uniswapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address weth = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address usdc = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;

    function swap(uint256 amountIn) external {
    
        IERC20(weth).transferFrom(msg.sender, address(this), amountIn); // deposit ke contract (user -> contract)

        IERC20(weth).approve(uniswapRouter, amountIn); // approve ke uniswap (contract -> uniswap)

        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: weth, // token yang mau di swap
                tokenOut: usdc, // token yang mau diterima
                fee: 3000, // fee 0.3%
                recipient: msg.sender, // penerima token
                deadline: block.timestamp, // deadline swap
                amountIn: amountIn, // jumlah token yang mau di swap
                amountOutMinimum: 0, // jumlah minimum token yang mau diterima
                sqrtPriceLimitX96: 0 // tidak perlu diisi
        });

        ISwapRouter(uniswapRouter).exactInputSingle(params); // swap
    }
}
