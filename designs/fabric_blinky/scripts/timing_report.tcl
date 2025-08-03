# -----------------------------------------------------------------------------
# timing_report.tcl
#
# 6/15/2025 D. W. Hawkins (dwh@caltech.edu)
#
# Libero SoC SmartTime Timing Analysis.
#
# The script is run as follows:
#
# 1. Open a project in Libero SoC (eg., version 2024.2)
#
# 2. Select "Project > Execute Script"
#
# 3. Select this script for the "Script file" and click "Run"
#
# 4. Open "timing_report.txt" to review the report
#
# -----------------------------------------------------------------------------
# Notes
# -----
#
# 1. SmartTime Tcl scripts
#
#    SmartTime does not have an "Execute Script" option. SmartTime scripts
#    need to be started from Libero using the run_tool command.
#
#    The "Libero-to-SmartTime Re-launch" section implements the logic that
#    allows this script to detect whether it is being called from Libero
#    or SmartTime. When this script is run using Libero, the script will
#    be called again as part of a SmartTime run_tool command. When the
#    script runs for the second time, it detects that it is in SmartTime
#    and continues. When the SmartTime script ends, run_tool ends, and
#    the 'return' statement exits the script back to Libero.
#
# 2. Tcl argument passing does not work
#
#    The Libero "Execute Script" option allows arguments to be passed to
#    this script when it is run from Libero, however, there is no way to
#    pass arguments to the run_tool script!
#
#    If the script is located in the source area, then there is no obvious
#    way to determine the path to the build area, unless there is a SmartTime
#    Tcl command that can be used to provide the project path.
#
#    The work-around is to use Libero to determine the path to the build
#    directory and then change to that directory before re-launching the
#    script to run in SmartTime. The SmartTime script can then used [pwd]
#    to determine the build directory and [info script] to determine the
#    source directories.
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Libero-to-SmartTime Re-launch
# -----------------------------------------------------------------------------
#
# If the toolname is 'libero' run the script in SmartTime, eg.,
#  * C:/software/Microchip/Libero_SoC_v2024.2/Designer/bin/libero.exe
#  * C:/software/Microchip/Libero_SoC_v2024.2/Designer/bin64/st_shell.exe
set toolname [file rootname [file tail [info nameofexecutable]]]
if {[string equal $toolname "libero"]} {
	puts [string repeat ~ 80]
	puts "timing_report.tcl: started (Libero)"

	# Use Libero to determine the build path
	# * A script argument could also have been used
	set build [file dirname [defvar_get -name DESDIR -silent]]

	# Change directory to the build area
	cd $build

	# Re-launch the script
	#  * The script executed by run_tool does not define argc/argv
	run_tool -name {VERIFYTIMING} -script [info script]

	puts "timing_report.tcl: ended (Libero)"
	puts [string repeat ~ 80]
	return
} elseif {![string equal $toolname "st_shell"]} {
	error "Error: Libero or SmartTime were not detected!"
}

# -----------------------------------------------------------------------------
# Start Message
# -----------------------------------------------------------------------------
#
puts [string repeat = 80]
puts "timing_report.tcl: started (SmartTime)"

# -----------------------------------------------------------------------------
# Directories
# -----------------------------------------------------------------------------
#
# The script executed by run_tool does not define argc/argv, so the build and
# repository directories cannot be passed as arguments.
#
# Build directory
set build [pwd]

# Source directory
set top  [file dirname [file dirname [file normalize [info script]]]]
set repo [file dirname [file dirname $top]]

puts "timing_report.tcl: top = $top"
puts "timing_report.tcl: repo = $repo"
puts "timing_report.tcl: build = $build"

# Timing Analysis Utilities
source $repo/tcl/timing_report_utils.tcl

# -----------------------------------------------------------------------------
# LED output timing
# -----------------------------------------------------------------------------
#
source $repo/tcl/timing_report_led_outputs.tcl
set filename $build/timing_report.txt
timing_report_led_outputs $filename

# -----------------------------------------------------------------------------
# End Message
# -----------------------------------------------------------------------------
#
puts "timing_report.tcl: ended (SmartTime)"
puts [string repeat = 80]



