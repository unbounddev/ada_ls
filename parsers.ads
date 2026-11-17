with Parse_Types;
generic
  type Result_Type is private;
package Parsers is
  type Result is new Parse_Types.Parse_Type with record
    Value: Result_Type;
    Rest: String;
  end record;

  type Parser is access function (Input: String) return Result;
end Parsers;
