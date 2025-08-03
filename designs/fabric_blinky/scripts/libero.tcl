# -----------------------------------------------------------------------------
# libero.tcl
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

puts [string repeat = 80]
puts "libero.tcl: started"

# -----------------------------------------------------------------------------
# Toolname check
# -----------------------------------------------------------------------------
#
# The executable string under Windows was:
# C:/software/Microchip/Libero_SoC_2025.1/Designer/bin/libero.exe
set toolname [file rootname [file tail [info nameofexecutable]]]
if {![string equal $toolname "libero"]} {
	error "libero.tcl: Error: unexpected tool name '$toolname'!"
}

# -----------------------------------------------------------------------------
# Project Directories
# -----------------------------------------------------------------------------
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
# Build Directory
# -----------------------------------------------------------------------------
#
# This script is designed to create a project from scratch, so the build
# directory should not exist. Rather than delete the folder, ask the user
# to remove it (this saves accidentally deleting a useful project!).
# Libero creates the project directory.
#
if {[file exists $build]} {
	error "libero.tcl: Error: the build directory already exists!"
}

# -----------------------------------------------------------------------------
# Libero Project
# -----------------------------------------------------------------------------
#
# The following commands were determined by manually creating a project, and
# then using 'Project -> Export Script' to create a script with Tcl commands.
# The commands were then edited to use the variables within this script.
#
# Polarfire SoC Discovery Kit
new_project \
	-location $build                                \
	-name $board                                    \
	-project_description {}                         \
	-block_mode 0                                   \
	-standalone_peripheral_initialization 0         \
	-instantiate_in_smartdesign 1                   \
	-ondemand_build_dh 1                            \
	-use_relative_path 0                            \
	-linked_files_root_dir_env {}                   \
	-hdl {VERILOG}                                  \
	-family {PolarFireSoC}                          \
	-die {MPFS095T}                                 \
	-package {FCSG325}                              \
	-speed {-1}                                     \
	-die_voltage {1.0}                              \
	-part_range {EXT}                               \
	-adv_options {IO_DEFT_STD:LVCMOS 1.8V}          \
	-adv_options {RESTRICTPROBEPINS:1}              \
	-adv_options {RESTRICTSPIPINS:0}                \
	-adv_options {SYSTEM_CONTROLLER_SUSPEND_MODE:0} \
	-adv_options {TEMPR:EXT}                        \
	-adv_options {VCCI_1.2_VOLTR:EXT}               \
	-adv_options {VCCI_1.5_VOLTR:EXT}               \
	-adv_options {VCCI_1.8_VOLTR:EXT}               \
	-adv_options {VCCI_2.5_VOLTR:EXT}               \
	-adv_options {VCCI_3.3_VOLTR:EXT}               \
	-adv_options {VOLTR:EXT}

# Source
create_links \
	-convert_EDN_to_HDL 0                                         \
	-hdl_source $src/pfs_disco.sv                                 \
	-hdl_source $repo/ip/pfs_init_monitor/src/pfs_init_monitor.sv \
	-hdl_source $repo/ip/cdc_sync_bit/src/cdc_sync_bit.sv         \
	-hdl_source $repo/ip/blinky/src/blinky.sv

# Constraints
create_links                          \
	-convert_EDN_to_HDL 0             \
	-io_pdc $scripts/pfs_disco_io.pdc \
	-fp_pdc $scripts/pfs_disco_fp.pdc \
	-sdc    $scripts/pfs_disco.sdc    \
	-ndc    $scripts/pfs_disco.ndc

# Set the design root
build_design_hierarchy
set_root -module ${board}::work

# Enable NDC for synthesis
organize_tool_files -tool {SYNTHESIZE} \
	-file $scripts/pfs_disco.ndc       \
	-module ${board}::work             \
	-input_type {constraint}

# Enable PDC and SDC for place-and-route
organize_tool_files -tool {PLACEROUTE} \
	-file $scripts/pfs_disco_io.pdc    \
	-file $scripts/pfs_disco_fp.pdc    \
	-file $scripts/pfs_disco.sdc       \
	-module ${board}::work             \
	-input_type {constraint}

# Enable SDC for timing verification
organize_tool_files -tool {VERIFYTIMING} \
	-file $scripts/pfs_disco.sdc         \
	-module ${board}::work               \
	-input_type {constraint}

# -----------------------------------------------------------------------------
# Configure Verify Timing
# -----------------------------------------------------------------------------
#
# Turn on all process corners
configure_tool -name {VERIFYTIMING}                \
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
	-params {MAX_TIMING_SLOW_LV_LT:1}              \
	-params {MAX_TIMING_VIOLATIONS_FAST_HV_LT:1}   \
	-params {MAX_TIMING_VIOLATIONS_MULTI_CORNER:1} \
	-params {MAX_TIMING_VIOLATIONS_SLOW_LV_HT:1}   \
	-params {MAX_TIMING_VIOLATIONS_SLOW_LV_LT:1}   \
	-params {MIN_TIMING_FAST_HV_LT:1}              \
	-params {MIN_TIMING_MULTI_CORNER:1}            \
	-params {MIN_TIMING_SLOW_LV_HT:1}              \
	-params {MIN_TIMING_SLOW_LV_LT:1}              \
	-params {MIN_TIMING_VIOLATIONS_FAST_HV_LT:1}   \
	-params {MIN_TIMING_VIOLATIONS_MULTI_CORNER:1} \
	-params {MIN_TIMING_VIOLATIONS_SLOW_LV_HT:1}   \
	-params {MIN_TIMING_VIOLATIONS_SLOW_LV_LT:1}   \
	-params {SLACK_THRESHOLD_VIOLATION:0.0}        \
	-params {SMART_INTERACTIVE:1}

# -----------------------------------------------------------------------------
# Run Synthesis and Place-and-Route
# -----------------------------------------------------------------------------
#
# Comment the following lines to have the script only setup the project.
# The user can then click on the green arrow to synthesize the project.
# This allows the script to complete quickly for projects where user
# interaction with the Libero GUI is expected.
#
# Run "Place and Route"
#run_tool -name {PLACEROUTE}

# Run "Verify Timing"
run_tool -name {VERIFYTIMING}

# Run "Generate Bitstream"
#run_tool -name {GENERATEPROGRAMMINGFILE}

# Run "Run PROGRAM Action"
# run_tool -name {PROGRAMDEVICE}

puts "libero.tcl: ended"
puts [string repeat = 80]

