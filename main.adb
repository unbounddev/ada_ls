with Ada.Text_IO; use Ada.Text_IO;
with Ada.Directories;
with Ada.Environment_Variables;
with Ada.Text_IO.Text_Streams;
with Ada.Streams;
with Parsers;

procedure Main is
  Log_File: File_Type;
  Home_Path: constant String := Ada.Environment_Variables.Value("HOME");
  Log_Path: constant String := Home_Path & "/.local/state/ada-ls";
  Log_File_Name: constant String := Log_Path & "/ada-ls.log";

  type Parse_Type is abstract tagged null record;
  type Parse_Type_Result is record
    Result: Parse_Type'Class;
    Rest: String;
  end record;
  
  function Parse(Input: String) return Parse_Type_Result is abstract;

  type Header is record
    Content_Length: Integer;
    Content_Type: String := "application/vscode-jsonrpc; charset=utf-8";
  end record;

  type Header_Field is record
    Name: String;
    Value: String;
  end;

  package Header_Parsers is new Parsers(Header);

  function Get_Header return Header_Parsers.Result is
    use Ada.Streams;

    Stdin_Stream: constant Ada.Text_IO.Text_Streams.Stream_Access :=
      Ada.Text_IO.Text_Streams.Stream(Ada.Text_IO.Standard_Input);

    Buffer: Stream_Element_Array (1 .. 1024);
    Last: Stream_Element_Offset;
  begin
    loop
      Stdin_Stream.Read(Buffer, Last);

      exit when Last < Buffer'First;



    end loop;
  end;

  function Get_Content () is
  begin
    null;
  end;

  procedure Get_Request is
  begin
    null;
  end Get_Request;

begin
  -- Create Log File
  Ada.Directories.Create_Path(Log_Path);
  Create(Log_File, Out_File, Log_File_Name);

  Put_Line(Log_File, "Starting ada-ls");
  Put_Line(Log_File, "ada-ls listening...");


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
