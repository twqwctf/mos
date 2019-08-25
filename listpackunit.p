{$X+}
unit listpackunit;

(********************************************************************************

 unit listpackunit
 Contents: this unit contains the linked list package, or all modules responsible
           for manipulations on the linked list stored in an array of records.
           
 ********************************************************************************)
           

interface

uses dirlsunit;

const namesize=14;      (* sizes of particular fields *)
      datesize=6;
      timesize=5;
      llistsize=100;
      rowsize=80;
      dummyspace=31;    (* dummy space between d or - and size in ls.out *)

type

nametype=packed array[1..namesize] of char;


(* type for a particular line in a directory *)

   linetype=record
      name:nametype;
      size:integer;
      date:packed array[1..datesize] of char;
      time:packed array[1..timesize] of char;
      kind:boolean;
      back,next:integer;
      tag:boolean;
   end;

filedir=array[1..llistsize] of linetype;       (* type for whole dir list *)
filetype=array[1..2] of filedir;
lastlisttype=array[1..2] of integer;

var
   dir
      :filetype;

   avail:integer;                 (* the next avail node *)
   lastlist               (* the index for the current end of the list *)
      :lastlisttype;

   listgreathun
      :boolean;           (* TRUE if the current dir is more than 100 elem *)


function size(filelist:filedir):integer;
procedure getnode(var anylist:filedir;llist:integer;var avail:integer);
procedure initlist(var anylist:filedir);
procedure filllist(var filelist:filedir;var llist,avail:integer);

implementation

function size;

(****************************************************************************

 Function size
 Purpose: This function determines the size of a directory

 Parameters: filelist
 Called by: deladjustllist, getcom
 Calls: none

 ****************************************************************************)
 
var endlist,count:integer;
   begin
   endlist:=1;
   count:=1;
   while (filelist[endlist].next<>0) do
      begin
      count:=count+1;
      endlist:=filelist[endlist].next;
      end;
   size:=count;
   end;


procedure getnode;

(*****************************************************************************

 Procedure: getnode
 Purpose: returns the index for the next available node 

 Parameters: anylist,lastlist,avail
 Called by: filllist
 Calls: none

 *****************************************************************************)

   begin
      if (anylist[avail].next<>0) and (llist<>0) 
         then
         avail:=anylist[avail].next; 
   end;

procedure initlist;

(*****************************************************************************

 Procedure: initlist
 Purpose: fills the back and next indexes of the linked list in a linked
          manner so that the back and next fields are linked together. If a
          node were to be deleted, the back and next fields would have to be
          altered accordingly to maintain the linked list.

 Parameters:  anylist
 Called by: filllist
 Calls: none

 *****************************************************************************)
 
   var i:integer;
   begin
   for i:=1 to llistsize do
      begin
      anylist[i].next:=i+1;
      anylist[i].back:=i-1;
      end;
   anylist[llistsize].next:=0;
  end;


procedure filllist;

(*****************************************************************************
 
 Procedure filllist
 Purpose: This procedure reads the current dir from ls.out and fills the linked
          lists' nodes with the appropriate fields. Then, in either case of the 
          dir being less than, equal to, or greater than 50 elements, the end
          of the list is denoted by a zero in the next field following the
          last full node.

 Parameters: anylist,lastlist,avail
 Called by: setup, getcom 
 Calls: getnode,initlist

 *********************************************************************************)

var t                (* counter *)
       :integer;
    dumchar,         (* dummy char *)
    chr              (* chr which determines dir or not *)
       :char;

   begin
   listgreathun:=FALSE;
   initlist(filelist);
   reset(lsfvar,'/tmp/ls.out');
   avail:=1;
   llist:=0;

   (* fills list until eof or fills 50 nodes *)

   while ((filelist[avail].next)<>0) and (not (eof(lsfvar))) do
      begin
      
      getnode(filelist,llist,avail);
      if (llist=0)
         then
         begin
         readln(lsfvar);
         llist:=1;
         end;
      read(lsfvar,chr);   
      if (chr='d')  
         then
         filelist[avail].kind:=TRUE
         else
         filelist[avail].kind:=FALSE;
      filelist[avail].tag:=FALSE;
      for t:=1 to dummyspace do
         read(lsfvar,dumchar);
      read(lsfvar,filelist[avail].size);
      read(lsfvar,dumchar);
      read(lsfvar,filelist[avail].date);
      read(lsfvar,dumchar);
      read(lsfvar,filelist[avail].time);
      read(lsfvar,dumchar);
      readln(lsfvar,filelist[avail].name);

      if (filelist[avail].next<>0) 
         then
         llist:=filelist[avail].next;

      end;

   if (not(eof(lsfvar))) 
      then
      listgreathun:=TRUE

      else

      (* sets zero in next field if dir is less than 100 elem *)

      if (filelist[avail].next<>0) then
         filelist[filelist[llist].back].next:=0;
     
   end;


begin
end.   (* unit listpackunit *)
   



