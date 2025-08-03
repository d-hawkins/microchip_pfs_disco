# -----------------------------------------------------------------------------
# timing_report_utils_common.tcl
#
# 6/15/2025 D. W. Hawkins (dwh@caltech.edu)
#
# Libero SoC SmartTime Timing Analysis utilities.
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# write_timing_table_to_csv
# -----------------------------------------------------------------------------
#
proc write_timing_table_to_csv {table filename} {
	set fd [open $filename w+]
	set header 0
	dict for {bit row} $table {
		if {$header == 0} {
			set keys [dict keys $row]
			puts $fd [join $keys ", "]
			incr header
		}
		set values [dict values $row]
		puts $fd [join $values ", "]
	}
	close $fd
	return
}

# -----------------------------------------------------------------------------
# write_timing_reports_input_setup
# -----------------------------------------------------------------------------
#
proc write_timing_reports_input_setup {clock_name port_names csvbase} {

	# List one path
	st_set_options -limit_max_paths 1

	foreach opcond [list best typ worst] {

		# Set the operating condition
		st_set_options -max_opcond $opcond

		# Get the timing parameters table
		set table [get_input_setup_delays_dict $clock_name $port_names]

		# Write the table to CSV
		set filename ${csvbase}_${opcond}.csv
		write_timing_table_to_csv $table $filename
	}
	return
}

# -----------------------------------------------------------------------------
# write_timing_reports_input_hold
# -----------------------------------------------------------------------------
#
proc write_timing_reports_input_hold {clock_name port_names csvbase} {

	# List one path
	st_set_options -limit_max_paths 1

	foreach opcond [list best typ worst] {

		# Set the operating condition
		st_set_options -min_opcond $opcond

		# Get the timing parameters table
		set table [get_input_hold_delays_dict $clock_name $port_names]

		# Write the table to CSV
		set filename ${csvbase}_${opcond}.csv
		write_timing_table_to_csv $table $filename
	}
	return
}

# -----------------------------------------------------------------------------
# write_timing_reports_clock_to_out
# -----------------------------------------------------------------------------
#
proc write_timing_reports_clock_to_out {clock_name port_names csvbase} {

	# List one path
	st_set_options -limit_max_paths 1

	foreach type [list min max] {
		foreach opcond [list best typ worst] {

			# Set the operating condition
			if {[string equal $type max]} {
				st_set_options -max_opcond $opcond
			} else {
				st_set_options -min_opcond $opcond
			}

			# Get the timing parameters table
			set table [get_output_delays_dict $clock_name $port_names $type]

			# Write the table to CSV
			set filename ${csvbase}_${type}_${opcond}.csv
			write_timing_table_to_csv $table $filename
		}
	}
	return
}
