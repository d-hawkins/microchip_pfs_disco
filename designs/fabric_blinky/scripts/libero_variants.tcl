# -----------------------------------------------------------------------------
# libero_variants.tcl
#
# 7/25/2025 D. W. Hawkins (dwh@caltech.edu)
#
# Microchip Libero SoC GUI project creation script.
#
# Script execution;
#
# 1. Start Libero SoC
#
# 2. Select Project -> Execute Script
#
#    and select this script with no arguments.
#
# The script will create the build/ directory, create a project, add the
# source and constraints, and then run synthesis and place-and-route.
#
# The Libero GUI can then be used to open tools such as ChipPlanner
# (to review the floorplan) and SmartTime (to review timing).
#
# -----------------------------------------------------------------------------
# Notes
# -----
#
# 1. Script development
#
#    This script was developed by first manually creating a Libero project,
#    and then exporting the Tcl script to get the Libero-specific project
#    Tcl commands. The project commands were then used to create the
#    Libero Tcl utilities procedures in libero_utils.tcl. The utilities
#    procedures are used in all designs.
#
#    This script is used to create projects for multiple design variants.
#    The variants.tcl script contains the project specific implementation
#    details.
#
#    The script usage is then:
#      libero_utils.tcl    : Libero project setup utilities (common)
#      variants.tcl        : Project variants (customized per project)
#      libero_variants.tcl : Project script (minor edits per project)
#
# 2. Project directories
#
#    microchip_pfs_disco/designs/$design
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Project Directories
# -----------------------------------------------------------------------------
#
# This script is executed in Libero using "Project > Execute Script".
# This executes the script in the directory containing the script.
#
# Project directories
set scripts [file dirname [file normalize [info script]]]
set top     [file dirname $scripts]
set repo    [file dirname [file dirname $top]]
set src     $top/src
set build   $top/build/libero

# Board and design name
set board   pfs_disco
set design  [file tail $top]

puts "board   = $board"
puts "design  = $design"
puts "repo    = $repo"
puts "top     = $top"
puts "scripts = $scripts"
puts "build   = $build"

# -----------------------------------------------------------------------------
# Support Scripts
# -----------------------------------------------------------------------------
#
# Libero utilities
source $repo/tcl/libero_utils.tcl

# Libero version
set version [libero_version_number]

# Design variants
source $scripts/variants.tcl
set variants [get_variants $board $repo $design]
puts [format "There are %d variants" [dict size $variants]]

# =============================================================================
# Synthesis loop
# =============================================================================
#
# Start time for all
set t_start_all [clock clicks -milliseconds]

