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
--         SW : in STD_LOGIC;
         red : out STD_LOGIC_VECTOR (c_nb_red-1 downto 0);
         blue : out STD_LOGIC_VECTOR (c_nb_blue-1 downto 0);
         green : out STD_LOGIC_VECTOR (c_nb_green-1 downto 0);         
         vsynch : out STD_LOGIC;
         hsynch : out STD_LOGIC;
		 led0 : out STD_LOGIC;
		 led1 : out STD_LOGIC;
		 led2 : out STD_LOGIC;
		 led3 : out STD_LOGIC;
		 led4 : out STD_LOGIC;
		 led5 : out STD_LOGIC;
		 led6 : out STD_LOGIC;
		 led7 : out STD_LOGIC;
		 led8 : out STD_LOGIC;
		 led9 : out STD_LOGIC;
		 led10 : out STD_LOGIC;
		 led11 : out STD_LOGIC;
		 led12 : out STD_LOGIC;
		 led13 : out STD_LOGIC;
		 led14 : out STD_LOGIC;
		 led15 : out STD_LOGIC
  );
end TOPsp;

Architecture Structural of TOPsp is
    
Component CMPsp
    PORT (compara_hecho : out STD_LOGIC; --Señal que indica que se han comparado los parches 3x3 (el parche de la ROM1 con el parche de la ROM3)
        busca_hecho_maqestados : in STD_LOGIC; --Señal que activa la comparación (resta) del pixel de la ROM1 con el pixel de la ROM3
        rst : in STD_LOGIC;
        dout2 : in STD_LOGIC; --Valor del pxl de la R2
        clk: in STD_LOGIC;
		--led8 : out STD_LOGIC;
        wea1 : out STD_LOGIC; --Señal que indica la escritura en la RAM (imagen procesada)
        fin_compara : out STD_LOGIC; --Señal que indica se ha terminado de comparar dos pixeles (ROM1 con ROM3) dentro de un mismo parche
        fin_vecindad : in STD_LOGIC; --Señal que indica que se ha terminado la vecindad 11x11 de un pixel de la ROM3
        asigna : in STD_LOGIC; --Señal que suma +1 en los dos contadores de pixeles de los parches 3x3 de ROM1 y ROM3 ya que se han comparado entre ellos
        addr_esc : out STD_LOGIC_VECTOR (c_dim_img - 1 downto 0); --Dirección de memoria a escribir en la RAM
        dout1_3x3 : in STD_LOGIC; --Valor del pixel de la ROM1
        pxl_num_3x3 : in std_logic_vector (c_dim_img - 1 downto 0); --Direción de memoria del pixel del parche 3x3 de la ROM3 dentro de su vecindad
        pxl_dout3_3x3 : in STD_LOGIC --Valor del pixel del parche 3x3 de la ROM3
		);
    end Component;
    
