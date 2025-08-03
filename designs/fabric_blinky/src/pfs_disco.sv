// ----------------------------------------------------------------------------
// pfs_disco.sv
//
// 7/25/2025 D. W. Hawkins (dwh@caltech.edu)
//
// Microchip PolarFire SoC Discovery Kit 'blinky' example design.
//
// ----------------------------------------------------------------------------

module pfs_disco (

		// --------------------------------------------------------------------
		// Asynchronous Reset
		// --------------------------------------------------------------------
		//
		input        arst_n,

		// --------------------------------------------------------------------
		// Clock
		// --------------------------------------------------------------------
		//
		input        clk_50mhz,

		// --------------------------------------------------------------------
		// User I/O
		// --------------------------------------------------------------------
		//
		// LEDs
		output [6:0] led,
		//
		// UART
		input        uart_rx,
		output       uart_tx,
		//
		// Probe signals
		output [3:0] probe

	);

	// ------------------------------------------------------------------------
	// Local parameters
	// ------------------------------------------------------------------------
	//
	// Clock frequency
	localparam real CLK_50MHZ_FREQUENCY = 50.0e6;

	// LED blink rate
	localparam real BLINK_PERIOD = 0.5;

	// LED width
	localparam integer LED_WIDTH = 7;

	// Counter width
	//
	// Note: the integer'() casts are important, without them Vivado
	// generates incorrect counter widths (much wider than expected)
	//
	// 7 LEDs driven by 50MHz
	localparam integer CNT_WIDTH =
		$clog2(integer'(CLK_50MHZ_FREQUENCY*BLINK_PERIOD)) + (LED_WIDTH-1);

	// ------------------------------------------------------------------------
	// Local signals
	// ------------------------------------------------------------------------
	//
	// Clock
	wire clk;

	// Power-on-reset
	wire device_init_done;
	wire bank_0_calib_status;
	logic por_n;

	// Reset
	logic rst_n_in;
	logic rst_n;

	// Blinky ouput
	wire  [LED_WIDTH-1:0] led_o;

	// Output registers
	logic [LED_WIDTH-1:0] led_r;

	// ------------------------------------------------------------------------
	// PolarFire SoC Initialization Monitor
	// ------------------------------------------------------------------------
	//
	pfs_init_monitor u1 (
		.fabric_por_n               (),
		.pcie_init_done             (),
		.sram_init_done             (),
		.device_init_done           (device_init_done),
		.usram_init_done            (),
		.xcvr_init_done             (),
		.usram_init_from_snvm_done  (),
		.usram_init_from_uprom_done (),
		.usram_init_from_spi_done   (),
		.sram_init_from_snvm_done   (),
		.sram_init_from_uprom_done  (),
		.sram_init_from_spi_done    (),
		.autocalib_done             (),
		.bank_0_calib_status        (bank_0_calib_status),
		.bank_1_calib_status        ()
    );

	// ------------------------------------------------------------------------
	// Global Clock Buffer
	// ------------------------------------------------------------------------
	//
	CLKBUF u2 (
		.PAD (clk_50mhz),
		.Y   (clk      )
	);

	// ------------------------------------------------------------------------
	// Reset Synchronizer
	// ------------------------------------------------------------------------
	//
	cdc_sync_bit #(
		.RESET_STATE (1'b0),      // Active low
		.PIPELINE    (4   )       // Number of FFs
	) u3 (
		.rst_n (por_n   ),        // Asynchronous input
		.clk   (clk     ),        // Clock-domain
		.d     (1'b1    ),        // Deasserted level
		.q     (rst_n_in)         // Async-assert / Sync-deassert reset
	);

	// Asynchronous reset sources
	// * The state of arst_n is 'unknown' until bank 0 calibration completes
	assign por_n = device_init_done & bank_0_calib_status & arst_n;

	// ------------------------------------------------------------------------
	// Global Buffer
	// ------------------------------------------------------------------------
	//
	CLKINT u4 (
		.A (rst_n_in),
		.Y (rst_n   )
	);

	// ------------------------------------------------------------------------
	// Blinky
	// ------------------------------------------------------------------------
	//
	blinky #(
		.CNT_WIDTH (CNT_WIDTH),
		.LED_WIDTH (LED_WIDTH)
	) u5 (
		.rst_n (rst_n),
		.clk   (clk  ),
		.led   (led_o)
	);

	// ------------------------------------------------------------------------
	// LED outputs
	// ------------------------------------------------------------------------
	//
	// The LED outputs are registered so that PDC constraints can be used to
	// place the registers in the IOB or fabric registers.
	//
	// These pipeline registers do not need to use reset.
	//
	always_ff @(posedge clk) begin
		led_r <= led_o;
	end
	assign led = led_r;

	// ------------------------------------------------------------------------
	// UART loopback
	// ------------------------------------------------------------------------
	//
	assign uart_tx = uart_rx;

	// ------------------------------------------------------------------------
	// Probes
	// ------------------------------------------------------------------------
	//
	assign probe = {
		rst_n,
		bank_0_calib_status,
		device_init_done,
		1'b0
	};

endmodule

