{$X+}
unit menuunit;

(**********************************************************************************

 unit menuunit

 contents: This unit contains all modules that are responsible for the menubar
           functions. In order for the program to perform such operations, the
           system function must be called which calls the UNIX system. This
           enables the program to work with the actual system function such
           as cp,mv,rm etc...

 **********************************************************************************)

interface

uses rawio,introunit,dirlsunit,listpackunit; 

const
    messageline=26;
    bigdirline=30;

var 
    bottllist,       (* variable which, upon traversing the linked list searching
                        for tagged files, keeps the last index when the procedure
                        gettag exited *)
    reg,             (* variable which is the index for the tagged file (if any) *)
    dup,             (* is assigned to reg to determine whether a duplicate
                        register (reg) was returned from gettag *)
    again,           (* counter to signify the end of a system calling loop *) 
    spot,            (* variable which holds the next available index to add to
                        a packed array (command) *)  
    newspot          (* similar to spot; a re-assigned index to fill 'command' *)
       :integer;


procedure gettag(var filelist:filedir;var tmpllist,llist,reg:integer;var foundtag
                 :boolean);
procedure addpathandname(var aname:nametype;var apath,command:string256;
                         var spot,newspot:integer);
procedure copy(var filelist:filedir;var llist,cond:integer;
               firstpath,secondpath:string256);
procedure move(var filelist:filedir;var llist,cond:integer;
               firstpath,secondpath:string256);
procedure deletefile(var filelist:filedir;var llist,cond:integer;
                     apath:string256);
procedure getname(var newname:nametype);
procedure rename(var filelist:filedir;var llist,cond:integer;
                     apath:string256);
procedure makedir(var filelist:filedir;var cond:integer;apath:string256);
procedure remdir (var filelist:filedir;var llist,cond:integer;apath:string256);
procedure edit   (var filelist:filedir;var llist,cond:integer;apath:string256);
procedure view   (var filelist:filedir;var llist,cond:integer;apath:string256);

implementation

procedure gettag;

(**********************************************************************************

 Procedure gettag
 Purpose: This procedure traverses a directory and, if finding a tagged file,
          returns the index. If no tagged files are found, the present index,
          llist, is simply returned.

 Parameters: filelist, tmpllist, llist, reg & foundtag
 Called by: copy, move, deletefile, rename, view & edit
 Calls: none

 **********************************************************************************)

var temp:integer;

   begin

   (* traverse list until reach end or tagged file *)

   while (not (filelist[tmpllist].tag)) and (filelist[tmpllist].next<>0) do
      tmpllist:=filelist[tmpllist].next;

   (* return the current tmpllist if finds a tagged file *)

   if (filelist[tmpllist].tag)
      then
      begin
      foundtag:=TRUE;
      reg:=tmpllist;
      tmpllist:=filelist[tmpllist].next;
      end 

      else

      (* otherwise simply return the current index, llist *)
 
      if (not(foundtag)) then
         reg:=llist;

      if (tmpllist=0) then begin 
         temp:=1;
         while (filelist[temp].next<>0) do
            temp:=filelist[temp].next;
         tmpllist:=temp;  
         reg:=temp;
         end;
                    
   

   gotoxy(bigdirline,1);
   end;

procedure addpathandname;

(******************************************************************************

 Procedure addpathname
 Purpose: This procedure accepts a name, a path, a command, and an index and adds
          the path and name respectively to the command at index

 Parameters: aname, apath, command, spot and newspot
 Called by: copy, move, deletefile, rename, makedir, remdir, edit and view
 Calls: none

 ******************************************************************************)

var i,j:integer;

   begin
       command[spot]:=' ';
       for i:=1 to pathsize(apath) do
          command[spot+i]:=apath[i];
       newspot:=spot+1+i;
       command[newspot]:='/';
       j:=0;
       repeat
          j:=j+1;
          newspot:=newspot+1;
          command[newspot]:=aname[j];
       until (aname[j]=' ') or (j=namesize);
   end;


procedure copy;            (* cp *)

(*******************************************************************************

 Procedure copy
 Purpose: This procedure determines the correct command and calls system with
          'cp' + firstpath + filelist.name secondpath + filelist.name. 
          Multiple copies are possible with tagged files.  

 Parameters: filelist, llist, cond, firstpath, secondpath
 Called by: getcom
 Calls: gettag, addpathandname, gotoxy, system

 *******************************************************************************)

var i:integer; 
    foundtag:boolean;
    command,tmpcommand:string256;

    begin
    foundtag:=FALSE;
    again:=0;
    dup:=0;
    bottllist:=1;
    gettag(filelist,bottllist,llist,reg,foundtag);

    (* repeat system calls for tagged files *)
    
    repeat
       tmpcommand:=command;
       gotoxy(40,50);
       command[1]:='c';
       command[2]:='p';
       spot:=3;
       addpathandname(filelist[reg].name,firstpath,command,spot,newspot);

       command[newspot+1]:=' ';
       for i:=1 to pathsize(secondpath) do
          command[newspot+1+i]:=secondpath[i];
       command[newspot+2+i]:=chr(0);

       gotoxy(bigdirline,1);

       if (tmpcommand<>command) then begin
          cond:=system(command);

          gotoxy(messageline,1);
          if (cond<>0)
             then
             write('Error in copying: ',firstpath,'/',filelist[reg].name)
 
             else
             write('Copying ',firstpath,'/',filelist[reg].name);
          end;

       dup:=bottllist;
       gettag(filelist,bottllist,llist,reg,foundtag);
       if (dup=bottllist) then again:=again+1;
       
       until (again=2); 
    
    end;