Component BUSCAsp
    PORT (fin_vecindad : out STD_LOGIC; --Señal que indica que se ha terminado la vecindad 11x11 de un pixel de la ROM3
        espera_ciclo : in STD_LOGIC; --Señal que activa el contador del parche 3x3 del pixel de la vecindad 11x11 de la ROM3
        busca_hecho : out STD_LOGIC; --Señal que indica que se ha encontrado un pixel del parche 3x3 de la ROM3
        busca1_hecho_maqestados : in STD_LOGIC; --Señal que para el contador del parche 3x3 en cada pixel para su procesamiento
        busca1_hecho : out STD_LOGIC; --Señal que indica que se ha encontrado un pixel del parche 3x3 de la ROM1
        para_vecindad: in STD_LOGIC; --Señal que para el contador de la vecindad 11x11 en cada pixel para hacer su parche 3x3
        para_vecindad_maqestados: out STD_LOGIC; --Señal que indica que se ha encontrado un pixel de la vecindad 11x11 de la ROM3
        addr3 : in STD_LOGIC_VECTOR (c_dim_img - 1 downto 0); --Dirección de memoria que indica el pixel de la R2 y va a la ROM3
        addr1 : in STD_LOGIC_VECTOR (c_dim_img - 1 downto 0); --Dirección de memoria que indica el pixel de la R2 y va a la ROM1
        addr1_3x3 : out STD_LOGIC_VECTOR (c_dim_img - 1 downto 0); --Direción de memoria del pixel del parche 3x3 de la ROM1
        pxl_num_3x3 : out STD_LOGIC_VECTOR (c_dim_img-1 downto 0); --Direción de memoria del pixel del parche 3x3 de la ROM3 dentro de su vecindad
        clk: in STD_LOGIC;
        rst: in STD_LOGIC;
--		asigna : in STD_LOGIC; --Señal que suma +1 en los dos contadores de pixeles de los parches 3x3 de ROM1 y ROM3 ya que se han comparado entre ellos
        compara : in STD_LOGIC); --Señal que activa el contador de pixeles del parche 3x3 de la ROM1 y de la vecindad 11x11 de la ROM3      
    end Component;
    
Component PNEGsp
    PORT (
        rst : in STD_LOGIC;
        clk : in STD_LOGIC;
        dout2 : in STD_LOGIC; --Valor del pxl de la R2
        fin_img : out STD_lOGIC; --Señal que indica que se ha terminado de recorrer la R2
        addr2 : out STD_LOGIC_VECTOR (c_dim_img - 1 downto 0); --Dirección de memoria de la cuenta de pixeles de la R2, que entra en R2
        addr1 : out STD_LOGIC_VECTOR (c_dim_img - 1 downto 0); --Dirección de memoria de la cuenta de pixeles de la R2, que entra en ROM1
        addr3 : out STD_LOGIC_VECTOR (c_dim_img - 1 downto 0); --Dirección de memoria de la cuenta de pixeles de la R2, que entra en ROM3
        para_contador : in STD_LOGIC); --Señal que viene de la máquina de estados e indica que se ha encontrado un pixel negro de la R2, parando así el contador de pixeles de la R2
    end Component;
    
Component MAQsp
    PORT (
        rst : in STD_LOGIC;
        clk : in STD_LOGIC;
        dout2 : in STD_LOGIC; --Valor del pxl de la R2
        fin_compara : in STD_LOGIC; --Señal que indica se ha terminado de comparar dos pixeles (ROM1 con ROM3) dentro de un mismo parche
        busca1_hecho : in STD_LOGIC; --Señal que indica que se ha encontrado un pixel del parche 3x3 de la ROM1
        busca_hecho : in STD_LOGIC; --Señal que indica que se ha encontrado un pixel del parche 3x3 de la ROM3
        para_vecindad_maqestados : in STD_LOGIC; --Señal que indica que se ha encontrado un pixel de la vecindad 11x11 de la ROM3
        compara_hecho : in STD_LOGIC; --Señal que indica que se han comparado los parches 3x3 (el parche de la ROM1 con el parche de la ROM3)
        fin_img : in STD_lOGIC; --Señal que indica que se ha terminado de recorrer la R2
        fin_vecindad : in STD_LOGIC; --Señal que indica que se ha terminado la vecindad 11x11 de un pixel de la ROM3
        --fin_imagen : out STD_LOGIC; --Fin del procesado y que pinta la imagen procesada
        compara : out STD_LOGIC; --Señal que activa el contador de pixeles del parche 3x3 de la ROM1 y de la vecindad 11x11 de la ROM3
        para_vecindad : out STD_LOGIC; --Señal que para el contador de la vecindad 11x11 en cada pixel para hacer su parche 3x3
        busca1_hecho_maqestados : out STD_LOGIC; --Señal que para el contador del parche 3x3 en cada pixel para su procesamiento
        espera_ciclo : out STD_LOGIC; --Señal que activa el contador del parche 3x3 del pixel de la vecindad 11x11 de la ROM3
        asigna : out STD_LOGIC; --Señal que suma +1 en los dos contadores de pixeles de los parches 3x3 de ROM1 y ROM3 ya que se han comparado entre ellos (modulo CMP)
        busca_hecho_maqestados : out STD_LOGIC; --Señal que activa la comparación (resta) del pixel de la ROM1 con el pixel de la ROM3
        para_contador : out STD_LOGIC;  --Señal que indica que se ha encontrado un pixel negro de la R2, parando así el contador de pixeles de la R2
		-----Señales LED para saber en que estado nos encontramos en cada momento-----------------------------------------
		led0 : out STD_LOGIC; --ESPERA
		led1 : out STD_LOGIC; --CICLORLJ
		led2 : out STD_LOGIC; --PARA
		led3 : out STD_LOGIC; --RESTA
		led4 : out STD_LOGIC; --COMPARA2
		led5 : out STD_LOGIC; --PINTA
		led6 : out STD_LOGIC; --COMPRUEBA
		led7 : out STD_LOGIC; --INIC
		led8 : out STD_LOGIC;
		led9 : out STD_LOGIC;
		led10 : out STD_LOGIC;
		led11 : out STD_LOGIC;
		led12 : out STD_LOGIC;
		led13 : out STD_LOGIC;
		led14 : out STD_LOGIC;
		led15 : out STD_LOGIC
		);
    end Component;
    
