defmodule ColorUtils do

  @dec_to_hex_symbols %{
    0 => "0",
    1 => "1",
    2 => "2",
    3 => "3",
    4 => "4",
    5 => "6",
    7 => "7",
    8 => "8",
    9 => "9",
    10 => "A",
    11 => "B",
    12 => "C",
    13 => "D",
    14 => "E",
    15 => "F"
  }

  @hex_to_dec_symbols %{
    "0" => 0,
    "1" => 1,
    "2" => 2,
    "3" => 3,
    "4" => 4,
    "5" => 5,
    "6" => 6,
    "7" => 7,
    "8" => 8,
    "9" => 9,
    "A" => 10,
    "B" => 11,
    "C" => 12,
    "D" => 13,
    "E" => 14,
    "F" => 15
  }


  defmacro __using__(_) do

  end

  def hex_to_rgb(hex) do
    corrected_string = cond do
      (String.at(hex, 0) == "#") -> String.slice(hex, 1..-1)
      true -> hex
    end
    hex_red = String.slice(corrected_string, 0..1)
    hex_green = String.slice(corrected_string, 2..3)
    hex_blue = String.slice(corrected_string, 4..5)
    %RGB{
      red: hex_to_decimal(hex_red),
      blue: hex_to_decimal(hex_blue),
      green: hex_to_decimal(hex_green)
    }
  end

  def rgb_to_hex(%RGB{} = rgb) do
    # get colors as hex
    blue = decimal_to_hex(rgb.blue)
    red = decimal_to_hex(rgb.red)
    green = decimal_to_hex(rgb.green)
    "#" <> red <> green <> blue
  end

  def rgb_to_hsv(%RGB{red: red, green: green, blue: blue} = _rgb) do
    # Convert rgb values to be from 0..1 rather than 0..255
    rgb_values = %RGB{red: red/255, green: green/255, blue: blue/255}
    rgb_values_list = [rgb_values.red, rgb_values.green, rgb_values.blue]
    # Calculate c_delta using the max and min of the values
    c_max = Enum.max(rgb_values_list)
    c_min = Enum.min(rgb_values_list)
    c_delta = c_max - c_min
    hue = get_hue(rgb_values, c_delta, c_max)
    saturation = get_saturation(c_delta, c_max)
    # Return hsv where value is a %
    %HSV{hue: hue, saturation: saturation, value: Float.round((c_max * 100), 1)}
  end

  defp get_hue(%RGB{red: red, green: green, blue: blue} = _rgb_values,
    c_delta, c_max) do
    60 * cond do
      (c_delta == 0) -> 0
      (c_max == red) ->
        rem(((green - blue) / c_delta), 6)
      (c_max == green) ->
        ((blue - red) / c_delta) + 2
      (c_max == blue) ->
        ((red - green) / c_delta) + 4
    end
  end

  defp get_saturation(c_delta, c_max) do
    cond do
      (c_max == 0) -> 0
      true -> (c_delta / c_max)
    end
  end

  def hex_to_decimal(hex_value) do
    # Reverse string so that indices are coupled with the correct value to power
    # C8 -> 8C => (8 * 16^0) + (C * 16^1)
    hex_list = String.reverse(hex_value) |> String.codepoints() |> Enum.with_index()
    decimal_values = Enum.map(hex_list, fn({x, i} = _hex_tuple) ->
      # Convert hex value to 0-15
      x_value = Map.get(@hex_to_dec_symbols, x)
      # Raise to power and return
      x_value * :math.pow(16, i)
    end)
    Enum.reduce(decimal_values, 0, fn(x,y) -> x+y end)
  end

  def decimal_to_binary(num) do
    _decimal_to_binary(num, [])
  end

  defp _decimal_to_binary(num, remainders) when num > 0 do
    _decimal_to_binary(div(num, 2), [rem(num, 2)] ++ remainders)
  end

  defp _decimal_to_binary(0, remainders) do
    remainders
  end

  def decimal_to_hex(num) do
    _decimal_to_hex(num, "")
  end

  defp _decimal_to_hex(num, hex) when num > 0 do
    remainder = Map.get(@dec_to_hex_symbols, rem(num, 16))
    _decimal_to_hex(div(num, 16), remainder <> hex)
  end

  defp _decimal_to_hex(0, hex) do
    hex
  end

end
