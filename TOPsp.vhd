----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.VGA_PKG.ALL; 
use WORK.DCSE_PKG.ALL;
use WORK.IMG_PKG.ALL; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TOPsp is
  Port ( clk : in STD_LOGIC;
         rst : in STD_lOGIC;
         red : out STD_LOGIC_VECTOR (c_nb_red-1 downto 0);
         blue : out STD_LOGIC_VECTOR (c_nb_blue-1 downto 0);
         green : out STD_LOGIC_VECTOR (c_nb_green-1 downto 0);         
         vsynch : out STD_LOGIC;
         hsynch : out STD_LOGIC
--                  hsynch : out STD_lOGIC;
--         addr2 : out STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0);
--         dout1_3x3 : in std_logic_vector (7 downto 0);
--         doutb : out std_logic_vector (7 downto 0);
--         dout2 : in STD_LOGIC;
--         wea : out STD_LOGIC;
--         fincuenta : out STD_LOGIC;
--         addrb: in STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0)     
  );
end TOPsp;

Architecture Structural of TOPsp is
    
Component CMPsp
    PORT (
        wea1 : out STD_LOGIC;
        rst : in STD_LOGIC;
        fin_vecindad : in STD_LOGIC;
        dout2 : in STD_LOGIC;
        --compara_hecho : in STD_LOGIC;
        clk: in STD_LOGIC;
        fin_compara : out STD_LOGIC;
        asigna : in STD_LOGIC;
        busca_hecho_maqestados : in STD_LOGIC;
        pixel_num_11x11 : in std_logic_vector (c_2dim_img - 1 downto 0);
        --addr3 : in STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0);
        addr_esc : out STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0);
        dout1_3x3 : in std_logic_vector (7 downto 0);
        pxl_dout3_3x3 : in std_logic_vector (7 downto 0));
    end Component;
    
Component BUSCAsp
    PORT (
               compara_hecho : out STD_LOGIC;
               fin_vecindad : out STD_LOGIC;
               busca_hecho_maqestados : in STD_LOGIC;
               pixel_num_11x11 : out std_logic_vector (c_2dim_img - 1 downto 0);
               espera_ciclo : in STD_LOGIC;
               busca_hecho : out STD_LOGIC;
               busca1_hecho_maqestados : in STD_LOGIC;
               busca1_hecho : out STD_LOGIC;
               para_vecindad: in STD_LOGIC; --Señal que para el contador de la vecindad 11x11 en cada pixel para hacer su parche 3x3
               para_vecindad_maqestados: out STD_LOGIC;
               addr3 : in STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0);
               addr1 : in STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0);
               addr1_3x3 : out STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0);
               pxl_num_3x3 : out STD_LOGIC_VECTOR (c_2dim_img-1 downto 0);
               clk: in STD_LOGIC;
               rst: in STD_LOGIC;
               compara : in STD_LOGIC);        
    end Component;
    
Component PNEGsp
    PORT (
        rst : in STD_LOGIC;
        wea : out STD_LOGIC;
        clk : in STD_LOGIC;
        dout2 : in STD_LOGIC;
--        fincuenta : out STD_LOGIC;
        addr2 : out STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0); --Cambiado para poder hacer el tb
        addr1 : out STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0);
        addr3 : out STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0);
        para_contador : in STD_LOGIC);
    end Component;
    
Component MAQsp
    PORT (
        rst : in STD_LOGIC;
               clk : in STD_LOGIC;
               dout2 : in STD_LOGIC;
               fin_compara : in STD_LOGIC;
               busca1_hecho : in STD_LOGIC;
               asigna : out STD_LOGIC;
               busca_hecho : in STD_LOGIC;
               para_vecindad_maqestados : in STD_LOGIC;
               compara_hecho : in STD_LOGIC;
               fin_vecindad : in STD_LOGIC;
               compara : out STD_LOGIC;
               espera_ciclo : out STD_LOGIC;
               para_vecindad : out STD_LOGIC;
               busca1_hecho_maqestados : out STD_LOGIC;
               busca_hecho_maqestados : out STD_LOGIC;
               para_contador : out STD_LOGIC);
    end Component;
    