Component RAMsp
	port( 
		clk : in std_logic;
		wea1 : in std_logic; --Señal que indica la escritura en la RAM (imagen procesada)
		addra : in std_logic_vector(16-1 downto 0); --Dirección de memoria a escribir en la RAM. Direccion del pixel comparado que supera el umbral de parecido.
		addrb : in std_logic_vector(16-1 downto 0); --Direccion de memoria para pintar la imagen procesada en la VGA
		dina : in std_logic; --Valor del pixel comparado que supera el umbral de parecido para escrbirlo en la RAM
		doutb : out std_logic --Valor del pixel para pintar la imagen procesada en la VGA
		);
	END COMPONENT;

COMPONENT ROM8b_mri1_bn
	port (
		clk  : in  std_logic;   
		addr_x : in std_logic_vector (c_dim_img-1 downto 0); --Dirección de memoria que pinta la ROM3 sin procesar
		dout_x: out std_logic --Valor del pixel que se pinta de la ROM3 sin procesar
	  );
	END COMPONENT;

COMPONENT ROM8b_mri1_bn_copia
	port (
		clk  : in  std_logic;   
		addr3 : in  std_logic_vector(c_dim_img-1 downto 0); --Direción de memoria del pixel del parche 3x3 de la ROM3 dentro de su vecindad
		dout3 : out std_logic; --Valor del pixel del parche 3x3 de la ROM3
		addr_pinta : in std_logic_vector (c_dim_img-1 downto 0); --Dirección del pixel comparado a pintar
		dout_pinta : out std_logic --Valor del pixel comparado a pintar
		);
	END COMPONENT;

Component ROM2sp 
	port (
		clk  : in  std_logic;   
		addr2 : in  std_logic_vector(c_dim_img-1 downto 0); --Dirección de memoria de los pixeles de la R2
		dout2 : out std_logic --Valor del pxl de la R2
	  );
	END COMPONENT;