# Variants loop
dict for {id variant} $variants {

	puts "[string repeat = 80]"
	puts "Starting synthesis for variant = $id"
	puts "[string repeat - 80]"

	# Time each loop
	set t_start [clock clicks -milliseconds]

	# -------------------------------------------------------------------------
	# Build Directory
	# -------------------------------------------------------------------------
	#
	# This script is designed to create a project from scratch, so the build
	# directory should not exist. Rather than delete the folder, ask the user
	# to remove it (this saves accidentally deleting a useful project!).
	# Libero creates the project directory.
	#
	set build $top/build/libero_${id}
	if {[file exists $build]} {
		error "Error: the build directory already exists!"
	}
	dict set variant BUILD  $build

	# -------------------------------------------------------------------------
	# Libero Project
	# -------------------------------------------------------------------------
	#
	# Create the project
	libero_project $variant

	# Project creation callback
	# * Create and add constraints files
	set variant [libero_project_callback $variant]

	# Add the source
	libero_add_source $variant

	# Set the root module
	build_design_hierarchy
	set_root -module ${board}::work

	# Add the constraints
	# * organize_tool_files uses the set_root -module
	libero_add_constraints $variant

	# Save project
	save_project

	# -------------------------------------------------------------------------
	# Configure Synplify HDL Parameters
	# -------------------------------------------------------------------------
	#
	# None used in this design.

	# -------------------------------------------------------------------------
	# Configure Verify Timing
	# -------------------------------------------------------------------------
	#
	# Turn on verification of all corners
	configure_tool -name {VERIFYTIMING} \
		-params {CONSTRAINTS_COVERAGE:1}               \
		-params {FORMAT:XML}                           \
		-params {MAX_EXPANDED_PATHS_TIMING:1}          \
		-params {MAX_EXPANDED_PATHS_VIOLATION:0}       \
		-params {MAX_PARALLEL_PATHS_TIMING:1}          \
		-params {MAX_PARALLEL_PATHS_VIOLATION:1}       \
		-params {MAX_PATHS_INTERACTIVE_REPORT:1000}    \
		-params {MAX_PATHS_TIMING:5}                   \
		-params {MAX_PATHS_VIOLATION:20}               \
		-params {MAX_TIMING_FAST_HV_LT:1}              \
		-params {MAX_TIMING_MULTI_CORNER:1}            \
		-params {MAX_TIMING_SLOW_LV_HT:1}              \
		-params {MAX_TIMING_VIOLATIONS_FAST_HV_LT:1}   \
		-params {MAX_TIMING_VIOLATIONS_MULTI_CORNER:1} \
		-params {MAX_TIMING_VIOLATIONS_SLOW_LV_HT:1}   \
		-params {MIN_TIMING_FAST_HV_LT:1}              \
		-params {MIN_TIMING_MULTI_CORNER:1}            \
		-params {MIN_TIMING_SLOW_LV_HT:1}              \
		-params {MIN_TIMING_VIOLATIONS_FAST_HV_LT:1}   \
		-params {MIN_TIMING_VIOLATIONS_MULTI_CORNER:1} \
		-params {MIN_TIMING_VIOLATIONS_SLOW_LV_HT:1}   \
		-params {SLACK_THRESHOLD_VIOLATION:0.0}        \
		-params {SMART_INTERACTIVE:true}

	# Save project
	save_project

	# -------------------------------------------------------------------------
	# Run Synthesis and Place-and-Route
	# -------------------------------------------------------------------------
	#
	set use_tmr [dict get $variant PARAMETERS USE_TMR]

	# Use Synplify Base (no TMR) or Elite (TMR)
	set run_par 1
	if {$use_tmr == 0} {
		select_profile -name {Synplify Base}
	} else {
		if {$version >= 2025.1} {
			select_profile -name {Synplify Elite}
		} else {
			# Libero issue: Libero Elite will not launch!
			puts "Please run Synplify Elite for variant $id"
			set run_par 0
		}
	}

	if {$run_par} {

		# Run P&R
		run_tool -name {PLACEROUTE}

		# Timing report/check script
		# * Run from the build directory
		# * The Libero GUI status changes to red (X)
		# * The red (x) do not occur when this script is run directly
		# * There must be a file the GUI checks for that does not exist
		cd $build
		run_tool -name {VERIFYTIMING} \
			-script $scripts/timing_report.tcl
		cd $top

		# Timing report/check script
		# * Re-run without the script
		# * The Libero GUI status changes to green check marks
		run_tool -name {VERIFYTIMING}

	}

	# -------------------------------------------------------------------------
	# Close project
	# -------------------------------------------------------------------------
	#
	close_project -save 1

	# Elapsed time
	set t_end [clock clicks -milliseconds]
	set t_elapsed [expr {($t_end - $t_start)/60000.0}]
	set elapsed_time [format "%.3f minutes" $t_elapsed]
	puts "Elapsed time: $elapsed_time"
}

# Elapsed time
set t_end [clock clicks -milliseconds]
set t_elapsed [expr {($t_end - $t_start_all)/60000.0}]
set elapsed_time [format "%.3f minutes" $t_elapsed]
puts "Total elapsed time: $elapsed_time"

puts "---------------------------------"
puts "All done!"
puts "---------------------------------"

