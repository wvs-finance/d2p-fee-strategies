// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AMMStrategyBase} from "./AMMStrategyBase.sol";
import {IAMMStrategy, TradeInfo} from "./IAMMStrategy.sol";

contract Strategy is AMMStrategyBase {
    function afterInitialize(uint256, uint256) external override returns (uint256, uint256) {
        slots[0] = bpsToWad(30); // starting fee
        return (bpsToWad(30), bpsToWad(30));
    }

    function afterSwap(TradeInfo calldata trade) external override returns (uint256, uint256) {
        uint256 fee = slots[0];

        // Large trade relative to reserves? Widen the spread.
        uint256 tradeRatio = wdiv(trade.amountY, trade.reserveY);
        if (tradeRatio > WAD / 20) { // > 5% of reserves
            fee = clampFee(fee + bpsToWad(10));
        } else {
            // Decay back toward 30 bps
            uint256 base = bpsToWad(30);
            if (fee > base) fee = fee - bpsToWad(1);
        }

        slots[0] = fee;
        return (fee, fee);
    }

    function getName() external pure override returns (string memory) {
        return "Widen After Big Trades";
    }
}