Component PINTA_IMG
	port (
	visible      : in std_logic;
	--SW : in STD_LOGIC;
	pxl_num      : in std_logic_vector(c_nb_pxls-1 downto 0);
	line_num     : in std_logic_vector(c_nb_lines-1 downto 0);
	datmem1      : in STD_LOGIC; --Valor de los pixeles de la imagen procesada (RAM)
	datmem3      : in STD_LOGIC; --Valor de los pixeles de la ROM3 sin procesar
	--fin_imagen : in STD_LOGIC;
	dirmem1      : out STD_LOGIC_VECTOR (c_dim_img - 1 downto 0); --Dirección de memoria de los pixeles de la imagen procesada (RAM)
	dirmem3      : out STD_LOGIC_VECTOR (c_dim_img - 1 downto 0); --Dirección de memoria de los pixeles de la ROM3 sin procesar
	red          : out std_logic_vector(c_nb_red-1 downto 0);
	green        : out std_logic_vector(c_nb_green-1 downto 0);
	blue         : out std_logic_vector(c_nb_blue-1 downto 0)
	);
	END COMPONENT;

Component R1sp
	port(
		clk  : in  std_logic;      
		addr1 : in  std_logic_vector(c_dim_img-1 downto 0);
		dout1 : out std_logic
	);
	END COMPONENT;

Component VGA_sincro
	port (
		clk : in STD_LOGIC;
		rst : in STD_LOGIC;
		hsynch : out STD_LOGIC;
		vsynch : out STD_LOGIC;
		visible : out STD_LOGIC;
		line_num : out STD_LOGIC_VECTOR (c_nb_lines-1 downto 0);
		pxl_num : out STD_LOGIC_VECTOR (c_nb_pxls-1 downto 0)); 
	END COMPONENT;
-------------------------------------------------------------------------------------
signal c_addr1, c_addr2, c2_addr3, c2_addr1, c_addr3: STD_LOGIC_VECTOR (c_dim_img - 1 downto 0);
signal c_addr_x, c_addrb, c_addr_pinta: STD_LOGIC_VECTOR (c_dim_img - 1 downto 0);
signal c_dout3, c_doutb, c_dout1, c_dout_x, c_dout11, c_dout_pinta: STD_LOGIC;
signal c_para_contador, c_compara, c_wea, c_wea1, c_fin_compara, c_compara_hecho, c_para_vecindad, c_busca1_hecho, c_busca_hecho, c_para_maq, c_busca, c_busca1, c_fin_vecindad, c_espera_ciclo, c_asigna, c_dout2, visible, c_fin_img : STD_LOGIC;
signal line_num: STD_LOGIC_VECTOR (c_nb_lines-1 downto 0);
signal pxl_num: STD_LOGIC_VECTOR (c_nb_pxls-1 downto 0);
--------------------------------------------------------------------------------------

begin

PNEG: PNEGsp
Port map(
    clk => clk,
    rst => rst,
    dout2 => c_dout2, --Valor del pxl de la R2
    fin_img => c_fin_img, --Señal que indica que se ha terminado de recorrer la R2
    para_contador => c_para_contador, --Señal que viene de la máquina de estados e indica que se ha encontrado un pixel negro de la R2, parando así el contador de pixeles de la R2
    addr1 => c2_addr1, --Dirección de memoria de la cuenta de pixeles de la R2, que entra en ROM1
    addr2 => c_addr2, --Dirección de memoria de la cuenta de pixeles de la R2, que entra en R2
    addr3 => c2_addr3 --Dirección de memoria de la cuenta de pixeles de la R2, que entra en ROM3
    );
    
