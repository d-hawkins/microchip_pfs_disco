# -----------------------------------------------------------------------------
# libero_utils.tcl
#
# 6/12/2025 D. W. Hawkins (dwh@caltech.edu)
#
# Microsemi Libero SoC 2025.1 utilities script.
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
#      libero_utils.tcl : Libero project setup utilities (common)
#      variants.tcl     : Project variants (customized per project)
#      libero.tcl       : Project script (minor edits per project)
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Libero SoC Version
# -----------------------------------------------------------------------------
#
# Libero SoC 2025.1
# -----------------
# get_libero_version = 2025.1.0.14
# get_libero_release = 2025.1
#
# Libero SoC 2024.2
# -----------------
# get_libero_version = 2024.2.0.13
# get_libero_release = v2024.2
#
proc libero_version_number {} {
	# Get the version string
	set version [get_libero_release]

	# Strip the leading v (does nothing for 2025.1)
	set version [string map {v {}} $version]

	return $version
}

# -----------------------------------------------------------------------------
# Project
# -----------------------------------------------------------------------------
#
proc libero_project {variant} {

	# Project settings
	set board  [dict get $variant BOARD]
	set design [dict get $variant DESIGN]
	set build  [dict get $variant BUILD]

	switch $board {
		igloo2_eval {
			# IGLOO2 Evaluation Kit (M2GL-EVAL-KIT)
			new_project \
				-location $build                                 \
				-name $board                                     \
				-project_description {}                          \
				-block_mode 0                                    \
				-standalone_peripheral_initialization 0          \
				-instantiate_in_smartdesign 1                    \
				-ondemand_build_dh 1                             \
				-use_relative_path 0                             \
				-linked_files_root_dir_env {}                    \
				-hdl {VERILOG}                                   \
				-family {IGLOO2}                                 \
				-die {M2GL010T}                                  \
				-package {484 FBGA}                              \
				-speed {-1}                                      \
				-die_voltage {1.2}                               \
				-part_range {COM}                                \
				-adv_options {DSW_VCCA_VOLTAGE_RAMP_RATE:100_MS} \
				-adv_options {IO_DEFT_STD:LVCMOS 2.5V}           \
				-adv_options {PLL_SUPPLY:PLL_SUPPLY_33}          \
				-adv_options {RESTRICTPROBEPINS:1}               \
				-adv_options {RESTRICTSPIPINS:0}                 \
				-adv_options {SYSTEM_CONTROLLER_SUSPEND_MODE:0}  \
				-adv_options {TEMPR:COM}                         \
				-adv_options {VCCI_1.2_VOLTR:COM}                \
				-adv_options {VCCI_1.5_VOLTR:COM}                \
				-adv_options {VCCI_1.8_VOLTR:COM}                \
				-adv_options {VCCI_2.5_VOLTR:COM}                \
				-adv_options {VCCI_3.3_VOLTR:COM}                \
				-adv_options {VOLTR:COM}
		}
		pfs_disco {
			# Polarfire SoC Discovery Kit (MPFS-DISCO-KIT)
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
		}
		sf2_security {
			# SmartFusion2 Security Evaluation Kit (M2S090TS-EVAL-KIT)
			new_project \
				-location $build                                 \
				-name $board                                     \
				-project_description {}                          \
				-block_mode 0                                    \
				-standalone_peripheral_initialization 0          \
				-instantiate_in_smartdesign 1                    \
				-ondemand_build_dh 1                             \
				-use_relative_path 0                             \
				-linked_files_root_dir_env {}                    \
				-hdl {VERILOG}                                   \
				-family {SmartFusion2}                           \
				-die {M2S090TS}                                  \
				-package {484 FBGA}                              \
				-speed {-1}                                      \
				-die_voltage {1.2}                               \
				-part_range {COM}                                \
				-adv_options {DSW_VCCA_VOLTAGE_RAMP_RATE:100_MS} \
				-adv_options {IO_DEFT_STD:LVCMOS 2.5V}           \
				-adv_options {PLL_SUPPLY:PLL_SUPPLY_33}          \
				-adv_options {RESTRICTPROBEPINS:1}               \
				-adv_options {RESTRICTSPIPINS:0}                 \
				-adv_options {SYSTEM_CONTROLLER_SUSPEND_MODE:0}  \
				-adv_options {TEMPR:COM}                         \
				-adv_options {VCCI_1.2_VOLTR:COM}                \
				-adv_options {VCCI_1.5_VOLTR:COM}                \
				-adv_options {VCCI_1.8_VOLTR:COM}                \
				-adv_options {VCCI_2.5_VOLTR:COM}                \
				-adv_options {VCCI_3.3_VOLTR:COM}                \
				-adv_options {VOLTR:COM}
		}
		default {
			error "Error: Unknown board $board!"
		}
	}

	# Enable SystemVerilog files
	# * Set the Project > Project Settings, Design Flow, SystemVerilog radio button
	# * Synplify .prj setting 'set_option -vlog_std sysv'
	project_settings -verilog_mode {SYSTEM_VERILOG}

	return
}

