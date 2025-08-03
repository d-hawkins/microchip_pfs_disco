# -----------------------------------------------------------------------------
# timing_report_utils.tcl
#
# 6/15/2025 D. W. Hawkins (dwh@caltech.edu)
#
# Libero SoC SmartTime Timing Analysis utilities.
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Input Setup Delays
# -----------------------------------------------------------------------------
#
# Setup requires 'list_paths -type external_setup -analysis max'. If the
# analysis is changed to min, then the delay path contains hold properties.
#
proc get_input_setup_delays_dict {clock_name port_names} {

	# Delay properties
	set props [list            \
		"From"                 \
		"To"                   \
		"Delay (ns)"           \
		"Slack (ns)"           \
		"Arrival (ns)"         \
		"Required (ns)"        \
		"Setup (ns)"           \
		"External Setup (ns)"  \
	]

	# Header (the first column entry is empty)
	set header ",[join $props ,]"

	# Dictionary of port delay properties
	set table [dict create]
	foreach port_name $port_names {

		# Timing path (in CSV format)
		set buffer [list_paths -format csv -analysis max \
			-clock $clock_name -type external_setup -from $port_name]

		# Convert the buffer to lines
		set lines [split $buffer "\n"]

		# Check the header
		set line [lindex $lines 0]
		if {![string equal $line $header]} {
			error "Error: Header mismatch!"
		}

		# Path elements
		set line [lindex $lines 1]
		set values [split $line ,]

		# Convert to dictionary
		set row [dict create]
		set i 1
		foreach prop $props {
			set val [lindex $values $i]
			dict set row $prop $val
			incr i
		}

		# Add to the table
		dict set table $port_name $row
	}
	return $table
}

# -----------------------------------------------------------------------------
# Input Hold Delays
# -----------------------------------------------------------------------------
#
# Hold requires 'list_paths -type external_hold -analysis min'. If the
# analysis is changed to max, then the delay path contains setup properties.
#
proc get_input_hold_delays_dict {clock_name port_names} {

	# Delay properties
	set props [list            \
		"From"                 \
		"To"                   \
		"Delay (ns)"           \
		"Slack (ns)"           \
		"Arrival (ns)"         \
		"Required (ns)"        \
		"Hold (ns)"            \
		"External Hold (ns)"   \
	]

	# Header (the first column entry is empty)
	set header ",[join $props ,]"

	# Dictionary of port delay properties
	set table [dict create]
	foreach port_name $port_names {

		# Timing path (in CSV format)
		set buffer [list_paths -format csv -analysis min \
			-clock $clock_name -type external_hold -from $port_name]

		# Convert the buffer to lines
		set lines [split $buffer "\n"]

		# Check the header
		set line [lindex $lines 0]
		if {![string equal $line $header]} {
			error "Error: Header mismatch!"
		}

		# Path elements
		set line [lindex $lines 1]
		set values [split $line ,]

		# Convert to dictionary
		set row [dict create]
		set i 1
		foreach prop $props {
			set val [lindex $values $i]
			dict set row $prop $val
			incr i
		}

		# Add to the table
		dict set table $port_name $row
	}
	return $table
}

# -----------------------------------------------------------------------------
# Input Delays
# -----------------------------------------------------------------------------
#
# Inputs
# ------
#  * clock_name    = an SDC clock name
#  * port_names    = a list of port names
#  * analysis_type = max or min
#
proc get_input_delays_dict {clock_name port_names analysis_type} {
	if {[string equal $analysis_type max]} {
		return [get_input_setup_delays_dict $clock_name $port_names]
	} elseif {[string equal $analysis_type min]} {
		return [get_input_hold_delays_dict $clock_name $port_names]
	} else {
		error "Error: Invalid analysis type!"
	}
}

# -----------------------------------------------------------------------------
# Output Delays
# -----------------------------------------------------------------------------
#
# Inputs
# ------
#  * clock_name    = an SDC clock name
#  * port_names    = a list of port names
#  * analysis_type = max or min
#
proc get_output_delays_dict {clock_name port_names analysis_type} {

	# Path properties
	set props [list            \
		"From"                 \
		"To"                   \
		"Delay (ns)"           \
		"Slack (ns)"           \
		"Arrival (ns)"         \
		"Required (ns)"        \
		"Clock to Out (ns)"    \
	]

	# Header (the first column entry is empty)
	set header ",[join $props ,]"

	# Dictionary of port delay properties
	set table [dict create]
	foreach port_name $port_names {

		# Timing path (in CSV format)
		set buffer [list_paths -format csv -analysis $analysis_type \
			-clock $clock_name -type clock_to_out -to $port_name]

		# Convert the buffer to lines
		set lines [split $buffer "\n"]

		# Check the header
		set line [lindex $lines 0]
		if {![string equal $line $header]} {
			error "Error: Header mismatch!"
		}

		# Path elements
		set line [lindex $lines 1]
		set values [split $line ,]

		# Convert to dictionary
		set row [dict create]
		set i 1
		foreach prop $props {
			set val [lindex $values $i]
			dict set row $prop $val
			incr i
		}

		# Add to the table
		dict set table $port_name $row
	}
	return $table
}
