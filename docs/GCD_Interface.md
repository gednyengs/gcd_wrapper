# GCD Wrapper

## GCD Module Interface

| Name | Width (bits) |
|------|--------------|
| clk | 1 |
| clk_en | 1 |
| rst_n | 1 |
| constant_time | 1 |
| start | 1 |
| op_code | 3 |
| A | 1279 |
| B | 1279 |
| done | 1 |
| cycle_count | 12 |
| bezout_a | 1284 |
| bezout_b | 1284 |

## Wrapper Interface

| Name | Width (bits) |
|------|--------------|
| CLK | 1 |
| CLKEN | 1 |
| RESETn | 1 |
| S_APB | 32 |
| S_AXI | 64 |
| IRQ | 1 |

### Notes
 - `S_APB`  : register file access interface
 - `S_AXI`  : data interface
 - `IRQ`    : level-sensitive interrupt