procedure move;            (* mv *)

(******************************************************************************

 Procedure move
 Purpose: This procedure determines command and calls system with 'cp' + 
          firstpath + filelist.name secondpath 
          In addition, multiple moves are possible if files are tagged. 

 Parameters: filelist, llist, cond, firstpath, secondpath
 Called by: getcom
 Calls: gettag, addpathandname, gotoxy, system

 ******************************************************************************)

var i:integer; 
    foundtag:boolean;
    command,tmpcommand:string256;

    begin
    foundtag:=FALSE;
    again:=0;
    dup:=0;
    bottllist:=1;
    gettag(filelist,bottllist,llist,reg,foundtag);
   
    (* repeat system calls for tagged files *)

    repeat
       tmpcommand:=command;
       gotoxy(40,50);
       command[1]:='m';
       command[2]:='v';
       spot:=3;
       addpathandname(filelist[reg].name,firstpath,command,spot,newspot);

       command[newspot+1]:=' ';
       for i:=1 to pathsize(secondpath) do
          command[newspot+1+i]:=secondpath[i];
       command[newspot+2+i]:=chr(0);

       gotoxy(bigdirline,1);
       if (tmpcommand<>command) then
          begin
          cond:=system(command);
          gotoxy(messageline,1);

          if (cond<>0)
             then
             write('Error in moving ',firstpath,'/',filelist[reg].name)

             else
             write('Moving ',firstpath,'/',filelist[reg].name);
          end;

       dup:=bottllist;
       gettag(filelist,bottllist,llist,reg,foundtag);
       if (dup=bottllist) then again:=again+1;

       until (again=2);

    end;

procedure deletefile;

(*****************************************************************************

 Procedure deletefile
 Purpose: This procedure determines the command and calls system with 'rm' +
          path + name. Multiple deletes are also allowed with tagged files. 

 Parameters: filelist, llist, cond, apath
 Called by: getcom
 Calls: gettag, addpathandname, gotoxy, system

 *****************************************************************************)

var i:integer; 
    foundtag:boolean;
    command,tmpcommand:string256;

   begin
   foundtag:=FALSE;
   again:=0;
   dup:=0;
   bottllist:=1;
   gettag(filelist,bottllist,llist,reg,foundtag);

   (* repeat system calls for tagged files *)

   repeat
      tmpcommand:=command;
      command[1]:='r';
      command[2]:='m';
      spot:=3;
      addpathandname(filelist[reg].name,apath,command,spot,newspot);
      command[newspot+1]:=chr(0);

      gotoxy(bigdirline,1);
      if (tmpcommand<>command) then
         begin
         cond:=system(command);
      
         gotoxy(messageline,1);
         if (cond<>0)
            then
            write('Error in deleting :',apath,'/',filelist[reg].name)
            else
            write('Deleting ',apath,'/',filelist[reg].name);
         end;

      dup:=bottllist;
      gettag(filelist,bottllist,llist,reg,foundtag);
      if (dup=bottllist) then again:=again+1;

      until (again=2);

   end;

procedure getname;

(*******************************************************************************

 Procedure getname
 Purpose: This procedure forms the packed array newname given user input.
 
 Parameters: newname
 Called by: rename, makedir   
 Calls: getchar 

 *******************************************************************************)

var ch:char;
    p:integer;

   begin
   p:=0;
   repeat
      p:=p+1;
      ch:=getchar;
      write(ch);
      newname[p]:=ch;
   until (p=namesize) or (ord(ch)=32);
   end;
      
      
procedure rename;

(*******************************************************************************

 Procedure rename
 Purpose: This procedure determines the command and calls system with 'mv' + 
          filelist.name + newname. Because this is a single file command,  
          multiple renames are not allowed. 

 Parameters: filelist, llist, cond, apath
 Called by: getcom
 Calls: gettag, addpathandname, gotoxy, system 

 *******************************************************************************)
  
