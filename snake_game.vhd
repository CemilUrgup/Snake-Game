library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
 
entity snake_game is
    generic(HorizontalVisibleArea : natural := 1440; --Zamanlama Parametreleri
        HorizontalFrontPorch : natural := 80;
        HorizontalSyncPulse : natural := 152;
        HorizontalBackPorch : natural := 232;
        VerticalVisibleArea : natural := 900;
        VerticalFrontPorch : natural := 1;
        VerticalSyncPulse : natural := 3;
        VerticalBackPorch : natural := 28;  
        HorizontalSyncPolarity : std_logic := '1';   --Sync Polariteleri
        VerticalSyncPolarity : std_logic := '1';
        RGBLength : integer := 4);                                                                                    
    port(clk, Enable : in std_logic;             --Pixel Clock ve Enable Girişi
        red_0: out std_logic := '0';
        red_1: out std_logic := '0';
        red_2: out std_logic := '0';
        red_3: out std_logic := '0';
        blue_0: out std_logic := '0';
        blue_1: out std_logic := '0';
        blue_2: out std_logic := '0';
        blue_3: out std_logic := '0';
        green_0: out std_logic := '0';
        green_1: out std_logic := '0';
        green_2: out std_logic := '0';
        green_3  : out std_logic;        --RGB Çıkışları
        HSync, VSync : out std_logic := '0'; --HSync ve VSync Çıkışı
        up_button, down_button: in std_logic;
        left_button, right_button: in std_logic;
        snake_height_button: in std_logic                              
        ); --Buffer Data Girişi
end snake_game;
 
architecture Behavioral of snake_game is
     
    --Toplam yatay pixel
    constant HorizontalWholeLine : integer := HorizontalVisibleArea + HorizontalFrontPorch + HorizontalSyncPulse + HorizontalBackPorch;
    --Toplam dikey pixel
    constant VerticalWholeLine : integer := VerticalVisibleArea + VerticalFrontPorch + VerticalSyncPulse + VerticalBackPorch;
    
    signal HCount : natural range 0 to HorizontalWholeLine - 1 := 0;
    signal VCount : natural range 0 to VerticalWholeLine - 1 := 0;
    signal HPulse, VPulse : std_logic := '0';
    signal HVisible, VVisible : std_logic :='0';
    signal BufferData: std_logic_vector(RGBLength * 3 - 1 downto 0) := "111100000000";
    signal counter: integer := 0;
    signal Red, Green, Blue: unsigned (RGBLength - 1 downto 0);
    type matrix_data1 is array (integer range 0 to 15) of std_logic_vector(11 downto 0);
    type matrix_data2 is array (integer range 0 to 9) of matrix_data1;
    signal matrix: matrix_data2 := (others => (others => X"000"));
    signal i: natural := 0;
    signal j: integer := 0;
    signal up1, up2, down1, down2, left1, left2, right1, right2: std_logic;
    type direction_type is (right, left, up, down);
    signal direction: direction_type := right;
    signal slow_clk: std_logic := '0';
    signal snake_height: integer := 3;
    type snake_3_data_j is array (integer range 0 to 2) of integer;
    signal snake_3_j: snake_3_data_j := (others => 0);
    type snake_3_data_i is array (integer range 0 to 2) of integer;
    signal snake_3_i: snake_3_data_i := (others => 0);
    type snake_4_data_j is array (integer range 0 to 3) of integer;
    signal snake_4_j: snake_4_data_j := (others => 0);
    type snake_4_data_i is array (integer range 0 to 3) of integer;
    signal snake_4_i: snake_4_data_i := (others => 0);
    type snake_5_data_j is array (integer range 0 to 4) of integer;
    signal snake_5_j: snake_5_data_j := (others => 0);
    type snake_5_data_i is array (integer range 0 to 4) of integer;
    signal snake_5_i: snake_5_data_i := (others => 0);
    signal height1, height2: std_logic;
     
begin
process(clk,slow_clk,height2)
begin
---------------------------------------------------
if rising_edge(clk) then
    
up1 <= up_button;
up2 <= not up1 and up_button;

