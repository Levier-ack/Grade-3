module mycpu_axi(
    input [5:0] int,
    input clk,
    input resetn,
    //inst_sram
    input inst_req,
    input inst_wr,
    input [1:0] inst_size,
    input [31:0] inst_addr,
    input [31:0] inst_wdata,
    output [31:0] inst_rdata,
    output inst_addr_ok,
    output inst_data_ok,
    //data_sram
    input data_req,
    input data_wr,
    input [1:0] data_size,
    input [31:0] data_addr,
    input [31:0] data_wdata,
    output [31:0] data_rdata,
    output data_addr_ok,
    output data_data_ok,
    //ar
    output reg  [3 :0] arid   ,
    output [31:0] araddr ,
    output [7 :0] arlen  ,
    output reg  [2 :0] arsize ,
    output [1 :0] arburst,
    output [1 :0] arlock ,
    output [3 :0] arcache,
    output [2 :0] arprot ,
    output  reg   arvalid, 
    input          arready,
    //r
    input [3 :0] rid    ,
    input [31:0] rdata  ,
    input [1 :0] rresp  ,
    input        rlast  ,
    input        rvalid ,
    output reg   rready ,
    //aw
    output reg  [3 :0] awid   ,
    output [31:0] awaddr ,
    output [7 :0] awlen  ,
    output reg  [2 :0] awsize ,
    output [1 :0] awburst,
    output [1 :0] awlock ,
    output [3 :0] awcache,
    output [2 :0] awprot ,
    output reg         awvalid,
    input          awready,
    //w
    output [3 :0] wid    ,
    output [31:0] wdata  ,
    output [3 :0] wstrb  ,
    output       wlast  ,
    output reg     wvalid ,
    input          wready ,
    //b
    input   [3 :0] bid    ,
    input   [1 :0] bresp  ,
    input          bvalid ,
    output   reg   bready

);




wire [3:0] wire_wstrb; 
wire [2:0] state;
reg reg_inst_addr_ok;
reg reg_data_addr_ok;
reg  [31:0] reg_awaddr;
reg  [31:0] reg_araddr;
reg  [3:0] reg_wstrb;
reg  [31:0] reg_wdata;
reg reg_data_wr;
// assign state = (inst_req)?3'b100:
//                 (data_req && ~data_wr)?3'b010:
//                 (data_req && data_wr)?3'b001:3'b000;

assign state = (data_req && ~data_wr)?3'b010:
                (data_req && data_wr)?3'b001:
                (inst_req)?3'b100:3'b000;