var i,j:integer; 
    foundtag:boolean;
    command:string256;
    newname:nametype;

   begin
   bottllist:=1;
   gettag(filelist,bottllist,llist,reg,foundtag);

   (* if there are no tagged files, proceed by calling system *)

   if (not (foundtag))
      then
      begin
      command[1]:='m';
      command[2]:='v';
      spot:=3;
      addpathandname(filelist[llist].name,apath,command,spot,newspot);
      command[newspot+1]:=' ';
      for i:=1 to pathsize(apath) do
         command[newspot+1+i]:=apath[i];
      newspot:=newspot+2+i;
      command[newspot]:='/';
      gotoxy(messageline,1);
      write('Enter new name: ');
      getname(newname);
      j:=0;
      repeat
         j:=j+1;
         command[newspot+j]:=newname[j];
      until (j=namesize) or (newname[j]=' ');
      command[newspot+2+j]:=chr(0);
      
      gotoxy(bigdirline,1);
      cond:=system(command);
      gotoxy(messageline,1);
      if (cond<>0)
         then
         write('Error in renaming :',apath,'/',filelist[reg].name)
         else
         write('Renaming ',apath,'/',filelist[reg].name);
      end

      else
      begin
      gotoxy(messageline,1);
      write('Error- Cannot rename with tagged files.');
      cond:=1;
      end;
   end; 
      
procedure makedir;

(********************************************************************************

 Procedure makedir
 Purpose: This procedure determines the command and calls system with 'mkdir' +
          apath + newname. The procedure is not concerned with tagged files.

 Parameters: filelist, cond, apath
 Called by: getcom
 Calls: gotoxy, getname, addpathandname, system

 ********************************************************************************)

var i,j:integer; 
    foundtag:boolean;
    command:string256;
    newname:nametype;

   begin
   command[1]:='m';
   command[2]:='k';
   command[3]:='d';
   command[4]:='i';
   command[5]:='r';
   spot:=6;
   gotoxy(messageline,1);
   write('Enter new directory: ');
   getname(newname);
   addpathandname(newname,apath,command,spot,newspot);
   command[newspot+1]:=chr(0);
   gotoxy(bigdirline,1);
   cond:=system(command);
   gotoxy(messageline,1);
   if (cond<>0)
      then
      write('Error in making directory :',apath,'/',newname)
      else
      write('Making directory ',apath,'/',newname);
   end;

procedure remdir;

(********************************************************************************

 Procedure remdir
 Purpose: This procedure determines command by 'rmdir' + apath + filelist.name.
          Also, tagged files are no concern.

 Parameters: filelist, llist, cond, apath
 Called by: getcom
 Calls: addpathandname, gotoxy, system

 ********************************************************************************)

 
var i,j:integer; 
    command:string256;

   begin
   command[1]:='r';
   command[2]:='m';
   command[3]:='d';
   command[4]:='i';
   command[5]:='r';
   spot:=6;
   addpathandname(filelist[llist].name,apath,command,spot,newspot);
   command[newspot+1]:=chr(0);
   gotoxy(bigdirline,1);
   cond:=system(command);
   gotoxy(messageline,1);
   if (cond<>0)
      then
      write('Error in removing directory :',apath,'/',filelist[llist].name)
      else
      write('Removing directory ',apath,'/',filelist[llist].name);
   end;

procedure edit;

(********************************************************************************
 
 Procedure edit
 Purpose: This procedure determines command by 'vi' + apath + filelist.name.
          It is a single command, so multiple edits are not allowed.

 Parameters: filelist, llist, cond, apath
 Called by: getcom
 Calls: gettag, addpathandname, gotoxy, system

 ********************************************************************************)

var foundtag:boolean;
    command:string256;
    newname:nametype;

   begin
   bottllist:=1;
   gettag(filelist,bottllist,llist,reg,foundtag);

   (* if no tagged files are found proceed with system call *)

   if (not (foundtag))
      then
      begin
      command[1]:='v';
      command[2]:='i';
      spot:=3;
      addpathandname(filelist[llist].name,apath,command,spot,newspot);
      command[newspot+1]:=chr(0);
      gotoxy(bigdirline,1);
      cond:=system(command);
      gotoxy(messageline,1);
      if (cond<>0)
         then
         write('Cannot edit ',apath,'/',filelist[llist].name);
      end

      else
      begin
      gotoxy(messageline,1);
      write('Error- Cannot edit with tagged files.');
      cond:=1;
      end;
   end;


procedure view;

(*******************************************************************************

 Procedure view
 Purpose: This procedure determines command by 'more' + apath + filelist.name.
          Again, it is a single command so multiple views are invalid.

 Parameters: filelist, llist, cond, apath
 Called by: getcom
 Calls: gettag, addpathandname, gotoxy, system

 *******************************************************************************)

var foundtag:boolean;
    command:string256;
    newname:nametype;

   begin
   bottllist:=1;
   gettag(filelist,bottllist,llist,reg,foundtag);

   (* if no tagged files are found proceed with system call *)

   if (not (foundtag))
      then
      begin
      command[1]:='m';
      command[2]:='o';
      command[3]:='r';
      command[4]:='e';
      spot:=5;  
      addpathandname(filelist[llist].name,apath,command,spot,newspot);
      command[newspot+1]:=chr(0);
      gotoxy(bigdirline,1);
      cond:=system(command);
      gotoxy(messageline,1);
      if (cond<>0)
         then
         write('Cannot view ',apath,'/',filelist[llist].name);
      end

      else
      begin
      gotoxy(messageline,1);
      write('Error- Cannot view with tagged files.');
      cond:=1;
      end;
   end;



begin
end.     (* unit menuunit *)
  
   
