# -----------------------------------------------------------------------------
# variants.tcl
#
# 7/30/2025 D. W. Hawkins (dwh@caltech.edu)
#
# PolarFire SoC Discovery Kit design variants.
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Create constraint file
# -----------------------------------------------------------------------------
#
# Create a SDC/PDC constraint file using the parameters and template.
#
# The params argument is a dictionary of parameters used to search-and-replace
# strings in the template file.
#
proc create_constraint_file {params template filename} {

	# Read the template
	set fd [open $template r]
	set buffer [read $fd]
	close $fd

	# Add the file DATE to the dictionary
	set date [clock format [clock seconds] -format "%m/%d/%Y"]
	dict set params DATE $date

	# Search and replace parameters
	#  * Replace each of the template strings "<${key}>" with $value
	dict for {key value} $params {
		set buffer [string map [list "<${key}>" $value] $buffer]
	}

	# Write the file
	set fd [open $filename w]
	puts $fd $buffer
	close $fd

	return
}

# -----------------------------------------------------------------------------
# Project Creation Callback
# -----------------------------------------------------------------------------
#
# This callback is used to write generated constraints files into the Libero
# project constraints directories. The Libero project directories must exist,
# so this callback is called after Libero project creation.
#
# File naming convention:
#
# Filename   Constraint Type   Used by
# --------   ---------------   -------
#  *.ndc     I/O Registers     Synplify (SYNTHESIZE)
#  *.fdc     TMR               Synplify (SYNTHESIZE)
#  *_io.pdc  I/O Pins          Libero   (PLACEROUTE)
#  *_fp.pdc  Floorplan         Libero   (PLACEROUTE)
#  *.sdc     Timing            Libero   (PLACEROUTE, VERIFYTIMING)
#
# The PDC files use a naming convention to implement -io_pdc and -fp_pdc.
#
# Synplify does not need an SDC file as its default settings are acceptable.
#
proc libero_project_callback {variant} {

	# Design parameters
	set board      [dict get $variant BOARD]
	set repo       [dict get $variant REPO]
	set design     [dict get $variant DESIGN]
	set build      [dict get $variant BUILD]
	set params     [dict get $variant PARAMETERS]

	# Template location
	set scripts $repo/designs/$design/scripts

	# Generate the SDC file
	set sdc_template $scripts/${board}_sdc.txt
	if {[file exists $sdc_template]} {
		set sdc_filename $build/constraint/$board.sdc
		create_constraint_file $params $sdc_template $sdc_filename
		puts "variant.tcl: Update constraints list with $sdc_filename"
		dict lappend variant CONSTRAINTS $sdc_filename
	}

	# Generate the I/O PDC file
	set io_pdc_template $scripts/${board}_io_pdc.txt
	if {[file exists $io_pdc_template]} {
		set io_pdc_filename $build/constraint/io/${board}_io.pdc
		create_constraint_file $params $io_pdc_template $io_pdc_filename
		puts "variant.tcl: Update constraints list with $io_pdc_filename"
		dict lappend variant CONSTRAINTS $io_pdc_filename
	}

	# Generate the floorplan PDC file
	set fp_pdc_template $scripts/${board}_fp_pdc.txt
	if {[file exists $fp_pdc_template]} {
		set fp_pdc_filename $build/constraint/fp/${board}_fp.pdc
		create_constraint_file $params $fp_pdc_template $fp_pdc_filename
		puts "variant.tcl: Update constraints list with $fp_pdc_filename"
		dict lappend variant CONSTRAINTS $fp_pdc_filename
	}

	# Generate the NDC file
	set ndc_template $scripts/${board}_ndc.txt
	if {[file exists $ndc_template]} {
		set ndc_filename $build/constraint/${board}.ndc
		create_constraint_file $params $ndc_template $ndc_filename
		puts "variant.tcl: Update constraints list with $ndc_filename"
		dict lappend variant CONSTRAINTS $ndc_filename
	}

	# Return the updated dictionary
	return $variant
}