Component RAMsp
port( 
    clk : in std_logic;
    wea : in std_logic;
    wea1 : in std_logic;
    addra : in std_logic_vector(c_2dim_img-1 downto 0);
    addr3 : in std_logic_vector(c_2dim_img-1 downto 0);
    addrb : in std_logic_vector(c_2dim_img-1 downto 0);
    dina : in std_logic_vector(8-1 downto 0);
--    douta : out std_logic_vector(8-1 downto 0);
    doutb : out std_logic_vector(8-1 downto 0)
    );
END COMPONENT;

COMPONENT R3_sp
port (
    clk  : in  std_logic;   -- reloj
    addr3 : in  std_logic_vector(c_2dim_img-1 downto 0); --16-1
    dout3 : out std_logic_vector(8-1 downto 0); 
    addr_x : in std_logic_vector (c_2dim_img-1 downto 0);
    dout_x: out std_logic_vector(8-1 downto 0); 
    
    addr_esc : in std_logic_vector(c_2dim_img-1 downto 0);
    dout_esc : out std_logic_vector(8-1 downto 0)
  );
END COMPONENT;

Component ROM2sp 
port (
    clk  : in  std_logic;   -- reloj
    addr2 : in  std_logic_vector(c_2dim_img-1 downto 0);
    dout2 : out std_logic 
  );
END COMPONENT;

Component PINTA_IMG
port (
        -- In ports
visible      : in std_logic;
pxl_num      : in std_logic_vector(c_nb_pxls-1 downto 0);
line_num     : in std_logic_vector(c_nb_lines-1 downto 0);
datmem1      : in STD_LOGIC_VECTOR (7 downto 0);
datmem3      : in STD_LOGIC_VECTOR (7 downto 0);

--  datmen       : in std_logic;
-- Out ports
dirmem1      : out STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0); --18 -1?? c_2dim_img??
dirmem3      : out STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0);
red          : out std_logic_vector(c_nb_red-1 downto 0);
green        : out std_logic_vector(c_nb_green-1 downto 0);
blue         : out std_logic_vector(c_nb_blue-1 downto 0)
);
END COMPONENT;

Component R1sp
port(
    clk  : in  std_logic;   -- reloj    
    addr1 : in  std_logic_vector(c_2dim_img-1 downto 0);
    dout1 : out std_logic_vector(8-1 downto 0) 
);
END COMPONENT;

Component VGA_sincro
port (
clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           hsynch : out STD_LOGIC;
           vsynch : out STD_LOGIC;
           visible : out STD_LOGIC;
           line_num : out STD_LOGIC_VECTOR (c_nb_lines-1 downto 0); -- 9 downto 0
           pxl_num : out STD_LOGIC_VECTOR (c_nb_pxls-1 downto 0)); 
END COMPONENT;
-------------------------------------------------------------------------------------

signal c_addr1, c_addr2, c2_addr3, c2_addr1, c_addr3, c_addrb, c_pxl_num_11x11, c_addr_esc, c_addr_x: STD_LOGIC_VECTOR (c_2dim_img - 1 downto 0);
signal c_dout3, c_dout_esc, c_doutb, c_dout1, c_dout_x: STD_LOGIC_VECTOR (7 downto 0);
signal c_para_contador, c_compara, c_wea, c_wea1, c_fin_compara, c_compara_hecho, c_para_vecindad, c_busca1_hecho, c_busca_hecho, c_para_maq, c_busca, c_busca1, c_fin_vecindad, c_espera_ciclo, c_asigna, c_dout2, visible : STD_LOGIC;
signal line_num: STD_LOGIC_VECTOR (9 downto 0);
signal pxl_num: STD_LOGIC_VECTOR (9 downto 0);



