{$X+}
unit dirlsunit;

(******************************************************************************

 unit dirlsunit
 contents: this unit is responsible for retrieving a new dir or pwd to the
           dir. 

 ******************************************************************************)

interface

   const string256size=256;
         string20size=20;

   type
      string20=packed array[1..string20size] of char;
      string256=packed array[1..string256size] of char;
      pathtype=array[1..2] of string256;
   var
      syscom:string20;
      path:pathtype;         (* the array variable for a path *)
      lsfvar,pwdfvar:text;   (* output files *)


function system(var syscom:string256):integer;

(* C ext. lanf. fnc. to call UNIX sys. routines *)
   cexternal;     

procedure append(var str256:string256;
                 var str20:string20;
                 len256:integer);
procedure pwd(var pwdfvar:text;
              var apath:string256);
procedure ls(var apath:string256);
procedure listls(var lsfvar:text);
procedure callprint(var apath:string256);
function pathsize(apath:string256):integer;
function samepath(firstpath,secondpath:string256):boolean;

implementation


procedure append;

(********************************************************************************

 Procedure append
 Purpose:  concats str20 onto end of str 256 at index len256 

 Parameters: str256, str20, len256
 Called by: ls, getnewpath
 Calls: none

 ********************************************************************************)

var
   chr0:char;       (* init nill char *)
   i:integer;

   begin
   chr0:=chr(0);
   i:=0;
   repeat
      i:=i+1;
      str256[len256+i-1]:=str20[i];
   until (i=20) or (str20[i]=chr0);
   end;
                        (*-------------------------------------------------*)

procedure pwd;

(********************************************************************************

 Procedure pwd
 Purpose: This procedure directs the path to the working directory to /tmp/pwd.out.
 
 Parameters :pwdfvar, apath
 Called by: callprint
 Calls: system

 *********************************************************************************)

var
   i:integer;
   ch:char;
   syscom:string20;
   syscom256:string256;

   begin

   (* set sys. com. to call, redirect pwd output *)
 
   syscom:='pwd> /tmp/pwd.out   ';
   syscom[20]:=chr(0);      (* end of string for C lang. fcn. *)
   append(syscom256,syscom,1);
   i:=system(syscom256);       (* calls pwd *)

   i:=0;
   reset(pwdfvar,'/tmp/pwd.out');
   while (not (eof(pwdfvar))) do
      begin
      if (eoln(pwdfvar))
         then
         read(pwdfvar,ch)
         else
         begin
         read(pwdfvar,ch);
         i:=i+1;
         apath[i]:=ch;
         end;
      end;
   i:=i+1;
   apath[i]:=chr(0);
   close(pwdfvar);
   end;  (* pwd *)
                        (*--------------------------------------------------*)

procedure ls;

(********************************************************************************

 Procedure ls
 Purpose: This procedure directs the directory listing to /tmp/ls.out
 
 Parameters: apath
 Called by: callprint, getcom
 Calls: append, system

 ********************************************************************************)

   var
      syscom:string256;
      sys20:string20;
      comdex,i,count:integer;
      chr0:char;

   begin
   chr0:=chr(0);

   (* set syscom:='ls -al '+path+'>/tmp/ls.out' *)

   syscom[1]:='l';
   syscom[2]:='s';
   syscom[3]:=' ';
   syscom[4]:='-';
   syscom[5]:='a';
   syscom[6]:='l';
   syscom[7]:=' ';
   comdex:=7;

   i:=0;
   count:=0;
   repeat
      i:=i+1;
      comdex:=comdex+1;
      syscom[comdex]:=apath[i];
      until apath[i]=chr0;       (* end of string *) 

   sys20:='> /tmp/ls.out       ';
   sys20[15]:=chr0;
   append(syscom,sys20,comdex);

   (* call ls fcn *)

   i:=system(syscom);  
   end; (* ls *)
                         (*--------------------------------------------------*)

procedure listls;

(**********************************************************************************

 Procedure listls
 Purpose: This procedure reads the input line by line from /tmp/ls.out

 Parameters: none
 Called by: getnewpath, getcom
 Calls: none
 
 **********************************************************************************)

var
   lsline:packed array[1..80] of char;
   ch,ch2,ch3,ch4,ch5:char;

begin
   reset(lsfvar,'/tmp/ls.out');
   readln(lsfvar);
   while (not (eof(lsfvar))) do
      begin
      readln(lsfvar,lsline);
      end;
end;   (* listls *)
                         (*-------------------------------------------*)

procedure callprint;

(********************************************************************************

 Procedure callprint
 Purpose: called by the main program, mos, to call ls and pwd firstly

 Parameters: apath
 Called by: main- mos
 Calls: pwd, ls

 ********************************************************************************)

begin 
   pwd(pwdfvar,apath);
   ls(apath);
end;   (* callprint *)


function pathsize;

(********************************************************************************
 
 Function pathsize
 Purpose: This function accepts a path and returns its size (# of chars)   

 Parameters: apath
 Called by: samepath, addpathname, adjustpath, printpath, copy, move, rename
 Calls: none

 ********************************************************************************) 
 
var i:integer;
    chr0:char;
   begin
   chr0:=chr(0);
   i:=0;
   repeat
      i:=i+1;
   until(apath[i]=chr0) or (i=string256size);
   pathsize:=i-1;
   end;

function samepath;

(********************************************************************************

 Function samepath
 Purpose: This function determines whether or not the two passed in paths are
          the same and returns the appropriate boolean

 Parameters: firstpath and secondpath
 Called by: getcom   
 Calls: pathsize

 ********************************************************************************)

var i:integer;
   begin
   samepath:=FALSE;
   if (pathsize(firstpath)=pathsize(secondpath))
      then
      for i:=1 to pathsize(firstpath) do
         samepath:=firstpath[i]=secondpath[i];
   end;



begin
end.  (* unit dirlsunit *)