# -----------------------------------------------------------------------------
# Variant Dictionary
# -----------------------------------------------------------------------------
#
# The project creation callback (see above) sets up the constraints files.
#
proc get_variants {board repo design} {

	# Directories
	set ip      $repo/ip
	set src     $repo/designs/$design/src
	set scripts $repo/designs/$design/scripts

	# Source
	# * The variants all use the same source
	set sources [list                                \
		$src/pfs_disco.sv                            \
		$ip/pfs_init_monitor/src/pfs_init_monitor.sv \
		$ip/cdc_sync_bit/src/cdc_sync_bit.sv         \
		$ip/blinky/src/blinky.sv                     \
	]

	# Constraints
	# * The variants use different constraints sets
	# * See the CONSTRAINTS entries below

	# Design variants
	#
	# LED outputs in fabric registers
	# * No floorplanning
	dict set variants 1 [list \
		BOARD       $board         \
		REPO        $repo          \
		DESIGN      $design        \
		SOURCES     $sources       \
		PARAMETERS  [list          \
			CLK_PERIOD       20.0  \
			LED_OUTPUT_REG   0     \
			LED_OUTPUT_DRIVE 4     \
			LED_OUTPUT_LOAD  5     \
			LED_OUTPUT_MIN   3.7   \
			LED_OUTPUT_MAX   6.7   \
			UART_DELAY_MIN   2.5   \
			UART_DELAY_MAX   4.9   \
			USE_REGIONS      0     \
			USE_TMR          0     \
		]                          \
	]

	# LED outputs in I/O registers
	# * No floorplanning
	dict set variants 2 [list \
		BOARD       $board         \
		REPO        $repo          \
		DESIGN      $design        \
		SOURCES     $sources       \
		CONSTRAINTS [list          \
			$scripts/pfs_disco.ndc \
		]                          \
		PARAMETERS  [list          \
			CLK_PERIOD       20.0  \
			LED_OUTPUT_REG   1     \
			LED_OUTPUT_DRIVE 4     \
			LED_OUTPUT_LOAD  5     \
			LED_OUTPUT_MIN   3.5   \
			LED_OUTPUT_MAX   6.1   \
			UART_DELAY_MIN   2.5   \
			UART_DELAY_MAX   4.9   \
			USE_REGIONS      0     \
			USE_TMR          0     \
		]                          \
	]

	# LED outputs in fabric registers
	# * With floorplanning
	dict set variants 3 [list \
		BOARD       $board         \
		REPO        $repo          \
		DESIGN      $design        \
		SOURCES     $sources       \
		PARAMETERS  [list          \
			CLK_PERIOD       20.0  \
			LED_OUTPUT_REG   0     \
			LED_OUTPUT_DRIVE 4     \
			LED_OUTPUT_LOAD  5     \
			LED_OUTPUT_MIN   3.7   \
			LED_OUTPUT_MAX   6.7   \
			UART_DELAY_MIN   2.5   \
			UART_DELAY_MAX   4.9   \
			USE_REGIONS      1     \
			USE_TMR          0     \
		]                          \
	]

	# LED outputs in I/O registers
	# * With floorplanning
	dict set variants 4 [list \
		BOARD       $board         \
		REPO        $repo          \
		DESIGN      $design        \
		SOURCES     $sources       \
		CONSTRAINTS [list          \
			$scripts/pfs_disco.ndc \
		]                          \
		PARAMETERS  [list          \
			CLK_PERIOD       20.0  \
			LED_OUTPUT_REG   1     \
			LED_OUTPUT_DRIVE 4     \
			LED_OUTPUT_LOAD  5     \
			LED_OUTPUT_MIN   3.5   \
			LED_OUTPUT_MAX   6.1   \
			UART_DELAY_MIN   2.5   \
			UART_DELAY_MAX   4.9   \
			USE_REGIONS      1     \
			USE_TMR          0     \
		]                          \
	]

	# LED outputs in fabric registers
	# * With floorplanning
	# * With TMR
	dict set variants 5 [list \
		BOARD       $board         \
		REPO        $repo          \
		DESIGN      $design        \
		SOURCES     $sources       \
		CONSTRAINTS [list          \
			$scripts/pfs_disco.fdc \
		]                          \
		PARAMETERS  [list          \
			CLK_PERIOD       20.0  \
			LED_OUTPUT_REG   0     \
			LED_OUTPUT_DRIVE 4     \
			LED_OUTPUT_LOAD  5     \
			LED_OUTPUT_MIN   3.7   \
			LED_OUTPUT_MAX   6.7   \
			UART_DELAY_MIN   2.5   \
			UART_DELAY_MAX   4.9   \
			USE_REGIONS      1     \
			USE_TMR          1     \
		]                          \
	]

	# LED outputs in I/O registers
	# * With floorplanning
	# * With TMR
	dict set variants 6 [list \
		BOARD       $board         \
		REPO        $repo          \
		DESIGN      $design        \
		SOURCES     $sources       \
		CONSTRAINTS [list          \
			$scripts/pfs_disco.ndc \
			$scripts/pfs_disco.fdc \
		]                          \
		PARAMETERS  [list          \
			CLK_PERIOD       20.0  \
			LED_OUTPUT_REG   1     \
			LED_OUTPUT_DRIVE 4     \
			LED_OUTPUT_LOAD  5     \
			LED_OUTPUT_MIN   3.5   \
			LED_OUTPUT_MAX   6.1   \
			UART_DELAY_MIN   2.5   \
			UART_DELAY_MAX   4.9   \
			USE_REGIONS      1     \
			USE_TMR          1     \
		]                          \
	]

	# LED outputs in fabric registers
	# * With floorplanning
	# * Without TMR
	# * LED drive = 8mA
	dict set variants 7 [list \
		BOARD       $board         \
		REPO        $repo          \
		DESIGN      $design        \
		SOURCES     $sources       \
		PARAMETERS  [list          \
			CLK_PERIOD       20.0  \
			LED_OUTPUT_REG   0     \
			LED_OUTPUT_DRIVE 8     \
			LED_OUTPUT_LOAD  5     \
			LED_OUTPUT_MIN   3.5   \
			LED_OUTPUT_MAX   6.4   \
			UART_DELAY_MIN   2.5   \
			UART_DELAY_MAX   4.9   \
			USE_REGIONS      1     \
			USE_TMR          0     \
		]                          \
	]

	# LED outputs in I/O registers
	# * With floorplanning
	# * Without TMR
	# * LED drive = 8mA
	dict set variants 8 [list \
		BOARD       $board         \
		REPO        $repo          \
		DESIGN      $design        \
		SOURCES     $sources       \
		CONSTRAINTS [list          \
			$scripts/pfs_disco.ndc \
		]                          \
		PARAMETERS  [list          \
			CLK_PERIOD       20.0  \
			LED_OUTPUT_REG   1     \
			LED_OUTPUT_DRIVE 8     \
			LED_OUTPUT_LOAD  5     \
			LED_OUTPUT_MIN   3.3   \
			LED_OUTPUT_MAX   5.9   \
			UART_DELAY_MIN   2.5   \
			UART_DELAY_MAX   4.9   \
			USE_REGIONS      1     \
			USE_TMR          0     \
		]                          \
	]

	# LED outputs in fabric registers
	# * With floorplanning
	# * Without TMR
	# * LED drive = 12mA
	dict set variants 9 [list \
		BOARD       $board         \
		REPO        $repo          \
		DESIGN      $design        \
		SOURCES     $sources       \
		PARAMETERS  [list          \
			CLK_PERIOD       20.0  \
			LED_OUTPUT_REG   0     \
			LED_OUTPUT_DRIVE 12    \
			LED_OUTPUT_LOAD  5     \
			LED_OUTPUT_MIN   3.4   \
			LED_OUTPUT_MAX   6.3   \
			UART_DELAY_MIN   2.5   \
			UART_DELAY_MAX   4.9   \
			USE_REGIONS      1     \
			USE_TMR          0     \
		]                          \
	]

	# LED outputs in I/O registers
	# * With floorplanning
	# * Without TMR
	# * LED drive = 12mA
	dict set variants 10 [list \
		BOARD       $board         \
		REPO        $repo          \
		DESIGN      $design        \
		SOURCES     $sources       \
		CONSTRAINTS [list          \
			$scripts/pfs_disco.ndc \
		]                          \
		PARAMETERS  [list          \
			CLK_PERIOD       20.0  \
			LED_OUTPUT_REG   1     \
			LED_OUTPUT_DRIVE 12    \
			LED_OUTPUT_LOAD  5     \
			LED_OUTPUT_MIN   3.2   \
			LED_OUTPUT_MAX   5.7   \
			UART_DELAY_MIN   2.5   \
			UART_DELAY_MAX   4.9   \
			USE_REGIONS      1     \
			USE_TMR          0     \
		]                          \
	]

	# LED outputs in fabric registers
	# * With floorplanning
	# * Without TMR
	# * LED drive = 4mA
	# * LED load = 10pF
	dict set variants 11 [list \
		BOARD       $board         \
		REPO        $repo          \
		DESIGN      $design        \
		SOURCES     $sources       \
		PARAMETERS  [list          \
			CLK_PERIOD       20.0  \
			LED_OUTPUT_REG   0     \
			LED_OUTPUT_DRIVE 4     \
			LED_OUTPUT_LOAD  10    \
			LED_OUTPUT_MIN   4.1   \
			LED_OUTPUT_MAX   7.0   \
			UART_DELAY_MIN   2.5   \
			UART_DELAY_MAX   4.9   \
			USE_REGIONS      1     \
			USE_TMR          0     \
		]                          \
	]

	# LED outputs in I/O registers
	# * With floorplanning
	# * Without TMR
	# * LED drive = 4mA
	# * LED load = 10pF
	dict set variants 12 [list \
		BOARD       $board         \
		REPO        $repo          \
		DESIGN      $design        \
		SOURCES     $sources       \
		CONSTRAINTS [list          \
			$scripts/pfs_disco.ndc \
		]                          \
		PARAMETERS  [list          \
			CLK_PERIOD       20.0  \
			LED_OUTPUT_REG   1     \
			LED_OUTPUT_DRIVE 4     \
			LED_OUTPUT_LOAD  10    \
			LED_OUTPUT_MIN   3.9   \
			LED_OUTPUT_MAX   6.4   \
			UART_DELAY_MIN   2.5   \
			UART_DELAY_MAX   4.9   \
			USE_REGIONS      1     \
			USE_TMR          0     \
		]                          \
	]

	# LED outputs in fabric registers
	# * With floorplanning
	# * Without TMR
	# * LED drive = 4mA
	# * LED load = 20pF
	dict set variants 13 [list \
		BOARD       $board         \
		REPO        $repo          \
		DESIGN      $design        \
		SOURCES     $sources       \
		PARAMETERS  [list          \
			CLK_PERIOD       20.0  \
			LED_OUTPUT_REG   0     \
			LED_OUTPUT_DRIVE 4     \
			LED_OUTPUT_LOAD  20    \
			LED_OUTPUT_MIN   4.8   \
			LED_OUTPUT_MAX   7.8   \
			UART_DELAY_MIN   2.5   \
			UART_DELAY_MAX   4.9   \
			USE_REGIONS      1     \
			USE_TMR          0     \
		]                          \
	]

	# LED outputs in I/O registers
	# * With floorplanning
	# * Without TMR
	# * LED drive = 4mA
	# * LED load = 20pF
	dict set variants 14 [list \
		BOARD       $board         \
		REPO        $repo          \
		DESIGN      $design        \
		SOURCES     $sources       \
		CONSTRAINTS [list          \
			$scripts/pfs_disco.ndc \
		]                          \
		PARAMETERS  [list          \
			CLK_PERIOD       20.0  \
			LED_OUTPUT_REG   1     \
			LED_OUTPUT_DRIVE 4     \
			LED_OUTPUT_LOAD  20    \
			LED_OUTPUT_MIN   4.6   \
			LED_OUTPUT_MAX   7.2   \
			UART_DELAY_MIN   2.5   \
			UART_DELAY_MAX   4.9   \
			USE_REGIONS      1     \
			USE_TMR          0     \
		]                          \
	]

	return $variants
}
