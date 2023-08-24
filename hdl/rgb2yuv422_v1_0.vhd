library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rgb2yuv422_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here
        tdata_in : in std_logic_vector(23 downto 0);
        tdata_out : out std_logic_vector(47 downto 0);
        ready_out : out std_logic;
        valid_in : in std_logic;
        ready_in : in std_logic;
        valid_out : out std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end rgb2yuv422_v1_0;

architecture arch_imp of rgb2yuv422_v1_0 is

	-- component declaration
	component rgb2yuv422_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component rgb2yuv422_v1_0_S00_AXI;

    signal transfer_data : std_logic_vector(31 downto 0);
	signal R : std_logic_vector(7 downto 0);
	signal G : std_logic_vector(7 downto 0);
	signal B : std_logic_vector(7 downto 0);
	signal Y : std_logic_vector(7 downto 0);
	signal Y1 : std_logic_vector(7 downto 0);
	signal Y1_reg : std_logic_vector(7 downto 0);
	signal Y2 : std_logic_vector(7 downto 0);
	signal U : std_logic_vector(7 downto 0);
	signal U_M : std_logic_vector(7 downto 0);
	signal V_M : std_logic_vector(7 downto 0);
	signal U2 : std_logic_vector(7 downto 0);
	signal U1 : std_logic_vector(7 downto 0);
	signal U1_reg : std_logic_vector(7 downto 0);
	signal V : std_logic_vector(7 downto 0);
	signal V2 : std_logic_vector(7 downto 0);
	signal V1 : std_logic_vector(7 downto 0);
	signal V1_reg : std_logic_vector(7 downto 0);
	signal stream_counter : std_logic;
	type state is (IDLE,ACQUIRE,STREAM);
	signal current_state : state;
begin

-- Instantiation of Axi Bus Interface S00_AXI
rgb2yuv422_v1_0_S00_AXI_inst : rgb2yuv422_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

	-- Add user logic here
tdata_out <= ("0000000000000000" & transfer_data);
    R <= tdata_in(23 downto 16);
    B <= tdata_in(15 downto 8);
    G <= tdata_in(7 downto 0);
    
    Y <= std_logic_vector( 
          unsigned(std_logic_vector'("00"& R(7 downto 2))) +
          unsigned(std_logic_vector'("00000"& R(7 downto 5))) +
          unsigned(std_logic_vector'("000000"& R(7 downto 6))) +
          
          unsigned(std_logic_vector'("0"& G(7 downto 1))) +
          unsigned(std_logic_vector'("0000"& G(7 downto 4))) +
          unsigned(std_logic_vector'("000000"& G(7 downto 6))) +
          unsigned(std_logic_vector'("0000000"& G(7 downto 7))) +
          
          unsigned(std_logic_vector'("0000"& B(7 downto 4))) +
          unsigned(std_logic_vector'("00000"& B(7 downto 5))) +
          unsigned(std_logic_vector'("000000"& B(7 downto 6))) +
          unsigned(std_logic_vector'("0000000"& B(7 downto 7)))
          );
          
    U <= std_logic_vector( 
    
          unsigned(std_logic_vector'("00"& B(7 downto 2))) +
          unsigned(std_logic_vector'("000"& B(7 downto 3))) +
          unsigned(std_logic_vector'("0000"& B(7 downto 4))) -
          
          unsigned(std_logic_vector'("00"& G(7 downto 2))) -
          unsigned(std_logic_vector'("00000"& G(7 downto 5))) -
          unsigned(std_logic_vector'("0000000"& G(7 downto 7))) -
          
          unsigned(std_logic_vector'("000"& R(7 downto 3))) -
          unsigned(std_logic_vector'("000000"& R(7 downto 6))) -
          unsigned(std_logic_vector'("0000000"& R(7 downto 7))) 
          
          
          
          );
     
     V <= std_logic_vector( 
          unsigned(std_logic_vector'("0"& R(7 downto 1))) +
          unsigned(std_logic_vector'("000"& R(7 downto 3))) -
                 
          unsigned(std_logic_vector'("0"& G(7 downto 1))) -
          
          unsigned(std_logic_vector'("0000"& B(7 downto 4))) -
          unsigned(std_logic_vector'("00000"& B(7 downto 5))) -
          unsigned(std_logic_vector'("00000000"& B(7 downto 7))) 
          );
          
    
          
          
          
          process(s00_axi_aclk)
          begin
          if (rising_edge(s00_axi_aclk)) then
            if (s00_axi_aresetn = '0') then
            
                current_state <= IDLE; 
                U2 <= (others => '0');
                V2 <= (others => '0');
                stream_counter <= '0';
            else
            case (current_state) is
                    when IDLE =>
                        stream_counter <= '0';
                        valid_out <= '0';

                        if (valid_in = '1') then
                        ready_out <= '1';
                        current_state <= ACQUIRE;
                        valid_out <= '0';
                        Y1 <= Y;
                        U1 <= U;
                        V1 <= V;
                        end if;  
                     when ACQUIRE =>
                        Y1 <= Y1_reg;
                        U1 <= U1_reg;
                        V1 <= V1_reg;
                        if (valid_in = '1') then
                            Y2 <= Y;
                            U2 <= U;
                            V2 <= V;
                            U_M <= std_logic_vector( unsigned(std_logic_vector'("0"& U1(7 downto 1))) +
                            unsigned(std_logic_vector'("0"& U2(7 downto 1))));
                            V_M <= std_logic_vector( unsigned(std_logic_vector'("0"& V1(7 downto 1))) +
                            unsigned(std_logic_vector'("0"& V2(7 downto 1))));
                            valid_out <= '1';                          
                            current_state <= STREAM;
                            stream_counter <= '0';
                        end if;
                     
                     when STREAM =>
                        transfer_data <= (V_M & Y2 & U_M & Y1);
                        if (ready_in = '1') then
                            current_state <= ACQUIRE;
                            valid_out <= '0';
                            ready_out <= '1';
                            Y1_reg <= Y;
                            U1_reg <= U;
                            V1_reg <= V;
                         end if;

                     when others =>
                        current_state <= IDLE;      
            
            end case;
            
     
            
            
               
            end if;
            end if;
            end process;
	-- User logic ends

end arch_imp;
