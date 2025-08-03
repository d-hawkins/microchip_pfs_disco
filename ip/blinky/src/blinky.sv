// ----------------------------------------------------------------------------
// blinky.sv
//
// 1/15/2025 D. W. Hawkins (dwh@caltech.edu)
//
// Blinky LED component.
//
// Top-level designs can pipeline the output through fabric or I/O registers.
//
// ----------------------------------------------------------------------------
// Notes
// -----
//
// 1. CNT_WIDTH
//
//    The counter width calculation was moved to a high-level of the design
//    due to a bug in Synplify Elite (Release W-2025.03) where designs that
//    use Distributed TMR designs would be implemented correctly, but the
//    design hierarchy would not be reported correctly. The design hierarchy
//    report is accessed from the "Project Status" GUI by clicking on the
//    "Hierachical Area Report" link, which selects the "Report" tab.
//    Elements of the design that use Distributed TMR should expand to show
//    the three instances within the component. Designs that use this
//    'blinky' component work correctly. Designs that used the previous
//    version with real valued parameters CLK_FREQUENCY and BLINK_PERIOD
//    would not show hierarchy in the report.
//
//    Example report hierarchy:
//
//    igloo2
//      > blinky_32s_8s
//          > C_1_TMR0
//          > C_1_TMR1
//          > C_1_TMR2
//      > cdc_sync_bit_0s_2s
//
// 2. Reset
//
//    Applications that use TMR should use reset on devices that do not
//    guarantee the startup state of the flip-flops, otherwise the TMR
//    voting could see three different initial register states.
//
// ----------------------------------------------------------------------------

module blinky #(
		parameter int CNT_WIDTH = 32,
		parameter int LED_WIDTH = 8
	) (
		// --------------------------------------------------------------------
		// Reset
		// --------------------------------------------------------------------
		//
		input rst_n,

		// --------------------------------------------------------------------
		// Clock
		// --------------------------------------------------------------------
		//
		input clk,

		// --------------------------------------------------------------------
		// User I/O
		// --------------------------------------------------------------------
		//
		// LEDs
		output [LED_WIDTH-1:0] led
	);

	// ------------------------------------------------------------------------
	// Local signals
	// ------------------------------------------------------------------------
	//
	// Counter
	logic [CNT_WIDTH-1:0] count;

	// ------------------------------------------------------------------------
	// Counter
	// ------------------------------------------------------------------------
	//
	always_ff @(negedge rst_n or posedge clk) begin
		if (~rst_n) begin
			count <= '0;
		end
		else begin
			count <= count + 1'b1;
		end
	end

	// ------------------------------------------------------------------------
	// LED outputs
	// ------------------------------------------------------------------------
	//
	assign led = count[(CNT_WIDTH-1) -: LED_WIDTH];

endmodule
