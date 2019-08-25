{$X+}
unit introunit;

(******************************************************************************

 unit: introunit
 Contents: This unit contains modules that are responsible for the introduction
           when the program is first executed and a getchar routine which
           allows the program to get a character during execution in 
           a rawio mode.

 ******************************************************************************) 


INTERFACE

uses rawio;

const
   escape=27;         (* escape constant *)
   mincombar=3;       (* minimum command bar position- row *)
   maxcombar=22;      (* maximum command bar position- row *)
   filehead='file name       size   date   time  type';
   menubar='1copy  2del  3view   4edit  5mkdir  6rmdir  7mv   8ren  9tag   (untagall   0exit';


function getchar:char;
procedure inverseoff;
procedure inverseon;
procedure startupscreen;
procedure clearscreen;
procedure helpscreen;
procedure gotoxy(row,col:integer);
procedure clearhalfscreen(k:integer);


IMPLEMENTATION

function getchar;

(******************************************************************************
 
 Function getchar
 Purpose: allows input from the user in rawio mode
 
 Parameters: none         
 Called by: helpscreen, clearscreen, getname, getcom 
 Calls: none 

 ******************************************************************************)

var getch:char;  (* assigned to the function name for the program to continue *)

   begin
   read(getch);
   getchar:=getch;
   end;

procedure inverseoff;

(******************************************************************************

 Procedure inverseoff
 Purpose: returns test to normal video
 
 Parameters: none
 Called by: printpath, showbar, reprint, & main- mos
 Calls: none

 ******************************************************************************)
 
   begin
   write(chr(escape),'[0m');
   end;

procedure inverseon;

(******************************************************************************

 Procedure inverseon
 Purpose: displays test in inverse video

 Parameters: none
 Called by: printpath, showbar, reprint, &
 Calls: none

 ******************************************************************************)

   begin
   write(chr(escape),'[7m');
   end;


procedure clearscreen;

(******************************************************************************

 Procedure clearscreen
 Purpose: This procedure clears the screen

 Parameters: none
 Called by: the main program, mos, reprint 
 Calls: none

 ******************************************************************************)
 
   begin
   write(chr(escape),'[1;1H');
   write(chr(escape),'[J');
   end;

procedure startupscreen;

(******************************************************************************

 Procedure startupscreen
 Purpose: this procedure is the startup or title screen for the program.
          It contains information on the program and programmer.

 Parameters: none
 Called by: the main program, mos 
 Calls: none
 
 ******************************************************************************)
 
var dummygetchar:char;

   begin
   write(chr(escape),'[1;1H');
   writeln;
   writeln('              ** **                 ***                *****');
   writeln('             *  *  *               *   *              *     ');
   writeln('             *  *  *               *   *               **** ');
   writeln('             *     *               *   *                   *'); 
   writeln('             *     *                ***               ***** ');
   writeln;
   writeln;
   writeln('Program: mos ');
   writeln('Purpose: The menu operating system is a program designed to allow');
   writeln('         the user to traverse and manipulate and two combination');
   writeln('         of directories in the directory hierarchy.');
   writeln;
   writeln('         The essential UNIX operating system commands can be');
   writeln('         carried out by the use of a simple menu bar command line.');
   writeln('         Such operations as copy, move, remove, & make a directory');
   writeln('         are several operations. ');
   writeln;
   writeln('         With the feature of two directories displayed on the screen');
   writeln('         at once, the user can perform manipulations on and between');
   writeln('         the directories easily, unlike the un-user-friendly ');
   writeln('         environment of the UNIX operating system.');
   writeln;
   writeln;
   writeln('HIT A KEY TO CONTINUE');
   dummygetchar:=getchar;
   end;

procedure helpscreen;

(******************************************************************************
 
 Procedure helpscreen
 Purpose: writes a help screen to the user on how to operate the program.

 Parameters: none
 Called by: the main program, mos 
 Calls: none

 ******************************************************************************)

var dummygetchar:char;

   begin
   write(chr(escape),'[1;1H');
   writeln;
   writeln('To traverse file by file, use the up-arrow, down-arrow keys');
   writeln('To traverse twenty files at a time up or down, press U or u');
   writeln('    or D or d respectively');
   writeln;
   writeln('To toggle between directories, press <TAB>');
   writeln('To enter another directory, move to the desired directory and ');
   writeln('    press <RETURN> or <SPACE>');
   writeln;
   writeln('To tag a file for multiple menu bar command operations, press 9- tag');
   writeln('To untag ann entries in a directory, press shift 9 - untag');
   writeln;
   writeln('The highlighted menu bar command line contains information on how');
   writeln('    to perform system commands :');
   writeln;
   writeln;
   writeln('HIT A KEY TO CONTINUE');
   
   dummygetchar:=getchar;
   end;


procedure gotoxy;

(********************************************************************************

 Procedure gotoxy
 Purpose: This procedure, given a row and column, goes to that spot on the screen.

 Parameters: row, col
 Called by: printline, printpath, getcom, showbar, showline, notifyendlist, 
            getnewpath, tagfile, copy, move, deletefile, rename, edit, view, remdir
            makedir
 Calls: none

 ********************************************************************************)

   begin
   write(chr(escape),'[');
   write(row div 10:1,row mod 10:1,';');
   write(col div 10:1,col mod 10:1,'H');
   end;

procedure clearhalfscreen;

(********************************************************************************

 Procedure clearhalfscreen
 Propose: this procedure clears the half of the screen determines by the index
          sent in.

 Parameters: the index, k
 Called by: setup, pagedown, pageup, getcom
 Calls: gotoxy

 ********************************************************************************)
 
const blankout='                                        ';
var i:integer;
   begin
   for i:=mincombar to maxcombar do
      begin
      gotoxy(i,((k*40)-40+1));
      write(blankout);
      end;
   end;


begin
end.  (* unit introunit *)