//inst_sram**************************************************************************************************
assign inst_addr_ok = (reg_inst_addr_ok || reg_data_addr_ok)?1'b0:
                      (state == 3'd4)?1'b1:1'b0;
always@(posedge clk)
begin
  if(!resetn)
  begin
    reg_inst_addr_ok <= 1'b0;
  end
  else if(inst_addr_ok)
  begin
    reg_inst_addr_ok <= 1'b1;
  end
  else if(inst_data_ok)
  begin
    reg_inst_addr_ok <= 1'b0;
  end
end
assign inst_data_ok = rvalid && rready && reg_inst_addr_ok; 
assign inst_rdata   = (inst_data_ok)?rdata:32'h0;
//data_sram**************************************************************************************************
assign data_addr_ok = (data_wr)?data_req:((reg_inst_addr_ok || reg_data_addr_ok)?1'b0:data_req);
always@(posedge clk)
begin
  if(!resetn)
  begin
    reg_data_addr_ok <= 1'b0;
  end
  else if(data_addr_ok) 
  begin
    reg_data_addr_ok <= 1'b1;
  end
  else if(data_data_ok)
  begin
    reg_data_addr_ok <= 1'b0; 
  end
end

always@(posedge clk)
begin
  if(!resetn)
  begin
    reg_data_wr <= 1'b0;
  end
  else if(data_addr_ok)
  begin
    reg_data_wr <= data_wr;
  end
  else if(data_data_ok)
  begin
    reg_data_wr <= 1'b0;
  end
end

assign data_data_ok = (reg_data_addr_ok && reg_data_wr)?(bvalid && bready):((reg_inst_addr_ok || inst_addr_ok)?1'b0:(rvalid && rready));
// assign data_data_ok = (reg_data_req)?(bvalid && bready) : (rvalid && rready);
assign data_rdata   = (data_data_ok && ~reg_data_wr)?rdata:32'h0;
//ar**************************************************************************************************
always@(posedge clk)
begin
  if(!resetn)
  begin
    arid <= 4'h0;
  end
  else if(inst_addr_ok || data_addr_ok) 
  begin
    arid <= inst_wr;
  end
  else if(inst_data_ok)
  begin
    arid <= 4'h0;
  end
end

always@(posedge clk)
begin
  if(!resetn)
  begin
    reg_araddr <= 32'h0;
  end
  else if(inst_addr_ok || data_addr_ok)
  begin
    reg_araddr <= (data_addr_ok && ~data_wr)?data_addr:inst_addr;
  end
  else if(arvalid && arready)
  begin
    reg_araddr <= 32'h0;
  end
end

assign araddr = (arvalid && arready || reg_inst_addr_ok || reg_data_addr_ok)?reg_araddr:32'h0;

always@(posedge clk)
begin
  if(!resetn)
  begin
    arsize <= 3'b0;
  end
  else if(data_addr_ok)
  begin
    arsize <= {1'b0,inst_size};
  end
  else if(inst_addr_ok)
  begin
    arsize <= {1'b0,inst_size};
  end
  else if(inst_data_ok || data_data_ok)
  begin
    arsize <= 3'b0;
  end
end

assign arlen    = 8'd0;
assign arburst  = (arvalid)?2'b01:2'b0;
assign arlock   = (arvalid)?2'd0:2'b0;
assign arcache  = (arvalid)?4'd0:4'h0;
assign arprot   = (arvalid)?3'd0:3'b0; 


always@(posedge clk)
begin
  if(!resetn)
  begin
    arvalid <= 1'b0;
  end
  else if(inst_addr_ok || (data_addr_ok && ~data_wr))
  begin
    arvalid <= 1'b1;
  end
  else if(arvalid && arready)
  begin
    arvalid <= 1'b0;
  end
end

//r**************************************************************************************************
// assign rready   = ~(inst_req || (data_req && ~data_wr));
always@(posedge clk)
begin
  if(!resetn)
  begin
    rready <= 1'b0;
  end
  else if((reg_inst_addr_ok && ~inst_data_ok) || (reg_data_addr_ok && ~data_data_ok))
  begin
    rready <= 1'b1;
  end
  else if(inst_data_ok || data_data_ok)
  begin
    rready <= 1'b0;
  end
end
//aw**************************************************************************************************
always@(posedge clk)
begin
    if(!resetn)
    begin
        awid <= 4'h0;
    end
    else if(data_addr_ok && data_wr)
    begin
        awid <= 4'd1;
    end
    else if(data_data_ok)
    begin
        awid <= 4'h0;
    end
end

always@(posedge clk)
begin
  if(!resetn)
  begin
    reg_awaddr <= 32'h0;// reg_awaddr <= 32'h00xx;
  end
  else if(data_addr_ok && data_wr)
  begin
    reg_awaddr <= data_addr;
  end
  else if(awvalid && awready)
  begin
    reg_awaddr <= 32'h0;
  end
end

assign awaddr = (awvalid && awready || (reg_data_addr_ok && reg_data_wr))?reg_awaddr:32'h0;

always@(posedge clk)
begin
  if(!resetn)
  begin
    awsize <= 3'b0;
  end
  else if(data_addr_ok && data_wr)
  begin
    awsize <= {1'b0,data_size};
  end
end

assign awlen    = 8'd0;
assign awburst  = (awvalid)?2'b01:2'b0;
assign awlock   = (awvalid)?2'd0:2'b0;
assign awcache  = (awvalid)?4'd0:4'h0;
assign awprot   = (awvalid)?3'd0:3'b0;

always@(posedge clk)
begin
  if(!resetn)
  begin
    awvalid <= 1'b0;
  end
  else if(data_addr_ok && data_wr)
  begin
    awvalid <= 1'b1;
  end
  else if(awvalid && awready)
  begin
    awvalid <= 1'b0;
  end
end
//w**************************************************************************************************
assign wid      = (wvalid)?4'd1:4'h0;
assign wlast    = (wvalid)?1'b1:1'b0;
always@(posedge clk)
begin
  if(!resetn)
  begin
    reg_wstrb <= 4'h0;
  end
  else if(data_addr_ok && data_wr)
  begin 
    reg_wstrb <= wire_wstrb;
  end
  else if(bvalid && bready)
  begin
    reg_wstrb <= 4'h0;
  end
end

assign  wire_wstrb = {(data_size==2'b10)||(data_size==2'b01&&data_addr[1:0]==2'b10)||(data_size==2'b00&&data_addr[1:0]==2'b11)||(data_size==2'b11&&data_addr[1:0]==2'b01),
                    (data_size==2'b10)||(data_size==2'b01&&data_addr[1:0]==2'b10)||(data_size==2'b00&&data_addr[1:0]==2'b10)||(data_size==2'b11&&data_addr[1:0]==2'b10)||(data_size==2'b11&&data_addr[1:0]==2'b01),
                    (data_size==2'b10)||(data_size==2'b01&&data_addr[1:0]==2'b00)||(data_size==2'b00&&data_addr[1:0]==2'b01)||(data_size==2'b01&&data_addr[1:0]==2'b01)||(data_size==2'b11&&data_addr[1:0]==2'b10)||(data_size==2'b11&&data_addr[1:0]==2'b01),
                    (data_size==2'b10)||(data_size==2'b01&&data_addr[1:0]==2'b00)||(data_size==2'b00&&data_addr[1:0]==2'b00)||(data_size==2'b01&&data_addr[1:0]==2'b01)||(data_size==2'b11&&data_addr[1:0]==2'b10)};


always@(posedge clk)
begin
  if(!resetn)
  begin
    reg_wdata <= 32'h0;
  end
  else if(data_addr_ok && data_wr)
  begin
    reg_wdata <= {{8{wire_wstrb[3]}},{8{wire_wstrb[2]}},{8{wire_wstrb[1]}},{8{wire_wstrb[0]}}} & data_wdata;
  end
  else if(bvalid && bready)
  begin
    reg_wdata <= 32'h0;
  end
end

assign wstrb = (wvalid)?reg_wstrb:32'h0;
assign wdata = (wvalid)?reg_wdata:32'h0;

always@(posedge clk)
begin
  if(!resetn)
  begin
    wvalid <= 1'b0;
  end
  else if(data_addr_ok && data_wr)
  begin
    wvalid <= 1'b1;
  end
  else if(wvalid && wready)
  begin
    wvalid <= 1'b0;
  end
end
//b**************************************************************************************************
// assign bready   = ~(data_req && data_wr);
always@(posedge clk)
begin
  if(!resetn)
  begin
    bready <= 1'b0;
  end
  else if(reg_data_addr_ok && reg_data_wr && ~data_data_ok)
  begin
    bready <= 1'b1;
  end
  else if(data_data_ok)
  begin
    bready <= 1'b0;
  end
end
endmodule