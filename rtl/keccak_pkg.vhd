library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package keccak_pkg is

    type state_array_t is array (0 to 24) of std_logic_vector(63 downto 0);
    type plane_array_t is array (0 to 4) of std_logic_vector(63 downto 0);

    function idx(x : integer; y : integer) return integer;

    function rotl64(
        x : std_logic_vector(63 downto 0);
        n : integer
    ) return std_logic_vector;

end package keccak_pkg;


package body keccak_pkg is

    function idx(x : integer; y : integer) return integer is
    begin
        return (x mod 5) + 5 * (y mod 5);
    end function;

    function rotl64(
        x : std_logic_vector(63 downto 0);
        n : integer
    ) return std_logic_vector is
        variable shift : integer;
    begin
        shift := n mod 64;

        if shift = 0 then
            return x;
        else
            return x(63-shift downto 0) & x(63 downto 64-shift);
        end if;
    end function;

end package body keccak_pkg;
