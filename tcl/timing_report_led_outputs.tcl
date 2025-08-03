# -----------------------------------------------------------------------------
# timing_report_led_outputs.tcl
#
# 6/15/2025 D. W. Hawkins (dwh@caltech.edu)
#
# SmartTime Timing Analysis for the blinky LED design LED outputs.
#
# This script uses the procedures defined in:
#  (a) timing_report_utils.tcl      for Libero SoC 2025.1 devices
#  (b) timing_report_utils_pa3.tcl  for Libero Soc 11.9sp6 ProASIC3 devices
#  (c) timing_report_utils_ide.tcl  for Libero IDE 9.2sp4 devices
#
# One of these scripts needs to be sourced before sourcing this script.
#
# -----------------------------------------------------------------------------
# Notes
# -----
#
# 1. Tcl functions that do not work in SmartTime (Libero 2025.1)
#
#    Several functions work in Libero, but not SmartTime, so there must be
#    missing Tcl initialization or explicit 'package require' statements.
#
#    (a) clock format did not work
#    (b) tcl::mathfunc::max and tcl::mathfunc::min did not work
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Report LED output timing
# -----------------------------------------------------------------------------
#
proc timing_report_led_outputs {filename} {

	# Clock and LED port names
	set clock_name clk
	set port_names {}
	for {set i 0} {$i < 7} {incr i} {
		lappend port_names led\[$i\]
	}

	# Read the dictionaries of timing parameters
	set led_min [get_output_delays_dict $clock_name $port_names min]
	set led_max [get_output_delays_dict $clock_name $port_names max]

	# Convert the dictionaries to tables for printing to file
	#
	# Read the properties from the first path entry
	set port_name [lindex $port_names 0]
	set path      [dict get $led_min $port_name]
	set props     [dict keys $path]

	# Determine the column widths
	#  * maximum string length for each column
	set widths {}
	foreach prop $props {
		lappend widths [string length $prop]
	}
	set N [llength $widths]
	set vals [dict values $path]
	for {set i 0} {$i < $N} {incr i} {
		set width_a [lindex $widths $i]
		set width_b [string length [lindex $vals $i]]
		if {$width_b > $width_a} {
			set widths [lreplace $widths $i $i $width_b]
		}
	}

	# Timing data format string
	set format_str {}
	foreach width $widths {
		append format_str [format "%%%ds " [expr {$width+2}]]
	}

	# Column header underline string (list of underlines)
	set under_str {}
	foreach width $widths {
		lappend under_str [string repeat - $width]
	}

	# LED delays minimum ASCII table
	set buffer {}
	append buffer "LED delays minimum\n"
	append buffer "------------------\n"
	append buffer "\n"
	append buffer [format $format_str {*}$props]
	append buffer "\n"
	append buffer [format $format_str {*}$under_str]
	append buffer "\n"
	foreach port_name $port_names {
		set path [dict get $led_min $port_name]
		set vals [dict values $path]
		append buffer [format $format_str {*}$vals]
		append buffer "\n"
	}
	append buffer "\n"

	# LED delays maximum ASCII table
	append buffer "LED delays maximum\n"
	append buffer "------------------\n"
	append buffer "\n"
	append buffer [format $format_str {*}$props]
	append buffer "\n"
	append buffer [format $format_str {*}$under_str]
	append buffer "\n"
	foreach port_name $port_names {
		set path [dict get $led_max $port_name]
		set vals [dict values $path]
		append buffer [format $format_str {*}$vals]
		append buffer "\n"
	}
	append buffer "\n"

	append buffer "LED clock-to-output delays\n"
	append buffer "--------------------------\n"
	append buffer "\n"
	append buffer [format "%-11s %10s %10s\n" "Port" "Min" "Max"]
	append buffer [format "%-11s %10s %10s\n" "-----------" "------" "------"]

	# Min and max process, clock-to-output min and max values
	set slack_positive 1
	set led_min_list {}
	set led_max_list {}
	foreach port_name $port_names {

		# Minimum process
		set path [dict get $led_min $port_name]
		set min  [dict get $path "Clock to Out (ns)"]

		set slack [dict get $path "Slack (ns)"]
		set req   [dict get $path "Required (ns)"]
		set exp   [format "%.3f" [expr {$min-$req}]]
	#	puts "$port_name: min exp = $exp, slack = $slack"
		if {![string equal $exp $slack]} {
			puts "Error: slack mismatch!"
		}
		if {$slack < 0} {
			set slack_positive 0
		}
		lappend led_min_list $min

		# Maximum process
		set path [dict get $led_max $port_name]
		set max  [dict get $path "Clock to Out (ns)"]

		set slack [dict get $path "Slack (ns)"]
		set req   [dict get $path "Required (ns)"]
		set exp   [format "%.3f" [expr {$req-$max}]]
	#	puts "$port_name: max exp = $exp, slack = $slack"
		if {![string equal $exp $slack]} {
			puts "Error: slack mismatch!"
		}
		if {$slack < 0} {
			set slack_positive 0
		}
		lappend led_max_list $max

		append buffer [format "%-11s %10s %10s\n" $port_name $min $max]
	}

	# tcl::mathfunc::min and max did not work within SmartTime,
	# but lsort -real does, so use that for min and max calculations.
	#
	# Minimum process: min and max values
	set min_tco_min [lindex [lsort -real $led_min_list] 0]
	set min_tco_max [lindex [lsort -real $led_min_list] end]
	#
	# Maximum process: min and max values
	set max_tco_min [lindex [lsort -real $led_max_list] 0]
	set max_tco_max [lindex [lsort -real $led_max_list] end]

	# Variation between bits
	set min_tco_delta [format "%.3f" [expr {$min_tco_max-$min_tco_min}]]
	set max_tco_delta [format "%.3f" [expr {$max_tco_max-$max_tco_min}]]

	append buffer "\n"
	append buffer "LED clock-to-output delays summary\n"
	append buffer "----------------------------------\n"
	append buffer "\n"
	append buffer "Data: tco_min(min, max, delta) = ($min_tco_min, $min_tco_max, $min_tco_delta)\n"
	append buffer "Data: tco_max(min, max, delta) = ($max_tco_min, $max_tco_max, $max_tco_delta)\n"

	append buffer "\n"
	if {$slack_positive} {
		set msg "PASS: There is positive timing slack."
	} else {
		set msg "FAIL: There is negative timing slack!"
	}
	append buffer "$msg\n"
	puts "timing_report.tcl: $msg"

	# Write a text file
	set fd [open $filename w+]
	puts $fd $buffer
	close $fd

	return
}


