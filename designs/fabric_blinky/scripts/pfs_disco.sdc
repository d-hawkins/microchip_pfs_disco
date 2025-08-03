# -----------------------------------------------------------------------------
# pfs_disco.sdc
#
# 7/25/2025 D. W. Hawkins (dwh@caltech.edu)
#
# Microchip PolarFire SoC Discovery Kit Synopsys Design Constraints (SDC).
#
# -----------------------------------------------------------------------------
# Clock-to-output Delays
# ----------------------
#
#   Output      Drive     Clock-to-Output (ns)     Constraint (ns)
#  Registers     (mA)        Min       Max          Min       Max
#  ---------    -----      -------   -------      -------   -------
#  Fabric (a)     4         3.766     6.651         3.7       6.7
#  Fabric (b)     4         3.769     6.605         3.7       6.7
#  I/O            4         3.587     6.010         3.5       6.1
#
#  Fabric (a)     8         3.569     6.447         3.5       6.5
#  Fabric (b)     8         3.571     6.397         3.5       6.4
#  I/O            8         3.373     5.802         3.3       5.9
#
# (a) Fabric registers without floorplanning (delays may change slightly)
# (b) Fabric registers with floorplanning next to output pad
#
# Output register types:
#  * Fabric is SLE
#  * I/O register is IOREG
#
# Changing the output registers and drive strengths requires editing the
# constraints files.
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Parameters
# -----------------------------------------------------------------------------
#
# Clock period
set clk_period 20.0

# LED output registers
# * Enabling the I/O registers requires the use of the .NDC file
set led_output_reg 1

# LED output delays (see the notes above)
if {$led_output_reg == 0} {
	# Fabric Registers
	set led_output_max  6.7
	set led_output_min  3.7
} else {
	# I/O Registers
	set led_output_max  6.1
	set led_output_min  3.5
}

# UART input-to-output delays
# * For 4mA drive use (min, max) = (2.5, 4.9)
# * For 8mA drive use (min, max) = (2.3, 4.7)
set uart_delay_max  4.9
set uart_delay_min  2.5

# -----------------------------------------------------------------------------
# Asynchronous Reset
# -----------------------------------------------------------------------------
#
set_false_path -from [get_ports {arst_n}]

# Metastability register-to-register paths (for PIPELINE = 4)
#
# The delays were obtained after the registers were floorplanned.
#
#  Delay          Min       Max
#  ----------   -------   -------
#  Actual        0.075     0.461
#  Constraint    0.070     0.470
#  Slack         0.005     0.009
#
# The Max Actual is given as the "Minimum Period" in the max delay table.
# The Min Actual was determined from the sum of Constraint plus Slack.
#
# PDC constraints are required to get minimum register-to-register routes.
# The SDC constraints alone are not sufficient.
#
set_max_delay 0.47 \
	-from [get_pins {u3/d_meta*}] \
	-to   [get_pins {u3/d_meta*}]
set_min_delay 0.07 \
	-from [get_pins {u3/d_meta*}] \
	-to   [get_pins {u3/d_meta*}]

# -----------------------------------------------------------------------------
# Global Clock
# -----------------------------------------------------------------------------
#
# 50MHz
create_clock -name clk -period $clk_period [get_ports {clk_50mhz}]
set_clock_groups -asynchronous -group [get_clocks {clk}]

# -----------------------------------------------------------------------------
# Input-to-Output Constraints
# -----------------------------------------------------------------------------
#
# Maximum delay
set_max_delay $uart_delay_max \
	-from [get_ports {uart_rx}] -to  [get_ports {uart_tx}]

# Minimum delay
set_min_delay $uart_delay_min \
	-from [get_ports {uart_rx}] -to  [get_ports {uart_tx}]

# -----------------------------------------------------------------------------
# Output Constraints
# -----------------------------------------------------------------------------
#
# The SmartTime clock-to-output delays were adjusted until the reported
# margin was under 0.1ns.

# Output delay constraints
set max [expr {$clk_period - $led_output_max}]
set min -$led_output_min

# Output setup analysis delay
set_output_delay -max $max -clock [get_clocks {clk}] [get_ports {led[*]}]

# Output hold analysis delay
set_output_delay -min $min -clock [get_clocks {clk}] [get_ports {led[*]}]
