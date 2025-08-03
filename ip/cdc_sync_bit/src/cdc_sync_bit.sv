// ----------------------------------------------------------------------------
// cdc_sync_bit.sv
//
// 7/4/2017 D. W. Hawkins (dwh@caltech.edu)
//
// A synchronizer for active high or low external signals.
//
// The reset state for the synchronizer is the inactive level.
// The generic is used to generate the appropriate reset state.
//
// ----------------------------------------------------------------------------

module cdc_sync_bit #(
		// Reset state
		parameter bit RESET_STATE  = 1'b0, // '0' for active low sync

		// Synchronizer pipeline delays (2 or more DFFs)
		parameter integer PIPELINE = 2
	) (
		input  logic rst_n,
		input  logic clk,
		input  logic d,
		output logic q
	);

	// ------------------------------------------------------------------------
	// Local signals
	// ------------------------------------------------------------------------
	//
	// Xilinx devices need an ASYNC_REG constraint on these registers.
	logic [PIPELINE-1:0] d_meta /* synthesis syn_preserve = 1 */;

	// ------------------------------------------------------------------------
	// Generics check
	// ------------------------------------------------------------------------
	//
	pipeline_check: assert final (PIPELINE >= 2) else
		$error("Error: PIPELINE must be 2 or greater!");

	// ------------------------------------------------------------------------
	// Synchronizer
	// ------------------------------------------------------------------------
	//
	always_ff @(negedge rst_n or posedge clk)
	begin
		if (~rst_n) begin
			// Use the replicate/concatenate operator to initialize
			// the pipeline registers to the desired reset state
			d_meta <= {PIPELINE{RESET_STATE}};
		end
		else begin
			d_meta[0] <= d;
			for (int i = 1; i < PIPELINE; i++) begin
				d_meta[i] <= d_meta[i-1];
			end
		end
	end
	assign q = d_meta[PIPELINE-1];
endmodule