BUSCA: BUSCAsp
Port map(
    clk => clk,
    rst => rst,
    addr1 => c2_addr1, --Dirección de memoria que indica el pixel de la R2 y va a la ROM1
    addr3 => c2_addr3, --Dirección de memoria que indica el pixel de la R2 y va a la ROM3
    espera_ciclo => c_espera_ciclo, --Señal que activa el contador del parche 3x3 del pixel de la vecindad 11x11 de la ROM3
    compara => c_compara, --Señal que activa el contador de pixeles del parche 3x3 de la ROM1 y de la vecindad 11x11 de la ROM3
    addr1_3x3 => c_addr1, --Direción de memoria del pixel del parche 3x3 de la ROM1--Direción de memoria del pixel del parche 3x3 de la ROM1
    pxl_num_3x3 => c_addr3, --Direción de memoria del pixel del parche 3x3 de la ROM3 dentro de su vecindad
    para_vecindad => c_para_vecindad, --Señal que para el contador de la vecindad 11x11 en cada pixel para hacer su parche 3x3
    busca1_hecho_maqestados => c_busca1, --Señal que para el contador del parche 3x3 en cada pixel para su procesamiento
--    asigna => c_asigna, --Señal que suma +1 en los dos contadores de pixeles de los parches 3x3 de ROM1 y ROM3 ya que se han comparado entre ellos
    fin_vecindad => c_fin_vecindad, --Señal que indica que se ha terminado la vecindad 11x11 de un pixel de la ROM3
    para_vecindad_maqestados => c_para_maq, --Señal que indica que se ha encontrado un pixel de la vecindad 11x11 de la ROM3
    busca_hecho => c_busca_hecho, --Señal que indica que se ha encontrado un pixel del parche 3x3 de la ROM3
    busca1_hecho => c_busca1_hecho --Señal que indica que se ha encontrado un pixel del parche 3x3 de la ROM1
    );
    
CMP: CMPsp
Port map(  
    dout1_3x3 => c_dout1, --Valor del pixel de la ROM1
    rst => rst,
	--led8 => led8,
    dout2 => c_dout2, --Valor del pxl de la R2
    fin_vecindad => c_fin_vecindad, --Señal que indica que se ha terminado la vecindad 11x11 de un pixel de la ROM3
    compara_hecho => c_compara_hecho, --Señal que indica que se han comparado los parches 3x3 (el parche de la ROM1 con el parche de la ROM3)
    clk => clk,
    asigna => c_asigna, --Señal que suma +1 en los dos contadores de pixeles de los parches 3x3 de ROM1 y ROM3 ya que se han comparado entre ellos
    pxl_dout3_3x3 => c_dout3, --Valor del pixel del parche 3x3 de la ROM3
    pxl_num_3x3 => c_addr3, --Direción de memoria del pixel del parche 3x3 de la ROM3 dentro de su vecindad
    busca_hecho_maqestados => c_busca, --Señal que activa la comparación (resta) del pixel de la ROM1 con el pixel de la ROM3
    fin_compara => c_fin_compara, --Señal que indica se ha terminado de comparar dos pixeles (ROM1 con ROM3) dentro de un mismo parche
    addr_esc => c_addr_pinta, --Dirección de memoria a escribir en la RAM
    wea1 => c_wea1 --Señal que indica la escritura en la RAM (imagen procesada)
    );

