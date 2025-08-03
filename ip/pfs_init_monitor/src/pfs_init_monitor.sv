// ----------------------------------------------------------------------------
// pfs_init_monitor.sv
//
// 7/25/2025 D. W. Hawkins (dwh@caltech.edu)
//
// Microchip PolarFire SoC Initialization Monitor.
//
// This component was created based on the generated code for the
// "PolarFireSoC Initialization Monitor version 1.0.309" component.
//
// ----------------------------------------------------------------------------
// References
// ----------
//
// [1] Microchip, "PolarFire FPGA and PolarFire SoC FPGA Macro Library
//     User Guide", DS50003078, Rev. J, Libero v2023.1.
//     https://ww1.microchip.com/downloads/aemDocuments/documents/FPGA/
//         core-docs/Libero/2023_1/tool/pf_mlg.pdf
//
//     Page 56 has a good description of the INIT ports.
//
// ----------------------------------------------------------------------------

module pfs_init_monitor (
		output fabric_por_n,
		output pcie_init_done,
		output sram_init_done,
		output device_init_done,
		output usram_init_done,
		output xcvr_init_done,
		output usram_init_from_snvm_done,
		output usram_init_from_uprom_done,
		output usram_init_from_spi_done,
		output sram_init_from_snvm_done,
		output sram_init_from_uprom_done,
		output sram_init_from_spi_done,
		output autocalib_done,
		output bank_0_calib_status,
		output bank_1_calib_status
	);

	// ------------------------------------------------------------------------
	// Initialization Monitor
	// ------------------------------------------------------------------------
	//
	INIT #(
		.FABRIC_POR_N_SIMULATION_DELAY    ( 1000),
		.PCIE_INIT_DONE_SIMULATION_DELAY  ( 4000),
		.SRAM_INIT_DONE_SIMULATION_DELAY  ( 6000),
		.UIC_INIT_DONE_SIMULATION_DELAY   (12000),
		.USRAM_INIT_DONE_SIMULATION_DELAY ( 9000)
	) u1 (
		.FABRIC_POR_N    (fabric_por_n  ),
		.GPIO_ACTIVE     (              ),
		.HSIO_ACTIVE     (              ),
		.PCIE_INIT_DONE  (pcie_init_done),
		.RFU({
			autocalib_done,
			nc0,
			nc1,
			nc2,
			nc3,
			sram_init_from_spi_done,
			sram_init_from_uprom_done,
			sram_init_from_snvm_done,
			usram_init_from_spi_done,
			usram_init_from_uprom_done,
			usram_init_from_snvm_done,
			xcvr_init_done
		}),
		.SRAM_INIT_DONE  (sram_init_done  ),
		.UIC_INIT_DONE   (device_init_done),
		.USRAM_INIT_DONE (usram_init_done )
	);

	// ------------------------------------------------------------------------
	// HSIO Calibration
	// ------------------------------------------------------------------------
	//
	BANKCTRL_HSIO #(
		.CALIB_STATUS_SIMULATION_DELAY (1000   ),
		.BANK_NUMBER                   ("bank0"),
		.PC_REG_CALIB_START            (1'b0   ),
		.PC_REG_CALIB_LOCK             (1'b0   ),
		.PC_REG_CALIB_LOAD             (1'b0   )
	)  u2 (
		.CALIB_STATUS     (bank_0_calib_status),
		.CALIB_INTERRUPT  (                   ),
		.CALIB_DIRECTION  (1'b0               ),
		.CALIB_LOAD       (1'b1               ),
		.CALIB_LOCK       (1'b0               ),
		.CALIB_MOVE_NCODE (1'b0               ),
		.CALIB_MOVE_PCODE (1'b0               ),
		.CALIB_START      (1'b0               ),
		.CALIB_MOVE_SLEWR (1'b0               ),
		.CALIB_MOVE_SLEWF (1'b0               )
	);

	// ------------------------------------------------------------------------
	// GPIO Calibration
	// ------------------------------------------------------------------------
	//
	BANKCTRL_GPIO #(
		.CALIB_STATUS_SIMULATION_DELAY (1000   ),
		.BANK_NUMBER                   ("bank1"),
		.PC_REG_CALIB_START            (1'b0   ),
		.PC_REG_CALIB_LOCK             (1'b0   ),
		.PC_REG_CALIB_LOAD             (1'b0   )
	)  u3 (
		.CALIB_STATUS         (bank_1_calib_status),
		.CALIB_INTERRUPT      (                   ),
		.CALIB_DIRECTION      (1'b0               ),
		.CALIB_LOAD           (1'b1               ),
		.CALIB_LOCK           (1'b0               ),
		.CALIB_MOVE_NCODE     (1'b0               ),
		.CALIB_MOVE_PCODE     (1'b0               ),
		.CALIB_START          (1'b0               ),
		.CALIB_MOVE_DIFFR_PVT (1'b0               )
	);

endmodule