--------------------------------------------------------------------------------------

begin

PNEG: PNEGsp
Port map(
    clk => clk,
    rst => rst,
    wea => c_wea,
    dout2 => c_dout2,
    para_contador => c_para_contador,
    addr1 => c2_addr1,
    addr2 => c_addr2,
    addr3 => c2_addr3
--    fincuenta => fincuenta
    );
    
BUSCA: BUSCAsp
Port map(
    clk => clk,
    rst => rst,
    pixel_num_11x11 => c_pxl_num_11x11,
    addr1 => c2_addr1,
    addr3 => c2_addr3,
    espera_ciclo => c_espera_ciclo,
    compara => c_compara,
    addr1_3x3 => c_addr1,
    pxl_num_3x3 => c_addr3,
    compara_hecho => c_compara_hecho,
    para_vecindad => c_para_vecindad,
    busca_hecho_maqestados => c_busca,
    busca1_hecho_maqestados => c_busca1,
    fin_vecindad => c_fin_vecindad,
    para_vecindad_maqestados => c_para_maq,
    busca_hecho => c_busca_hecho,
    busca1_hecho => c_busca1_hecho
    );
    
CMP: CMPsp
Port map(
    
    dout1_3x3 => c_dout1,
    rst => rst,
    dout2 => c_dout2,
    fin_vecindad => c_fin_vecindad,
    --compara_hecho => c_compara_hecho,
    clk => clk,
    asigna => c_asigna,
    pxl_dout3_3x3 => c_dout3,
    pixel_num_11x11 => c_pxl_num_11x11,
    busca_hecho_maqestados => c_busca,
    fin_compara => c_fin_compara,
    addr_esc => c_addr_esc,
    wea1 => c_wea1
    );

    
MAQ: MAQsp
Port map(
    dout2 => c_dout2,
    fin_compara => c_fin_compara,
    clk => clk,
    rst => rst,
    asigna => c_asigna,
    espera_ciclo => c_espera_ciclo,
    para_contador => c_para_contador,
    compara => c_compara,
    busca1_hecho => c_busca1_hecho,
    para_vecindad_maqestados => c_para_maq,
    busca_hecho => c_busca_hecho,
    compara_hecho => c_compara_hecho,
    fin_vecindad => c_fin_vecindad,
    para_vecindad => c_para_vecindad,
    busca1_hecho_maqestados => c_busca1,
    busca_hecho_maqestados => c_busca
    );
    
RAM1: RAMsp
Port map(
    addra => c_addr_esc,
    wea => c_wea,
    wea1 => c_wea1,
    dina => c_dout_esc,
    addrb => c_addrb,
    addr3 => c2_addr3,
    doutb => c_doutb,
    clk => clk
    );
    
ROM3: R3_sp
Port map(
    addr3 => c_addr3,
    dout3 => c_dout3,
    addr_esc => c_addr_esc,
    dout_esc => c_dout_esc,
    clk => clk,
    addr_x => c_addr_x,
    dout_x => c_dout_x
    );

R2: ROM2sp
Port map(
    clk => clk,
    dout2 => c_dout2,
    addr2 => c_addr2
    );
    
ROM1: R1sp
Port map(
    addr1 => c_addr1, 
    dout1 => c_dout1,
    clk => clk
    );
    
PINTA: PINTA_IMG
Port map(
    datmem1 => c_doutb,
    datmem3 => c_dout_x,
    dirmem1 => c_addrb,
    dirmem3 => c_addr_x,
    red => red,
    green => green,
    blue => blue,
    pxl_num => pxl_num,
    line_num => line_num,
    visible => visible
    );
    
VGA: VGA_sincro 
       PORT MAP (
             vsynch => vsynch,
             CLK => CLK,
             RST => RST,
             hsynch => hsynch,
             visible => visible,
             line_num => line_num,
             pxl_num => pxl_num
           );

end Structural;