MAQ: MAQsp
Port map(
    dout2 => c_dout2, --Valor del pxl de la R2
    fin_compara => c_fin_compara, --Señal que indica se ha terminado de comparar dos pixeles (ROM1 con ROM3) dentro de un mismo parche
    clk => clk,
    rst => rst,
    asigna => c_asigna, --Señal que suma +1 en los dos contadores de pixeles de los parches 3x3 de ROM1 y ROM3 ya que se han comparado entre ellos (modulo CMP)
    espera_ciclo => c_espera_ciclo, --Señal que activa el contador del parche 3x3 del pixel de la vecindad 11x11 de la ROM3
    para_contador => c_para_contador, --Señal que indica que se ha encontrado un pixel negro de la R2, parando así el contador de pixeles de la R2
    compara => c_compara, --Señal que activa el contador de pixeles del parche 3x3 de la ROM1 y de la vecindad 11x11 de la ROM3
    busca1_hecho => c_busca1_hecho, --Señal que indica que se ha encontrado un pixel del parche 3x3 de la ROM1
    para_vecindad_maqestados => c_para_maq, --Señal que indica que se ha encontrado un pixel de la vecindad 11x11 de la ROM3
    busca_hecho => c_busca_hecho, --Señal que indica que se ha encontrado un pixel del parche 3x3 de la ROM3
    fin_img => c_fin_img, --Señal que indica que se ha terminado de recorrer la R2
--    fin_imagen => fin_img, --Fin del procesado y que pinta la imagen procesada
    compara_hecho => c_compara_hecho, --Señal que indica que se han comparado los parches 3x3 (el parche de la ROM1 con el parche de la ROM3)
    fin_vecindad => c_fin_vecindad, --Señal que indica que se ha terminado la vecindad 11x11 de un pixel de la ROM3
    para_vecindad => c_para_vecindad, --Señal que para el contador de la vecindad 11x11 en cada pixel para hacer su parche 3x3
    busca1_hecho_maqestados => c_busca1, --Señal que para el contador del parche 3x3 en cada pixel para su procesamiento
    busca_hecho_maqestados => c_busca, --Señal que activa la comparación (resta) del pixel de la ROM1 con el pixel de la ROM3
	-----Señales LED para saber en que estado nos encontramos en cada momento-----------------------------------------
	led0 => led0, --ESPERA
	led1 => led1, --CICLORLJ
	led2 => led2, --PARA
	led3 => led3, --RESTA
	led4 => led4, --COMPARA2
	led5 => led5, --PINTA
	led6 => led6, --COMPRUEBA
	led7 => led7, --INIC
	led8 => led8,
	led9 => led9,
	led10 => led10,
	led11 => led11,
	led12 => led12,
	led13 => led13,
	led14 => led14,
	led15 => led15
    );
    
RAM1: RAMsp
Port map(
    addra => c_addr_pinta, --Dirección del pixel central del parche. Dirección del pixel comparado a pintar
    wea1 => c_wea1, --Señal que indica la escritura en la RAM (imagen procesada)
    dina => c_dout_pinta, --Valor del pixel central del parche. Valor del pixel comparado a pintar
    addrb => c_addrb, --Direccion de memoria para pintar la imagen procesada en la VGA
    doutb => c_doutb, --Valor del pixel para pintar la imagen procesada en la VGA
    clk => clk
    );
    
ROM3: ROM8b_mri1_bn
Port map(
    clk => clk,
    addr_x => c_addr_x, --Dirección de memoria que pinta la ROM3 sin procesar
    dout_x => c_dout_x --Valor del pixel que se pinta de la ROM3 sin procesar
    );
    
ROM3_copia: ROM8b_mri1_bn_copia
Port map(
    clk => clk,
    addr3 => c_addr3, --Direción de memoria del pixel del parche 3x3 de la ROM3 dentro de su vecindad
    dout3 => c_dout3, --Valor del pixel del parche 3x3 de la ROM3
    addr_pinta => c_addr_pinta, --Dirección del pixel comparado a pintar
    dout_pinta => c_dout_pinta --Valor del pixel comparado a pintar
    );

R2: ROM2sp
Port map(
    clk => clk,
    dout2 => c_dout2, --Valor del pxl de la R2
    addr2 => c_addr2 --Dirección de memoria de los pixeles de la R2
    );
    
ROM1: R1sp
Port map(
    addr1 => c_addr1, 
    dout1 => c_dout1,
    clk => clk
    );
    
PINTA: PINTA_IMG
Port map(
    datmem1 => c_doutb, --Valor de los pixeles de la imagen procesada (RAM)
    datmem3 => c_dout_x, --Valor de los pixeles de la ROM3 sin procesar
    dirmem1 => c_addrb, --Dirección de memoria de los pixeles de la imagen procesada (RAM)
    dirmem3 => c_addr_x, --Dirección de memoria de los pixeles de la ROM3 sin procesar
--    fin_imagen => fin_img, --Fin del procesado y que pinta la imagen procesada
    red => red,
    green => green,
    blue => blue,
    pxl_num => pxl_num,
    line_num => line_num,
    visible => visible
--    SW => SW
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