down1 <= down_button;
down2 <= not down1 and down_button;

left1 <= left_button;
left2 <= not left1 and left_button;

right1 <= right_button;
right2 <= not right1 and right_button;

height1 <= snake_height_button;
height2 <= height1;
    
    if up2 = '1' and direction /= down then
        direction <= up;
    end if;
    if down2 = '1' and direction /= up then
        direction <= down;
    end if;
    if left2 = '1' and direction /= right then
        direction <= left;
    end if;
    if right2 = '1' and direction /= left then
        direction <= right;
    end if;
end if;
--------------------------------------------------------
if rising_edge(height2) then
    snake_height <= snake_height + 1;
end if;

if rising_edge(clk) then

    if snake_height = 3 then
        matrix <= (others => (others => X"000"));
        matrix(snake_3_i(0) mod 10)(snake_3_j(0) mod 16) <= X"EE2";
        matrix(snake_3_i(1) mod 10)(snake_3_j(1) mod 16) <= X"EE2";
        matrix(snake_3_i(2) mod 10)(snake_3_j(2) mod 16) <= X"EE2";
    elsif snake_height = 4 then
        matrix <= (others => (others => X"000"));
        matrix(snake_4_i(0) mod 10)(snake_4_j(0) mod 16) <= X"EE2";
        matrix(snake_4_i(1) mod 10)(snake_4_j(1) mod 16) <= X"EE2";
        matrix(snake_4_i(2) mod 10)(snake_4_j(2) mod 16) <= X"EE2";
        matrix(snake_4_i(3) mod 10)(snake_4_j(3) mod 16) <= X"EE2";
    elsif snake_height = 5 then
        matrix <= (others => (others => X"000")); 
        matrix(snake_5_i(0) mod 10)(snake_5_j(0) mod 16) <= X"EE2";
        matrix(snake_5_i(1) mod 10)(snake_5_j(1) mod 16) <= X"EE2";
        matrix(snake_5_i(2) mod 10)(snake_5_j(2) mod 16) <= X"EE2";
        matrix(snake_5_i(3) mod 10)(snake_5_j(3) mod 16) <= X"EE2";
        matrix(snake_5_i(4) mod 10)(snake_5_j(4) mod 16) <= X"EE2"; 
    else
        matrix <= (others => (others => X"000")); 
        matrix(snake_5_i(0) mod 10)(snake_5_j(0) mod 16) <= X"EE2";
        matrix(snake_5_i(1) mod 10)(snake_5_j(1) mod 16) <= X"EE2";
        matrix(snake_5_i(2) mod 10)(snake_5_j(2) mod 16) <= X"EE2";
        matrix(snake_5_i(3) mod 10)(snake_5_j(3) mod 16) <= X"EE2";
        matrix(snake_5_i(4) mod 10)(snake_5_j(4) mod 16) <= X"EE2";
    end if;
end if;

if rising_edge(clk) then
    if counter < 34999999 then
        counter <= counter + 1;
    else
        counter <= 0;
        slow_clk <= not slow_clk;
    end if;
    
end if;

if rising_edge(slow_clk) then

    case direction is
    
    when up => i <= i-1;
    when down => i <= i+1;
    when left => j <= j-1;
    when right => j <= j+1;

    end case;
    
    if snake_height = 3 then    
            
        snake_3_i <= i & snake_3_i (0 to 1);
        snake_3_j <= j & snake_3_j (0 to 1);
        snake_4_i <= i & snake_4_i (0 to 2);
        snake_4_j <= j & snake_4_j (0 to 2);
        snake_5_i <= i & snake_5_i (0 to 3);
        snake_5_j <= j & snake_5_j (0 to 3);
        
    elsif snake_height = 4 then
 
        snake_4_i <= i & snake_4_i (0 to 2);
        snake_4_j <= j & snake_4_j (0 to 2);
        snake_5_i <= i & snake_5_i (0 to 3);
        snake_5_j <= j & snake_5_j (0 to 3);
        
    elsif snake_height = 5 then
    
        snake_5_i <= i & snake_5_i (0 to 3);
        snake_5_j <= j & snake_5_j (0 to 3);
    
    else
      
        snake_5_i <= i & snake_5_i (0 to 3);
        snake_5_j <= j & snake_5_j (0 to 3);
            
    end if;

