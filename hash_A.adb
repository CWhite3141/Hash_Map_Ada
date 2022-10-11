with Ada.Direct_IO;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;



package body hash_A is

   procedure whichHash(inFile: String; outFile: String; size: Integer; currCapacity: Float; probeType: probe;
                       hashType: hash; loc: implement) is
   begin

      put_line("Hash: " & hash'Image(hashType));
      put_line("Probe: " & probe'Image(probeType));

      if loc = memory then
         put_line("Location: main memory");
         mainMem(inFile, size, currCapacity, probeType, hashType);
      else
         put_line("Location: " & outFile);
         randAcc(inFile, outFile, size, currCapacity, probeType, hashType);
      end if;

   end whichHash;

   procedure mainMem(inFile: String; size: Integer; currCapacity: Float;
                      probeType: probe; hashType: hash) is
      input: HIO.File_Type;
      upper: Integer:= Integer(Float'Floor(Float(size) * currCapacity));
   begin
      Open(input, in_file, inFile);
      Reset(input);
      declare
         nullRec: hashRecord:= ("                ", 0, 0);
         myTable: hashTable(0..size-1):= (others => nullRec);
      begin
         for pt in 2..upper+1 loop
            declare
               hRec: hashRecord;
               temp: hRead;
               offset: Integer:= 0;
               R: Integer:= 1;
               div: Integer:= 2**(Integer(Log(base=> 2.0, x=>Float(size))) + 2);
            begin
               Read(input, temp, HIO.Count(pt));
               hRec.item:= temp(1..16);

               if hashType= yours then
                  hRec.loc:= HshKey(hRec.Item);
               else
                  hRec.loc:= myHash(hRec.Item, size);
               end if;

               while myTable((hRec.loc + offset) mod size).Item /= nullRec.Item loop

                  if probeType = linear then
                     offset:= offset + 1;
                  else
                     R:= (R * 5) mod div;
                     offset:= R/4;
                  end if;

                  hRec.probes:= hRec.probes + 1;
               end loop;
               myTable((hRec.loc + offset) mod size):= hRec;
            end;
         end loop;

         for pt in 0..size-1 loop
            if myTable(pt).Item /= nullRec.Item then
               put(Integer'Image(pt) & " is "); put(myTable(pt).Item);
               put("Original location:" & Integer'Image(myTable(pt).loc));
               put("    Number of Probes:" & Integer'Image(myTable(pt).probes)); New_Line;
            else
               put_line(Integer'Image(pt) & " is NULL");
            end if;
         end loop;
         avg(input, eFile, myTable, 2, 31, size, probeType, hashType, memory);
         avg(input, eFile, myTable, upper-29, upper, size, probeType, hashType, memory);
         theoretical(size, upper, probeType); New_Line;
      end;
      Close(input);
   end mainMem;

   procedure randAcc(inFile: String; outFile: String; size: Integer;
                   currCapacity: Float; probeType: probe; hashType: hash) is
      input: HIO.File_Type;
      storage: OIO.File_Type;
      UB: Integer:= Integer(float'floor(Float(size) * currCapacity));
      T: hashRecord;
      loc: Integer;
   begin
      Open(input, in_file, inFile);
      declare
         nullRec: hashRecord:= ("                ", 0, 0);
      begin
         Create(storage, inout_file, outFile);
         for pt in 1..size loop
            OIO.Write(storage, nullRec, OIO.Count(pt));
         end loop;

         for pt in 2..UB+1 loop
            declare

               hRec: hashRecord;
               temp: hRead;
               offset: Integer:= 0;
               R: Integer:= 1;
               div: Integer:= 2**(Integer(Log(Base => 2.0, X => Float(size))) + 2);

            begin

               HIO.Read(input, temp, HIO.Count(pt));
               hRec.Item:= temp(1..16);  --slice item

               if hashType = yours then
                  hRec.loc:= HshKey(hRec.Item);
               else
                  hRec.loc:= myHash(hRec.Item, size);
               end if;

               loop --search for open space
                  loc:= (hRec.loc + offset) mod size;
                  if loc = 0 then   --wrap around if hash address exceeds TS
                     loc:= 64;
                  end if;
                  OIO.Read(storage, T, OIO.Count(loc));
                  exit when T = nullRec;
                  hRec.probes:= hRec.probes + 1;
                  if probeType = LINEAR then
                     offset:= offset + 1;
                  else
                     R:= (R * 5) mod div;
                     offset:= R/4;
                  end if;
               end loop;
               OIO.Write(storage, hRec, OIO.Count(loc));
            end;
         end loop;

         for pt in 1..size loop
            OIO.Read(storage, T, OIO.Count(pt));
            if T /= nullRec then
               put(Integer'Image(pt) & " is "); put(T.Item);
               put("Original location:" & Integer'Image(T.loc));
               put("     Number of Probes:" & Integer'Image(T.probes)); New_Line;
            else
               put_line(Integer'Image(pt) & " is NULL");
            end if;
         end loop;

         avg(input, storage, eTable, 2, 31, size, probeType, hashType, file);
         avg(input, storage, eTable, UB-29, UB, size, probeType, hashType, file);
         theoretical(size, UB, probeType); New_Line;

         Close(storage);

      end;

      Close(input);
   end randAcc;

   procedure avg(input: HIO.File_Type; storage: OIO.File_Type;
                  myTable: hashTable; lower: Integer; upper: Integer;
                  size: Integer; probeType: probe; hashType: hash;
                  location: implement) is
      min: Integer:= 1000;
      max: Integer:= 1;
      avg: Float:= 0.0;
      div: Float:= Float(upper-lower+1);
   begin
      for pt in lower..upper loop
         declare
            T, T2: hashRecord;
            temp: hRead;
            offset: integer:= 0;
            loc: Integer:= 0;
            R: Integer:= 1;
            divisor: Integer:= 2**(Integer(Log(base=>2.0, x=>Float(size))) + 2);
         begin
            Read(input, temp, HIO.Count(pt));
            T.Item:= temp(1..16);
            if hashType = yours then
               T.loc:= HshKey(T.Item);
            else
               T.loc:= myHash(T.Item, size);
            end if;
            if location = file then
               loop
                  loc:= (T.loc + offset) mod size;
                  if loc = 0 then  --wrap around when location exceeds table size
                     loc:= 64;
                  end if;
                  OIO.Read(storage, T2, OIO.Count(loc));
                  exit when T2.Item = T.Item;
                  T.probes:= T.probes + 1;
                  if probeType = LINEAR then
                     offset:= offset + 1;
                  else
                     R:= (R * 5) mod divisor;
                     offset:= R/4;
                  end if;
               end loop;
            else
               while myTable((T.loc + offset) mod size).Item /= T.Item loop

                  if probeType = LINEAR then
                     offset:= offset + 1;
                  else
                     R:= (R * 5) mod divisor;
                     offset:= R/4;
                  end if;
                  T.probes:= T.probes + 1;
               end loop;
            end if;
            if T.probes < min then
               min:= T.probes;
            elsif T.probes > max then
               max:= T.probes;
            end if;
            avg:= avg + (Float(T.probes) / div);
         end;
      end loop;
      put_line("--------------------------------------");
      put_line("Stats for" & Integer'Image(Upper-30) & " to" & integer'Image(Upper));
      put_line("Min:" & Integer'Image(min));
      put_line("Max:" & Integer'Image(max));
      put("Avg:"); fIO.put(avg,3,2,0); New_Line;
   end avg;

   procedure theoretical(size : Integer; keys : Integer; probeType : probe) is
      loadFactor: float;
      E: float;
   begin
      loadFactor:= (float(keys) / float(size));
      if probeType = linear then
         E:= (1.0 - loadFactor / 2.0) / (1.0 - loadFactor);
      else
         E:= -(1.0 / loadFactor) * (Log(1.0 - loadFactor));
      end if;
      put_line("--------------------------------------");
      put_line("Keys:" & Integer'Image(keys));
      put("Load level: ");
      fIO.put(loadFactor * 100.0, 2, 2, 0); put("%");
      New_Line;
      put("Expected probes to locate key:");
      fIO.put(E, 2, 2, 0); New_Line;
   end theoretical;

   function HshKey(Item : hElement) return Integer is
      HA: Unsigned_64;
   begin
      HA:= ((char2Uns(Item(3)) + char2uns(Item(1)))*8) / 256;
      HA:= HA + char2Uns(Item(8));
      HA:= HA mod 128;
      return uns2Int(HA);
   end HshKey;

   function myHash(Item: hElement; TS: Integer) return Integer is
      HA: Unsigned_64;
   begin
      HA:= mystr2uns(Item(1..4)) + mystr2Uns(Item(5..8)) + mystr2Uns(Item(9..12))
            + myStr2Uns(Item(13..16)); --fold
      HA:= squareStr(Item(1..8)) * squareStr(Item(9..16)); -- square
      HA:= HA XOR 5953474341373129;  --xor to scramble with prime 16 digit number
      HA:= HA / 100000;    --shift right 5
      return uns2Int(HA mod int2Uns(TS));  --division remainder
   end myHash;

end hash_A;
