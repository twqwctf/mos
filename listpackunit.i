

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