end if;


if rising_edge(clk) then
    
        if VCount < 90 then
                if Hcount < 90 then
                    BufferData <= matrix(0)(0);
                elsif HCount > 89 and Hcount < 180 then
                    BufferData <= matrix(0)(1);
                elsif HCount > 179 and Hcount <270 then
                    BufferData <= matrix(0)(2);
                elsif HCount > 269 and Hcount <360 then
                    BufferData <= matrix(0)(3);
                elsif HCount > 359 and Hcount <450 then
                    BufferData <= matrix(0)(4);
                elsif HCount > 449 and Hcount <540 then
                    BufferData <= matrix(0)(5);
                elsif HCount > 539 and Hcount <630 then
                    BufferData <= matrix(0)(6);
                elsif HCount > 629 and Hcount <720 then
                    BufferData <= matrix(0)(7);
                elsif HCount > 719 and Hcount <810 then
                    BufferData <= matrix(0)(8);
                elsif HCount > 809 and Hcount < 900 then
                    BufferData <= matrix(0)(9);
                elsif HCount > 899 and Hcount <990 then
                    BufferData <= matrix(0)(10);
                elsif HCount > 989 and Hcount <1080 then
                    BufferData <= matrix(0)(11);
                elsif HCount > 1079 and Hcount <1170 then
                    BufferData <= matrix(0)(12);
                elsif HCount > 1169 and Hcount <1260 then
                    BufferData <= matrix(0)(13);
                elsif HCount > 1259 and Hcount <1350 then
                    BufferData <= matrix(0)(14);
                else
                    BufferData <= matrix(0)(15);
                end if;
        elsif VCount > 89 and Vcount <180 then
                if Hcount < 90 then
                    BufferData <= matrix(1)(0);
                elsif HCount > 89 and Hcount < 180 then
                    BufferData <= matrix(1)(1);
                elsif HCount > 179 and Hcount <270 then
                    BufferData <= matrix(1)(2);
                elsif HCount > 269 and Hcount <360 then
                    BufferData <= matrix(1)(3);
                elsif HCount > 359 and Hcount <450 then
                    BufferData <= matrix(1)(4);
                elsif HCount > 449 and Hcount <540 then
                    BufferData <= matrix(1)(5);
                elsif HCount > 539 and Hcount <630 then
                    BufferData <= matrix(1)(6);
                elsif HCount > 629 and Hcount <720 then
                    BufferData <= matrix(1)(7);
                elsif HCount > 719 and Hcount <810 then
                    BufferData <= matrix(1)(8);
                elsif HCount > 809 and Hcount < 900 then
                    BufferData <= matrix(1)(9);
                elsif HCount > 899 and Hcount <990 then
                    BufferData <= matrix(1)(10);
                elsif HCount > 989 and Hcount <1080 then
                    BufferData <= matrix(1)(11);
                elsif HCount > 1079 and Hcount <1170 then
                    BufferData <= matrix(1)(12);
                elsif HCount > 1169 and Hcount <1260 then
                    BufferData <= matrix(1)(13);
                elsif HCount > 1259 and Hcount <1350 then
                    BufferData <= matrix(1)(14);
                else
                    BufferData <= matrix(1)(15);
                end if;
        elsif VCount > 179 and Vcount <270 then
                if Hcount < 90 then
                    BufferData <= matrix(2)(0);
                elsif HCount > 89 and Hcount < 180 then
                    BufferData <= matrix(2)(1);
                elsif HCount > 179 and Hcount <270 then
                    BufferData <= matrix(2)(2);
                elsif HCount > 269 and Hcount <360 then
                    BufferData <= matrix(2)(3);
                elsif HCount > 359 and Hcount <450 then
                    BufferData <= matrix(2)(4);
                elsif HCount > 449 and Hcount <540 then
                    BufferData <= matrix(2)(5);
                elsif HCount > 539 and Hcount <630 then
                    BufferData <= matrix(2)(6);
                elsif HCount > 629 and Hcount <720 then
                    BufferData <= matrix(2)(7);
                elsif HCount > 719 and Hcount <810 then
                    BufferData <= matrix(2)(8);
                elsif HCount > 809 and Hcount < 900 then
                    BufferData <= matrix(2)(9);
                elsif HCount > 899 and Hcount <990 then
                    BufferData <= matrix(2)(10);
                elsif HCount > 989 and Hcount <1080 then
                    BufferData <= matrix(2)(11);
                elsif HCount > 1079 and Hcount <1170 then
                    BufferData <= matrix(2)(12);
                elsif HCount > 1169 and Hcount <1260 then
                    BufferData <= matrix(2)(13);
                elsif HCount > 1259 and Hcount <1350 then
                    BufferData <= matrix(2)(14);
                else
                    BufferData <= matrix(2)(15);
                end if;
        elsif VCount > 269 and Vcount < 360 then
                                 
                if Hcount < 90 then
                    BufferData <= matrix(3)(0);
                elsif HCount > 89 and Hcount < 180 then
                    BufferData <= matrix(3)(1);
                elsif HCount > 179 and Hcount <270 then
                    BufferData <= matrix(3)(2);
                elsif HCount > 269 and Hcount <360 then
                    BufferData <= matrix(3)(3);
                elsif HCount > 359 and Hcount <450 then
                    BufferData <= matrix(3)(4);
                elsif HCount > 449 and Hcount <540 then
                    BufferData <= matrix(3)(5);
                elsif HCount > 539 and Hcount <630 then
                    BufferData <= matrix(3)(6);
                elsif HCount > 629 and Hcount <720 then
                    BufferData <= matrix(3)(7);
                elsif HCount > 719 and Hcount <810 then
                    BufferData <= matrix(3)(8);
                elsif HCount > 809 and Hcount < 900 then
                    BufferData <= matrix(3)(9);
                elsif HCount > 899 and Hcount <990 then
                    BufferData <= matrix(3)(10);
                elsif HCount > 989 and Hcount <1080 then
                    BufferData <= matrix(3)(11);
                elsif HCount > 1079 and Hcount <1170 then
                    BufferData <= matrix(3)(12);
                elsif HCount > 1169 and Hcount <1260 then
                    BufferData <= matrix(3)(13);
                elsif HCount > 1259 and Hcount <1350 then
                    BufferData <= matrix(3)(14);
                else
                    BufferData <= matrix(3)(15);
                end if;
        elsif VCount > 359 and Vcount < 450 then
                if Hcount < 90 then
                    BufferData <= matrix(4)(0);
                elsif HCount > 89 and Hcount < 180 then
                    BufferData <= matrix(4)(1);
                elsif HCount > 179 and Hcount <270 then
                    BufferData <= matrix(4)(2);
                elsif HCount > 269 and Hcount <360 then
                    BufferData <= matrix(4)(3);
                elsif HCount > 359 and Hcount <450 then
                    BufferData <= matrix(4)(4);
                elsif HCount > 449 and Hcount <540 then
                    BufferData <= matrix(4)(5);
                elsif HCount > 539 and Hcount <630 then
                    BufferData <= matrix(4)(6);
                elsif HCount > 629 and Hcount <720 then
                    BufferData <= matrix(4)(7);
                elsif HCount > 719 and Hcount <810 then
                    BufferData <= matrix(4)(8);
                elsif HCount > 809 and Hcount < 900 then
                    BufferData <= matrix(4)(9);
                elsif HCount > 899 and Hcount <990 then
                    BufferData <= matrix(4)(10);
                elsif HCount > 989 and Hcount <1080 then
                    BufferData <= matrix(4)(11);
                elsif HCount > 1079 and Hcount <1170 then
                    BufferData <= matrix(4)(12);
                elsif HCount > 1169 and Hcount <1260 then
                    BufferData <= matrix(4)(13);
                elsif HCount > 1259 and Hcount <1350 then
                    BufferData <= matrix(4)(14);
                else
                    BufferData <= matrix(4)(15);
                end if;
        elsif VCount > 449 and Vcount < 540 then
                if Hcount < 90 then
                    BufferData <= matrix(5)(0);
                elsif HCount > 89 and Hcount < 180 then
                    BufferData <= matrix(5)(1);
                elsif HCount > 179 and Hcount <270 then
                    BufferData <= matrix(5)(2);
                elsif HCount > 269 and Hcount <360 then
                    BufferData <= matrix(5)(3);
                elsif HCount > 359 and Hcount <450 then
                    BufferData <= matrix(5)(4);
                elsif HCount > 449 and Hcount <540 then
                    BufferData <= matrix(5)(5);
                elsif HCount > 539 and Hcount <630 then
                    BufferData <= matrix(5)(6);
                elsif HCount > 629 and Hcount <720 then
                    BufferData <= matrix(5)(7);
                elsif HCount > 719 and Hcount <810 then
                    BufferData <= matrix(5)(8);
                elsif HCount > 809 and Hcount < 900 then
                    BufferData <= matrix(5)(9);
                elsif HCount > 899 and Hcount <990 then
                    BufferData <= matrix(5)(10);
                elsif HCount > 989 and Hcount <1080 then
                    BufferData <= matrix(5)(11);
                elsif HCount > 1079 and Hcount <1170 then
                    BufferData <= matrix(5)(12);
                elsif HCount > 1169 and Hcount <1260 then
                    BufferData <= matrix(5)(13);
                elsif HCount > 1259 and Hcount <1350 then
                    BufferData <= matrix(5)(14);
                else
                    BufferData <= matrix(5)(15);
                end if;
        elsif VCount > 539 and Vcount < 630 then
                if Hcount < 90 then
                    BufferData <= matrix(6)(0);
                elsif HCount > 89 and Hcount < 180 then
                    BufferData <= matrix(6)(1);
                elsif HCount > 179 and Hcount <270 then
                    BufferData <= matrix(6)(2);
                elsif HCount > 269 and Hcount <360 then
                    BufferData <= matrix(6)(3);
                elsif HCount > 359 and Hcount <450 then
                    BufferData <= matrix(6)(4);
                elsif HCount > 449 and Hcount <540 then
                    BufferData <= matrix(6)(5);
                elsif HCount > 539 and Hcount <630 then
                    BufferData <= matrix(6)(6);
                elsif HCount > 629 and Hcount <720 then
                    BufferData <= matrix(6)(7);
                elsif HCount > 719 and Hcount <810 then
                    BufferData <= matrix(6)(8);
                elsif HCount > 809 and Hcount < 900 then
                    BufferData <= matrix(6)(9);
                elsif HCount > 899 and Hcount <990 then
                    BufferData <= matrix(6)(10);
                elsif HCount > 989 and Hcount <1080 then
                    BufferData <= matrix(6)(11);
                elsif HCount > 1079 and Hcount <1170 then
                    BufferData <= matrix(6)(12);
                elsif HCount > 1169 and Hcount <1260 then
                    BufferData <= matrix(6)(13);
                elsif HCount > 1259 and Hcount <1350 then
                    BufferData <= matrix(6)(14);
                else
                    BufferData <= matrix(6)(15);
                end if;
                
        elsif VCount > 629 and Vcount < 720 then
                if Hcount < 90 then
                    BufferData <= matrix(7)(0);
                elsif HCount > 89 and Hcount < 180 then
                    BufferData <= matrix(7)(1);
                elsif HCount > 179 and Hcount <270 then
                    BufferData <= matrix(7)(2);
                elsif HCount > 269 and Hcount <360 then
                    BufferData <= matrix(7)(3);
                elsif HCount > 359 and Hcount <450 then
                    BufferData <= matrix(7)(4);
                elsif HCount > 449 and Hcount <540 then
                    BufferData <= matrix(7)(5);
                elsif HCount > 539 and Hcount <630 then
                    BufferData <= matrix(7)(6);
                elsif HCount > 629 and Hcount <720 then
                    BufferData <= matrix(7)(7);
                elsif HCount > 719 and Hcount <810 then
                    BufferData <= matrix(7)(8);
                elsif HCount > 809 and Hcount < 900 then
                    BufferData <= matrix(7)(9);
                elsif HCount > 899 and Hcount <990 then
                    BufferData <= matrix(7)(10);
                elsif HCount > 989 and Hcount <1080 then
                    BufferData <= matrix(7)(11);
                elsif HCount > 1079 and Hcount <1170 then
                    BufferData <= matrix(7)(12);
                elsif HCount > 1169 and Hcount <1260 then
                    BufferData <= matrix(7)(13);
                elsif HCount > 1259 and Hcount <1350 then
                    BufferData <= matrix(7)(14);
                else
                    BufferData <= matrix(7)(15);
                end if;
            
        elsif VCount > 719 and Vcount < 810 then
                if Hcount < 90 then
                    BufferData <= matrix(8)(0);
                elsif HCount > 89 and Hcount < 180 then
                    BufferData <= matrix(8)(1);
                elsif HCount > 179 and Hcount <270 then
                    BufferData <= matrix(8)(2);
                elsif HCount > 269 and Hcount <360 then
                    BufferData <= matrix(8)(3);
                elsif HCount > 359 and Hcount <450 then
                    BufferData <= matrix(8)(4);
                elsif HCount > 449 and Hcount <540 then
                    BufferData <= matrix(8)(5);
                elsif HCount > 539 and Hcount <630 then
                    BufferData <= matrix(8)(6);
                elsif HCount > 629 and Hcount <720 then
                    BufferData <= matrix(8)(7);
                elsif HCount > 719 and Hcount <810 then
                    BufferData <= matrix(8)(8);
                elsif HCount > 809 and Hcount < 900 then
                    BufferData <= matrix(8)(9);
                elsif HCount > 899 and Hcount <990 then
                    BufferData <= matrix(8)(10);
                elsif HCount > 989 and Hcount <1080 then
                    BufferData <= matrix(8)(11);
                elsif HCount > 1079 and Hcount <1170 then
                    BufferData <= matrix(8)(12);
                elsif HCount > 1169 and Hcount <1260 then
                    BufferData <= matrix(8)(13);
                elsif HCount > 1259 and Hcount <1350 then
                    BufferData <= matrix(8)(14);
                else
                    BufferData <= matrix(8)(15);
                end if;
                
        elsif VCount > 809 and Vcount < 900 then
                if Hcount < 90 then
                    BufferData <= matrix(9)(0);
                elsif HCount > 89 and Hcount < 180 then
                    BufferData <= matrix(9)(1);
                elsif HCount > 179 and Hcount <270 then
                    BufferData <= matrix(9)(2);
                elsif HCount > 269 and Hcount <360 then
                    BufferData <= matrix(9)(3);
                elsif HCount > 359 and Hcount <450 then
                    BufferData <= matrix(9)(4);
                elsif HCount > 449 and Hcount <540 then
                    BufferData <= matrix(9)(5);
                elsif HCount > 539 and Hcount <630 then
                    BufferData <= matrix(9)(6);
                elsif HCount > 629 and Hcount <720 then
                    BufferData <= matrix(9)(7);
                elsif HCount > 719 and Hcount <810 then
                    BufferData <= matrix(9)(8);
                elsif HCount > 809 and Hcount < 900 then
                    BufferData <= matrix(9)(9);
                elsif HCount > 899 and Hcount <990 then
                    BufferData <= matrix(9)(10);
                elsif HCount > 989 and Hcount <1080 then
                    BufferData <= matrix(9)(11);
                elsif HCount > 1079 and Hcount <1170 then
                    BufferData <= matrix(9)(12);
                elsif HCount > 1169 and Hcount <1260 then
                    BufferData <= matrix(9)(13);
                elsif HCount > 1259 and Hcount <1350 then
                    BufferData <= matrix(9)(14);
                else
                    BufferData <= matrix(9)(15);
                end if;
        
        end if;
    
    end if;
    
        if rising_edge(clk) then
        
        if Enable = '1' then
             
            --HCount arttırılır
            if HCount < HorizontalWholeLine - 1 then
                HCount <= HCount + 1;
            else
                --HCount sona ulaştığında resetlenir ve VCount arttırılır
                HCount <= 0;
                if VCount < VerticalWholeLine - 1 then
                    VCount <= VCount + 1;
                else
                    VCount <= 0;
                end if;
            end if; 
             
            --HCount visible area içindeyse HVisible setlenir
            if HCount < HorizontalVisibleArea then
                HPulse <= '0';
                HVisible <= '1';
            elsif HCount < HorizontalVisibleArea + 
                                HorizontalFrontPorch then
                HPulse <= '0';
                HVisible <= '0';
            --HCount pulse alanı içindeyse HPulse setlenir.
            elsif HCount < HorizontalVisibleArea +
                                HorizontalFrontPorch +
                                HorizontalSyncPulse then
                HPulse <= '1';
                HVisible <= '0'; 
            elsif HCount < HorizontalWholeLine then
                HPulse <= '0';
                HVisible <= '0';
            end if;
             
            --VCount visible area içindeyse VVisible setlenir
            if VCount < VerticalVisibleArea then
                VPulse <= '0';
                VVisible <= '1';
            elsif VCount < VerticalVisibleArea + 
                                VerticalFrontPorch then
                VPulse <= '0';
                VVisible <= '0';
            --VCount pulse alanı içindeyse VPulse setlenir.
            elsif VCount < VerticalVisibleArea +
                                VerticalFrontPorch +
                                VerticalSyncPulse then
                VPulse <= '1';   
                VVisible <= '0';
            elsif VCount < VerticalWholeLine then
                VPulse <= '0';   
                VVisible <= '0';
            end if; 
             
            --Horizontal pulse üretimi
            if HPulse = '1' then
                HSync <= HorizontalSyncPolarity;
            else
                HSync <= not HorizontalSyncPolarity;
            end if;
             
            --Vertical pulse üretimi
            if VPulse = '1' then
                VSync <= VerticalSyncPolarity;
            else
                VSync <= not VerticalSyncPolarity;
            end if;
                     
            --Her iki yönde de visible alan içindeyse RGB sinyalleri gönderilir ve
            --Data Enable setlenir
            if HVisible = '1' and VVisible = '1' then      
                Red <= unsigned(BufferData(RGBLength * 3 - 1 downto RGBLength * 2));
                Green <= unsigned(BufferData(RGBLength * 2 - 1 downto RGBLength));
                Blue <= unsigned(BufferData(RGBLength - 1 downto 0));
                red_0 <= Red(0);
                red_1 <= Red(1);
                red_2 <= Red(2);
                red_3 <= Red(3);
                blue_0 <= Blue(0);
                blue_1 <= Blue(1);
                blue_2 <= Blue(2);
                blue_3 <= Blue(3);
                green_0 <= Green(0);
                green_1 <= Green(1);
                green_2 <= Green(2);
                green_3 <= Green(3);
--                DE <= '1';
            --Her iki yönde en az biri visible alan dışındaysa RGB ve Data Enable
            --resetlenir
            else           
                Red <= to_unsigned(0, RGBLength);
                Green <= to_unsigned(0, RGBLength);
                Blue <= to_unsigned(0, RGBLength);
                red_0 <= Red(0);
                red_1 <= Red(1);
                red_2 <= Red(2);
                red_3 <= Red(3);
                blue_0 <= Blue(0);
                blue_1 <= Blue(1);
                blue_2 <= Blue(2);
                blue_3 <= Blue(3);
                green_0 <= Green(0);
                green_1 <= Green(1);
                green_2 <= Green(2);
                green_3 <= Green(3);
--                DE <= '0';               
            end if;
            
            else
            
            HCount <= 0;
            VCount <= 0;
            BufferData <= "000000000000";
                         
            end if;
                         
        end if;

    end process;
 
end Behavioral;