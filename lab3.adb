with Ada.Text_IO, direct_io; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with hash_A; use hash_A;

procedure lab3 is

begin
    put_line("Question A:");
    hash_A.whichHash("C:\Users\curti\OneDrive\Desktop\Words200D16.txt", "", 128, 0.45, linear, yours, memory);
    hash_A.whichHash("C:\Users\curti\OneDrive\Desktop\Words200D16.txt", "relFile", 128, 0.45, linear, yours, file);
    hash_A.whichHash("C:\Users\curti\OneDrive\Desktop\Words200D16.txt", "", 128, 0.45, linear, mine, memory);
    hash_A.whichHash("C:\Users\curti\OneDrive\Desktop\Words200D16.txt", "relfile", 128, 0.45, linear, mine, file);



    put_line("Question B:");
    hash_A.whichHash ("C:\Users\curti\OneDrive\Desktop\Words200D16.txt", "", 128, 0.85, linear, yours, memory);
    hash_A.whichHash ("C:\Users\curti\OneDrive\Desktop\Words200D16.txt", "relFile", 128, 0.85, linear, yours, file);
    hash_A.whichHash ("C:\Users\curti\OneDrive\Desktop\Words200D16.txt", "", 128, 0.85, linear, mine, memory);
    hash_A.whichHash ("C:\Users\curti\OneDrive\Desktop\Words200D16.txt", "relFile", 128, 0.85, linear, mine, file);

    put_line("Question C:");
    hash_A.whichHash ("C:\Users\curti\OneDrive\Desktop\Words200D16.txt", "", 128, 0.45, random, yours, memory);
    hash_A.whichHash ("C:\Users\curti\OneDrive\Desktop\Words200D16.txt", "relfile", 128, 0.45, random, yours, file);
    hash_A.whichHash ("C:\Users\curti\OneDrive\Desktop\Words200D16.txt", "", 128, 0.85, random, yours, memory);
    hash_A.whichHash ("C:\Users\curti\OneDrive\Desktop\Words200D16.txt", "relFile", 128, 0.85, random, yours, file);

    hash_A.whichHash ("C:\Users\curti\OneDrive\Desktop\Words200D16.txt", "", 128, 0.45, random, mine, memory);
    hash_A.whichHash ("C:\Users\curti\OneDrive\Desktop\Words200D16.txt", "relfile", 128, 0.45, random, mine, file);
    hash_A.whichHash ("C:\Users\curti\OneDrive\Desktop\Words200D16.txt", "", 128, 0.85, random, mine, memory);
    hash_A.whichHash ("C:\Users\curti\OneDrive\Desktop\Words200D16.txt", "relFile", 128, 0.85, random, mine, file);


end lab3;