# -----------------------------------------------------------------------------
# Add source
# -----------------------------------------------------------------------------
#
proc libero_add_source {variant} {

	# Source list
	set filenames [dict get $variant SOURCES]

	# Link to the project
	foreach filename $filenames {
		puts "libero.tcl: Link source file $filename"
		create_links              \
			-convert_EDN_to_HDL 0 \
			-hdl_source $filename
	}
	return
}

# -----------------------------------------------------------------------------
# Add constraints
# -----------------------------------------------------------------------------
#
# Link or import constraints files.
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
# The logic below can be modified to support other file types.
#
proc libero_add_constraints {variant} {

	# Project settings
	set board  [dict get $variant BOARD]
	set build  [dict get $variant BUILD]

	# Constraints list
	set filenames [dict get $variant CONSTRAINTS]

	# Imported and Linked constraint files
	set fdc_filenames {}
	set ndc_filenames {}
	set pdc_filenames {}
	set sdc_filenames {}
	foreach filename $filenames {
		set ext [file extension $filename]

		# Import or link constraints depending on their location
		if {[string first $build/constraint $filename] != -1} {
			# Import files in the $build/constraint directory
			puts "libero.tcl: Import constraint file $filename"
			switch $ext {
				.fdc {
					lappend fdc_filenames $filename
					import_files               \
						 -convert_EDN_to_HDL 0 \
						 -net_fdc $filename
				}
				.ndc {
					lappend ndc_filenames $filename
					import_files               \
						 -convert_EDN_to_HDL 0 \
						 -ndc $filename
				}
				.pdc {
					if {[string first _io.pdc $filename] != -1} {
						lappend pdc_filenames $filename
						import_files               \
							 -convert_EDN_to_HDL 0 \
							 -io_pdc $filename
					} elseif {[string first _fp.pdc $filename] != -1} {
						lappend pdc_filenames $filename
						import_files               \
							 -convert_EDN_to_HDL 0 \
							 -fp_pdc $filename
					} else {
						error "Error: Incorrect PDC file name!"
					}
				}
				.sdc {
					lappend sdc_filenames $filename
					import_files               \
						 -convert_EDN_to_HDL 0 \
						 -sdc $filename
				}
				default {
					error "Error: unknown constraint extension!"
				}
			}
		} else {
			# Link files in the $scripts directory
			puts "libero.tcl: Link constraint file $filename"
			switch $ext {
				.fdc {
					lappend fdc_filenames $filename
					create_links               \
						 -convert_EDN_to_HDL 0 \
						 -net_fdc $filename
				}
				.ndc {
					lappend ndc_filenames $filename
					create_links               \
						 -convert_EDN_to_HDL 0 \
						 -ndc $filename
				}
				.pdc {
					if {[string first _io.pdc $filename] != -1} {
						lappend pdc_filenames $filename
						create_links               \
							 -convert_EDN_to_HDL 0 \
							 -io_pdc $filename
					} elseif {[string first _fp.pdc $filename] != -1} {
						lappend pdc_filenames $filename
						create_links               \
							 -convert_EDN_to_HDL 0 \
							 -fp_pdc $filename
					} else {
						error "Error: Incorrect PDC file name!"
					}
				}
				.sdc {
					lappend sdc_filenames $filename
					create_links               \
						 -convert_EDN_to_HDL 0 \
						 -sdc $filename
				}
				default {
					error "Error: unknown constraint extension!"
				}
			}
		}
	}

	# The organize_tool_files command requires a separate
	# -file argument for each of the SDC or PDC files.

	# organize_tool_files -module argument
	set module ${board}::work

	# Enable FDC and NDC for synthesis
	set file_arg {}
	foreach filename $fdc_filenames {
		lappend file_arg -file
		lappend file_arg $filename
	}
	foreach filename $ndc_filenames {
		lappend file_arg -file
		lappend file_arg $filename
	}
	if {[llength $file_arg]} {
		organize_tool_files -tool {SYNTHESIZE} \
			{*}$file_arg                       \
			-module $module                    \
			-input_type {constraint}
	}

	# Enable SDC and PDC files for place-and-route
	set file_arg {}
	foreach filename $sdc_filenames {
		lappend file_arg -file
		lappend file_arg $filename
	}
	foreach filename $pdc_filenames {
		lappend file_arg -file
		lappend file_arg $filename
	}
	if {[llength $file_arg]} {
		organize_tool_files -tool {PLACEROUTE} \
			{*}$file_arg                       \
			-module $module                    \
			-input_type {constraint}
	}

	# Enable SDC files for verify timing
	set file_arg {}
	foreach filename $sdc_filenames {
		lappend file_arg -file
		lappend file_arg $filename
	}
	if {[llength $file_arg]} {
		organize_tool_files -tool {VERIFYTIMING} \
			{*}$file_arg                         \
			-module $module                      \
			-input_type {constraint}
	}

	return
}
