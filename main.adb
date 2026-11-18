with Ada.Text_IO; use Ada.Text_IO;
with Ada.Directories;
with Ada.Environment_Variables;
with Ada.Text_IO.Text_Streams;
with Ada.Streams;
with Ada.Containers.Vectors;
with Ada.Characters.Latin_1;
with Ada.Exceptions; use Ada.Exceptions;

procedure Main is
  use Ada.Characters.Latin_1;
  use Ada.Streams;
  package Stream_Element_Vectors is new Ada.Containers.Vectors(Natural, Stream_Element); 
  Log_File: File_Type;
  Home_Path: constant String := Ada.Environment_Variables.Value("HOME");
  Log_Path: constant String := Home_Path & "/.local/state/ada-ls";
  Log_File_Name: constant String := Log_Path & "/ada-ls.log";
  
  Header_End : constant String := CR & LF & CR & LF; 
  
  Stdin_Stream: constant Ada.Text_IO.Text_Streams.Stream_Access :=
    Ada.Text_IO.Text_Streams.Stream(Ada.Text_IO.Standard_Input);

  Incomplete_Header: Exception;
  Invalid_Request: Exception;
  
  -- function Parse(Input: String) return Parse_Type_Result is abstract;

  -- type Header is record
  --   Content_Length: Integer;
  --   Content_Type: String := "application/vscode-jsonrpc; charset=utf-8";
  -- end record;

  -- type Header_Field is record
  --   Name: String;
  --   Value: String;
  -- end record;

  -- package Header_Parsers is new Parsers(Header);
  -- package String_Parsers is new Parsers(String);
  -- package Stream_Element_Array_Parsers is new Parsers(Stream_Element_Array);

  function To_String(Buffer: Stream_Element_Array) return String is
    Result: String(1..Buffer'Length);
    I: Positive := 1;
  begin
    for Byte of Buffer loop
      Result(I) := Character'Val(Byte);
      I := I + 1;
    end loop;
    return Result;
  end To_String;

  function To_String(Buffer: Stream_Element_Vectors.Vector) return String is
    Result: String(1..Integer(Buffer.Length));
    I: Positive := 1;
  begin
    for Byte of Buffer loop
      Result(I) := Character'Val(Byte);
      I := I + 1;
    end loop;
    return Result;
  end To_String;
  
  function To_Vector(Buffer: Stream_Element_Array) return Stream_Element_Vectors.Vector is
    V: Stream_Element_Vectors.Vector;
  begin
    V.Reserve_Capacity(Buffer'Length);
    for Byte of Buffer loop
      V.Append(Byte);
    end loop;
    return V;
  end;

  type Stream_Element_Result is record
    Value: Stream_Element_Vectors.Vector;
    Rest: Stream_Element_Vectors.Vector;
  end record;
  
  function Get_Header return Stream_Element_Result is
    Content: Stream_Element_Vectors.Vector;
    Buffer: Stream_Element_Array (1 .. 1024);
    Last: Stream_Element_Offset;
    Temp_Str: String(Header_End'Range);
  begin
    loop
      Stdin_Stream.Read(Buffer, Last);

      exit when Last < Buffer'First;

      Content.Reserve_Capacity(Ada.Containers.Count_Type(Integer(Content.Length) + Integer(Last-Buffer'First+1)));

      for I in Buffer'First .. Last loop
        Content.Append(Buffer(I));
        if I >= Buffer'First + Header_End'Length - 1 then
          Temp_Str := To_String(Buffer(I-3..I));
          if Temp_Str = Header_End then
              return (Value => Content, Rest => To_Vector(Buffer(I..Last)));
          end if;
        end if;
      end loop;
    end loop;
    raise Incomplete_Header with "Header must end with empty newline";
  end;

  -- function Get_Content return Stream_Element_Result is
  -- begin
  --  null;
  -- end;

  procedure Get_Request is
    Header: Stream_Element_Result;
  begin
    Header := Get_Header;
    Put_Line(Log_File, "Header:");
    Put(Log_File, To_String(Header.Value));
    New_Line(Log_File);
    Put_Line(Log_File, "Rest:");
    Put(Log_File, To_String(Header.Rest));
    New_Line(Log_File);
    -- Raising to prevent infinite loop due to incomplete implementation
    raise Invalid_Request with "Request must include header and content";
  end Get_Request;

begin
  -- Create Log File
  Ada.Directories.Create_Path(Log_Path);
  Create(Log_File, Out_File, Log_File_Name);

  Put_Line(Log_File, "Starting ada-ls");
  Put_Line(Log_File, "ada-ls listening...");

  loop
    Get_Request;
  end loop;

  Close(Log_File); 
  
  exception
    when others =>
      Close(Log_File); 
end Main;

-- generic
   -- Accepts any tagged type (abstract or concrete)
--    type Element_Type is abstract tagged private;
-- package Generic_Polymorphic_Array is

   -- 1. Define a class-wide access type so elements have a fixed pointer size
--   type Element_Access is access all Element_Type'Class;

   -- 2. Define the array using the access type
--   type Element_Array is array (Positive range <>) of Element_Access;

   -- Example procedure that dispatches dynamically on elements
--   procedure Process_All (Items : in Element_Array);

-- end Generic_Polymorphic_Array;
