`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/05/2024 03:40:51 PM
// Design Name: 
// Module Name: design2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module source_mem(clk,data_out,adrs);
input clk;
reg [17:0] address = 0;
output [17:0] adrs;
output reg [7:0] data_out;

 (* RAM_STYLE="BLOCK" *)
 reg [7:0] data_mem [66563:0];
 
initial $readmemb("", data_mem);

 always @(posedge clk)
 begin        
     if(address <= 66563)
     begin
          data_out = data_mem[address];
          address = address + 1;
     end
 end
 
 assign adrs = address;
 endmodule
 
 
 
 
module k_means_cluster(input clk,rst,read,input [7:0] data_in,input [17:0] adrs,output [7:0] Data_out);

reg [7:0] image[66563:0];
source_mem DUT(clk,data_in,adrs);
//clusters
parameter k = 2;
parameter width = 30;//image width
parameter height = 30;//image height
integer it = 0;
integer s = 0;

//cluster centers
reg [7:0] centroids[k - 1:0];
 
integer i = 0;
reg [31:0] temp = 0;
reg [31:0] update_it = 0;
//cluster_count
reg [31:0] cluster_count[k - 1 : 0];

//parameters
reg[8:0] dist = 345 * 345;
reg[8:0] cur_dist;
reg[31:0] euc_dist;  
reg[11:0] centroid_idx;

reg[31:0] dist_diff;
reg[31:0] min_diff = 256;
reg final_cent = 0;

parameter INITIAL = 0,RST = 1,FIND_DIST = 2,UPDATE_CENT = 3,UPDATE_IMAGE = 4,WAIT = 5;
reg[2:0] state = INITIAL;

integer j = 0;
integer p = 0;

always @(posedge clk)
begin
    case(state)
        WAIT: state = WAIT;
        INITIAL:begin
                    for(it = 0; it < k; it = it + 1) cluster_count[it] = 1;
                    state = RST;
                end
        RST:begin
            for(i = 0; i < k; i = i + 1)
                begin
                    temp = (temp + i * i * 10) % (255);
                    centroids[i] = temp;
                end
                state = FIND_DIST;
            end
           
        FIND_DIST:
        begin
            for(j = 0; j < k; j = j + 1)
            begin
                cur_dist = data_in - centroids[j];
                euc_dist = cur_dist * cur_dist;
                if(euc_dist < dist)
                begin
                    centroid_idx = j;
                    dist = euc_dist;
                end
            end
            cluster_count[centroid_idx] = cluster_count[centroid_idx] + 1;
            dist = 345 * 345;
            state = UPDATE_CENT;
        end
       
        UPDATE_CENT:
        begin
            centroids[centroid_idx] = (centroids[centroid_idx] + data_in)/(cluster_count[centroid_idx]);
            image[adrs - 1] = data_in;
           
            if(adrs == 66564) state = UPDATE_IMAGE;
            else state = FIND_DIST;
        end
       
        UPDATE_IMAGE:
        begin
            for(s = 0; s < k; s = s + 1)
            begin
               dist_diff = image[update_it] - centroids[s];
               if(dist_diff < 0) dist_diff = -dist_diff;
               if(dist_diff < min_diff)
               begin
                    min_diff = dist_diff;
                    final_cent = s;
               end
            end
            image[update_it] = centroids[final_cent];
            update_it = update_it + 1;
            if(update_it == 66364) state = WAIT;  
        end
    endcase
end
endmodule