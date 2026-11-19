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

  function To_String(
    Buffer: Stream_Element_Vectors.Vector; 
    Start_Index: Stream_Element_Vectors.Extended_Index;
    End_Index: Stream_Element_Vectors.Extended_Index
  ) return String is
    Result: String(1..End_Index-Start_Index);
    Result_Index: Positive := Result'First;
  begin
    for I in Start_Index..End_Index loop
      Result(Result_Index) := Character'Val(Buffer(I));
      Result_Index := Result_Index + 1;
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
  end To_Vector;

  function To_Vector(Str: String) return Stream_Element_Vectors.Vector is
    V: Stream_Element_Vectors.Vector;
  begin
    for C of Str loop
      V.Append(Character'Pos(C));
    end loop;
    return V;
  end To_Vector;

  function Tail(Buffer: Stream_Element_Vectors.Vector; Count: Integer) return Stream_Element_Vectors.Vector is
    use Stream_Element_Vectors;
    V: Vector;
    Last_Index: constant Extended_Index := Buffer.Last_Index;
    Start_Index: constant Extended_Index := Extended_Index'Max(Buffer.First_Index, Last_Index-(Count-1));
  begin
    if not Buffer.Is_Empty then
      for I in Start_Index .. Last_Index loop
        V.Append(Buffer(I));
      end loop;
    end if;
    return V;
  end Tail;

  function Ends_With(Buffer: Stream_Element_Vectors.Vector; Str: String) return Boolean is
    use Ada.Containers;
    use Stream_Element_Vectors;
    Last_Index: constant Extended_Index := Buffer.Last_Index;
    Start_Index: constant Extended_Index := Extended_Index'Max(Buffer.First_Index, Last_Index-(Str'Length-1));
    Str_Index: Positive := Str'First;
  begin

    if Str'Length = 0 then
      return true;
    end if;

    if Buffer.Length < Str'Length then
      return false;
    end if;

    for I in Start_Index .. Last_Index loop
      if Buffer(I) /= Character'Pos(Str(Str_Index)) then
        return false;
      end if;
      Str_Index := Str_Index + 1;
    end loop;

    return true;
  
  end Ends_With;

  type Stream_Element_Result is record
    Value: Stream_Element_Vectors.Vector;
    Rest: Stream_Element_Vectors.Vector;
  end record;
  
  function Get_Header return Stream_Element_Vectors.Vector is
    use Ada.Containers;
    use Stream_Element_Vectors;
    Content: Stream_Element_Vectors.Vector;
    Buffer: Stream_Element_Array (1 .. 1);
    Last: Stream_Element_Offset;
    Temp_Str: String(Header_End'Range);
  begin
    loop
      Stdin_Stream.Read(Buffer, Last);

      exit when Last < Buffer'First;

      Content.Append(Buffer(Buffer'First));
      if Content.Length >= Header_End'Length then
        if Ends_With(Content, Header_End) then
          return Content; 
        end if;
      end if;
    end loop;
    raise Incomplete_Header with "Header must end with empty newline";
  end;

  -- function Get_Content return Stream_Element_Result is
  -- begin
  --  null;
  -- end;

  procedure Get_Request is
    Header: Stream_Element_Vectors.Vector;
  begin
    Header := Get_Header;
    Put_Line(Log_File, "Header:");
    Put(Log_File, To_String(Header));
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
    when Invalid_Request | Incomplete_Header =>
      Close(Log_File); 
end Main;

