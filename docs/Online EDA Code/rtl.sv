module up_down_counter #(
  parameter int unsigned WIDTH = 4
) (
  input  logic             clk,
  input  logic             rst_n,
  input  logic             enable,
  input  logic             load,
  input  logic             up_down,
  input  logic [WIDTH-1:0] load_data,
  output logic [WIDTH-1:0] count
);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      count <= '0;
    else if (load)
      count <= load_data;
    else if (enable) begin
      if (up_down)
        count <= count + 1'b1;
      else
        count <= count - 1'b1;
    end
  end

endmodule