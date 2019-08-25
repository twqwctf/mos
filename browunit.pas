{$X+}
unit browunit;

(*******************************************************************************
 
 unit browunit  
 
 contents: This unit, the largest unit of the program, contains all modules that
           are responsible for the user's input, that is, all input such as the 
           menu bar functions and the other functions such as traversing up and
           down, paging up and down, and entering different directories. Also
           included are the modules responsible for the path manipulation. 

 *******************************************************************************)

interface

uses rawio,introunit,dirlsunit,listpackunit,menuunit; 

const
   sizespot=15;         (* constants for where to print a field on the screen *)
   datespot=23;
   timespot=31;
   kindspot=38;
   pathspot=24;
   errorrow=28;
   thirtynine=39;
   forty=40;
   fortyone=41;
   

type
   starttype=array[1..2] of integer;   (* array type for the index position
                                          of the topmost index on the screen *)    

   combartype=array[1..2] of integer;  (* array type for the current command
                                          bar position *)

var
   combar                              (* command bar variable *)
      :combartype;                      
   start                               (* topmost index position variable *)
      :starttype;               

   adddupdir,                          (* boolean to determine if the opposite
                                          directory needs to be reprinted in case
                                          of an addition to the currect directory *) 

   deldupdir                           (* identical to 'adddupdir' but in case of
                                          a deletion or multiple deletion from the
                                          current directory *)
      :boolean;
   oldsize                             (* holds the size of a directory before any
                                          changes are made *)
      :integer;                         
   quit
      :boolean;                        (* boolean to determine when to end mos *)


procedure notifyendlist;
procedure adjustpath  (var thepath:string256);
procedure printpath   (firstpath,secondpath:string256);
procedure printline   (var filelist:filedir;index:integer;
                       var llist:integer;currrow:integer);
procedure showlist    (var filelist:filedir;index,llist:integer;
                       var listgreathun:boolean);
procedure showbar     (var filelist:filedir;index:integer;var acombar,llist:integer);
procedure showline    (var filelist:filedir;index:integer;var llist,acombar:integer);
procedure traverseup  (var filelist:filedir;
                       var index,acombar,astart,llist:integer);
procedure traversedown(var filelist:filedir;
                       var index,acombar,astart,llist:integer);
procedure getnewpath  (var filelist:filedir;var llist:integer;var apath:string256);
procedure pagedown    (var filelist:filedir;var index,llist,astart,acombar:integer;
                       var apath:string256);
procedure pageup      (var filelist:filedir;var index,llist,astart,acombar:integer;
                       var apath:string256);
procedure setup       (var filelist:filedir;var index,acombar,llist,
                       avail,astart:integer;var apath:string256);
procedure tagfile     (var filelist:filedir;var llist:integer);
procedure untagall    (var filelist:filedir;var llist,index,acombar:integer;
                       var listgreathun:boolean);
procedure addadjustllist(var filelist:filedir;var llist,astart,acombar:integer);
procedure deladjustllist(var filelist:filedir;var llist,astart,acombar,oldsize:integer);
procedure reprint     (var dir:filetype;var index:integer);
procedure getcom      (var filelist:filedir;var dir:filetype;var index,llist,
                       astart,acombar:integer;
                       var listgreathun:boolean;var apath:string256);
implementation


procedure notifyendlist;

(*******************************************************************************
 
 Procedure: notifyendlist
 Purpose: This procedure notifys the user that he/she has reached the end of
          the directory while traversing.	

 Parameters: none      
 Called by: procedure traversedown, traverseup, pagedown, pageup 
 Calls: none 

 *******************************************************************************)
 
   begin
   gotoxy(errorrow,1);
   write('Reached end of list');
   end;

procedure adjustpath;

(*******************************************************************************

 Procedure: adjustpath
 Purpose: if a path becomes greater than 39 characters long, this procedure accepts
          the path as a value parameter and adjusts it so that the rightmost 36
          characters appear at the right preceded by three periods-(...) 

 Parameters: a path (thepath)
 Called by: procedure printpath
 Calls: none

 *******************************************************************************)
 
var i:integer;
   begin
   for i:=1 to 3 do
      thepath[i]:='.';
   for i:=4 to thirtynine do
      thepath[i]:=thepath[(pathsize(thepath)-36)+(i-3)];
   end;


procedure printpath;

(********************************************************************************

 Procedure : printpath
 Purpose: This procedure accepts the two paths (path[1],path[2]), adjusts them if
          necessary, and prints them to the appropriate spot on the screen.

 Parameters: the two paths- path[1] and path[2]
 Called by: procedure showlist
 Calls: proc. gotoxy, inverseon, inverseoff, & adjustpath

 ********************************************************************************)
 
 var i,rearr:integer;
   begin
      
   if (pathsize(firstpath)>forty)
      then
      adjustpath(firstpath);
   if (pathsize(secondpath)>forty)
      then
      adjustpath(secondpath);
   
   gotoxy(pathspot,1);
   write('                                                                                       ');
   gotoxy(pathspot,1);
   inverseon;
   i:=0;
   repeat
      i:=i+1;
      write(firstpath[i]);
   until (i=thirtynine);
   gotoxy(pathspot,fortyone);
   i:=0;
   repeat
      i:=i+1;
      write(secondpath[i]);
   until (i=thirtynine);
   inverseoff;
   end;


procedure printline;

(****************************************************************************** 
 
 Procedure: printline
 Purpose: This procedure takes in the currentrow, currrow, and the filelist
          and lastlist and then writes a line of the currect directory
          at the appropriate spot on the screen, each field printed
          separately.

 Parameters: filelist, index, currrow, and llist
 Called by: showlist,showbar,showline & getcom
 Calls: gotoxy

 ******************************************************************************)

 var add:integer;
   begin
      if (index=2) then 
         add:=forty
         else
         add:=0;
         
      gotoxy(currrow,1+add);
      write(filelist[llist].name);
      gotoxy(currrow,sizespot+add);
      write(filelist[llist].size);
      gotoxy(currrow,datespot+add);
      write(filelist[llist].date);
      gotoxy(currrow,timespot+add);
      write(filelist[llist].time);
      gotoxy(currrow,kindspot+add);
      if (filelist[llist].kind)
         then
         write('dir')
         else
      if (filelist[llist].tag)
         then
         write('tag')
         else
         write('   ');
   end;

procedure showlist;

(******************************************************************************
 
 Procedure: showlist
 Purpose: this procedure prints out the appropriate section of the directory
          to be traversed.

 Parameters: filelist,index,llist,listgreathun
 Called by: procedures traverseup, traversedown, pageup, pagedown, setup, untagall,
            reprint, & getcom 
 Calls: printline, gotoxy, printpath

 ******************************************************************************)
 
var currrow:integer;
   begin
   currrow:=mincombar;
   while(llist<>0) and (currrow<=maxcombar) do
      begin  
      printline(filelist,index,llist,currrow);
      currrow:=currrow+1;
      llist:=filelist[llist].next;
      end;           

   if (index=1)
      then
      gotoxy(bigdirline,1)
      else
      gotoxy(bigdirline,fortyone);
   if (listgreathun)
      then
      write('Directory greater than 100 files/dirs')
      else
      write('                                     ');

      
   printpath(path[1],path[2]);
   end;

procedure showbar;

(*******************************************************************************
 
 Procedure: showbar
 Purpose: prints the inverse video version of a line in the directory.       

 Parameters: filelist,index,combar,llist
 Called by: procedure getcom
 Calls: gotoxy,printline,inverseon,inverseoff

 *******************************************************************************)

   begin
   gotoxy(acombar,1);
   inverseon;
   printline(filelist,index,llist,acombar);
   inverseoff;
   end;

procedure showline;

(*******************************************************************************

 Procedure: showline
 Purpose: prints the normal video version of a line in the directory           

 Parameters: filelist,index,combar,lastlist
 Called by: procedure traverseup, traversedown, pageup, pagedown, & getcom
 Calls: gotoxy,printline

 *******************************************************************************)

   begin
   gotoxy(acombar,1);
   printline(filelist,index,llist,acombar);
   end;


procedure traverseup;

(*******************************************************************************
 
 Procedure traverseup
 Purpose: This procedure is responsible for allowing the user to traverse up
          the directory one by one. 

 Parameters: a file list, index, acombar, astart, and llist
 Called by: procedure getcom
 Calls: showbar, showline, showlist, notifyendlist

 *******************************************************************************)

var backcombar:integer;
   begin
   if (acombar>mincombar)            (* not at top of list *)
      then
      begin 
      acombar:=acombar-1;
      llist:=filelist[llist].back;

      if (acombar<maxcombar)         (* not at bottom of list *)  
         then
         begin
         backcombar:=acombar+1;
         showline(filelist,index,filelist[llist].next,backcombar); 
         end;

      end

      else                           (* command bar somewhere in middle of list *)
      if (llist<>1)
         then
         begin
         llist:=filelist[llist].back;
         astart:=astart-1;
         showlist(filelist,index,astart,listgreathun);
         end 

         else
         notifyendlist;
      
   end;


procedure traversedown;

(*******************************************************************************

 Procedure traversedown
 Purpose: This procedure is responsible for allowing the user to traverse down
          the directory one by one.

 Called by: getcom
 Calls: showbar, showline, showlist, notifyendlist

 *******************************************************************************)
 
var backcombar:integer;
   begin
   if (filelist[llist].next<>0)
      then
      begin
      if (acombar<maxcombar)         (* if not at bottom of list *)
         then
         begin
         acombar:=acombar+1;
         llist:=filelist[llist].next;
         if (acombar>mincombar)      (* if not at top of list *)
            then
            begin
            backcombar:=acombar-1;
            showline(filelist,index,filelist[llist].back,backcombar);
            end;
 
         end
 
         else                        (* command bar somewhere in middle of list *)
         begin
         llist:=filelist[llist].next;
         astart:=astart+1;
         showlist(filelist,index,astart,listgreathun);
         end;

      end

      else
      notifyendlist;
   end;

procedure getnewpath;

(*******************************************************************************

 Procedure getnewpath
 Purpose: This procedure, once a new directory is being entered, adjusts the 
          current path accordingly. 

 Parameters: filelist, llist, & apath
 Called by: getcom
 Calls: gotoxy, append, ls & listls

 *******************************************************************************)

var i,j,                                
    origpathsize,addpathsize:integer;  
    addpath:string20;
    chr0:char;

   begin
   chr0:=chr(0); 
   origpathsize:=0;
   addpathsize:=0;
   for i:=1 to namesize do      (* clear out the path to be added *)
      addpath[i]:=' ';
   i:=0;

   (* determine the size of the original path *)

   repeat
      i:=i+1;
      origpathsize:=origpathsize+1;  (* determines size + 1 *) 
   until (apath[i]=chr0);

   
   apath[origpathsize]:='/';
   apath[origpathsize+1]:=chr0;
   i:=0;
   gotoxy(32,1);
 
   (* fill the packed array, addpath, with the name to be added *)

   repeat
      i:=i+1;
      if (i<=namesize)
         then
         begin
         addpath[i]:=filelist[llist].name[i];
         addpathsize:=addpathsize+1;
         end;
   until (addpath[i]=' ') or (i=namesize);

   if (ord(addpath[i])<>32) and (addpathsize=namesize)
      then
      addpathsize:=addpathsize+1;
   i:=0;
   addpath[addpathsize+1]:=chr0; 
 
   (* if the current position is the 'dot-dot' file *)

   if (filelist[llist].name='..            ')
      then
      begin

      if (origpathsize=2) then
         begin
         for i:=2 to addpathsize do
            addpath[i-1]:=addpath[i];
         addpath[addpathsize]:=chr0;
         addpathsize:=addpathsize-1;
         end;

      i:=string256size+1;
      for j:=1 to 2 do
         repeat
            i:=i-1;
            apath[i]:=' ';
         until (apath[i-1]='/');
        

      j:=namesize+1;
      repeat
         j:=j-1;
         addpath[j]:=' ';
      until (j=1);
   
      if (i<>2)
         then
         apath[i-1]:=chr0
         else
         apath[i]:=chr0;
      

      end

      else    (* if the current position isn't the 'dot-dot' file *)

      if (origpathsize=2)
         then
         begin
         for i:=2 to origpathsize+addpathsize do
            apath[i-1]:=apath[i];

         for i:=(origpathsize+addpathsize) to 256 do
            apath[i]:=' ';
         origpathsize:=origpathsize-1;
         end;
         
      (* add addpatih to apath *)
         
      append(apath,addpath,origpathsize+1);
      apath[origpathsize+addpathsize]:=chr0;

      ls(apath);
      listls(lsfvar);
   end;

procedure pagedown;

(*********************************************************************************

 Procedure pagedown
 Purpose: This procedure allows the user to page twenty files down in the directory.

 Parameters: filelist, index, llist, astart, acombar & apath
 Called by: getcom
 Calls: clearhalfscreen, showlist, showline
 
 *********************************************************************************)

var i,tmpllist,cnt,diff:integer;

   begin
   cnt:=0;
   tmpllist:=llist;

   (* move llist up twenty times or until hit the end of the list *)  

   while (filelist[llist].next<>0) and (cnt<>20) do
      begin
      cnt:=cnt+1;
      llist:=filelist[llist].next;
      end;

   (* if llist is not at the end, show the list from that position, llist, and
      adjust llist to accomodate for retaining the same position on the screen *)

   if (filelist[llist].next<>0)
      then
      begin
      clearhalfscreen(index);
      showlist(filelist,index,llist,listgreathun);
      for i:=1 to (acombar-3) do
         begin
         if (filelist[llist].next<>0)
            then
            llist:=filelist[llist].next
            else
            acombar:=acombar-1;
         end;

      astart:=llist;
      for i:=(acombar-1) downto mincombar do
         astart:=filelist[astart].back;
      end

   {---------------------------------------------------}

      (* the end of the list was reached *)

      else
      begin
      diff:=maxcombar-acombar;

      (* if the end of the list is found to be off of the current list displayed 
         on the screen *)

      if (cnt>diff)           
         then
         begin
         clearhalfscreen(index);
         if (acombar=mincombar)    (* if the command bar position is at the
                                      topmost position *)
            then
            begin
            cnt:=cnt-1;
            tmpllist:=filelist[tmpllist].next;
            end;
         acombar:=mincombar+cnt;
         if (acombar>maxcombar)    (* if acombar, after adjusted, is greater than
                                      its most lower possible position *) 
            then
            begin
            acombar:=maxcombar;
            tmpllist:=filelist[tmpllist].next;
            end;
         showlist(filelist,index,tmpllist,listgreathun);

        (* adjust llist to retain the same command bar position *)

         astart:=llist;
         for i:=(acombar-1) downto mincombar do
            astart:=filelist[astart].back;
         end

         (* if the end of the llist is displayed on the screen *)

         else
         begin
         if (filelist[tmpllist].back<>0)
            then
            begin
            showline(filelist,index,filelist[filelist[tmpllist].back].next,acombar); 
            notifyendlist;
            end
            else
            showline(filelist,index,filelist[filelist[tmpllist].next].back,acombar); 
            
         for i:=1 to cnt do
            acombar:=acombar+1;
         end;
     end;
   end;
         

procedure pageup;

(*******************************************************************************

 Procedure pageup
 Purpose: This procedure allows the user to page up the directory by twenty times.

 Parameters: filelist, index, llist, astart & acombar
 Called by: getcom
 Calls: clearhalfscreen, showlist, showline

********************************************************************************)

var i,tmpllist,tmpcombar,cnt,diff:integer;
   begin
   cnt:=0;
   tmpllist:=llist;

   (* move llist back twenty times or until reach end of list *)

   while (filelist[llist].back<>0) and (cnt<>20) do
      begin
      cnt:=cnt+1;
      llist:=filelist[llist].back;
      end;

   (* adjust llist further back to show the list however much the above loop
      pushed llist back + the space between the uppermost position and the
      previous llist *)

   tmpcombar:=acombar;
   while (filelist[llist].back<>0) and (tmpcombar>mincombar) do
      begin
      tmpcombar:=tmpcombar-1;
      llist:=filelist[llist].back;
      end;

   (* if llist was moved back twenty times *)

   if (filelist[llist].back<>0)
      then
      begin
      clearhalfscreen(index);
      showlist(filelist,index,llist,listgreathun);

      (* adjust llist again to retain same command bar position *)
  
      for i:=1 to (acombar-3) do
         begin
	 if (filelist[llist].next<>0)
 	    then
            llist:=filelist[llist].next
            else
            acombar:=acombar-1;
         end;

      astart:=llist;

      (* adjust the starting (topmost index) variable *)
 
      for i:=(acombar-1) downto mincombar do
         astart:=filelist[astart].back;
      end

      {----------------------------------------------------}

      else                  (* the end of the list was reached before reducing
                               llist twenty times *)
      begin
      diff:=(maxcombar-(maxcombar-acombar))-mincombar;

      (* if the end of the list does not appear on the screen *)

      if (cnt>diff)
         then
         begin
         clearhalfscreen(index);
         if (acombar=maxcombar)
            then
            begin
            cnt:=cnt+1;
            tmpllist:=filelist[tmpllist].back;
            end;

         showlist(filelist,index,llist,listgreathun);
         acombar:=mincombar;
         astart:=1;
         end

         (* the end of the list appears on the screen *)

         else
         begin

         (* if at end of list *)
 
         if (filelist[tmpllist].next<>0)
            then
            begin
            showline(filelist,index,filelist[filelist[tmpllist].next].back,acombar);
            notifyendlist;
            end

            (* if not at end of list *)

            else
            showline(filelist,index,filelist[filelist[tmpllist].back].next,acombar);
            acombar:=mincombar;
            end;
         end;
   end;

       
       

procedure setup;

(********************************************************************************

 Procedure setup
 Purpose: This procedure is called by the main program to initially setup the
          linked lists and show then on the screen. It is called with both 
          indexes, that is, both linked lists (dir[1],dir[2]) are filled and
          both are printed uniquely. Later, it may be called if another 
          directory is entered. 

 Parameters: filelist, index, acombar, llist, avail, astart & apath
 Called by: main program & getcom
 Calls: clearhalfscreen, filllist, showlist

 ********************************************************************************)

   begin
   clearhalfscreen(index);
        
   llist:=1;
   filllist(filelist,llist,avail);
   llist:=1;
   showlist(filelist,index,llist,listgreathun);

   acombar:=mincombar;
   llist:=1;
   astart:=1;
   end;

procedure tagfile;

(*********************************************************************************

 Procedure tagfile
 Purpose: This procedure assigns the field, tag, to an element of the linked list
          if it is not a directory.

 Parameters: filelist, llist
 Called by: getcom
 Calls: gotoxy

 ********************************************************************************)

   begin
   if not (filelist[llist].kind)
      then
      begin
      filelist[llist].tag:=TRUE;
      end 
 
      else
      begin
      gotoxy(errorrow,29);
      write('Cannot tag directorys');
      end;
   end;

      
procedure untagall;

(********************************************************************************

 Procedure untagall
 Purpose: This procedure traverses the linked list and sets every tag field 
          to false and re-shows the list 

 Parameters: filelist, llist, index, acombar, listgreathun 
 Called by: getcom
 Calls: showlist

 ********************************************************************************)

var tmpllist,i:integer;
   begin
   for i:=1 to llistsize do
      filelist[i].tag:=FALSE;
   tmpllist:=llist;
   for i:=acombar downto mincombar+1 do
      tmpllist:=filelist[tmpllist].back;
   showlist(filelist,index,tmpllist,listgreathun);
   end;


procedure addadjustllist;

(********************************************************************************

 Procedure addadjustllist
 Purpose: This procedure adjusts llist (current index) if an addition has been 
          made to a directory.

 Parameters: filelist, llist, astart, acombar
 Called by: getcom 
 Calls: none

 ********************************************************************************)
  
var i:integer;
   begin
   llist:=astart;
   for i:=mincombar to acombar-1 do
      llist:=filelist[llist].next;
   end;

procedure deladjustllist;

(********************************************************************************

 Procedure deladjustllist
 Purpose: This procedure adjusts llist (current index) if one or more deletions
          have been made in a directory.

 Parameters: filelist, llist, astart, acombar, oldsize
 Called by: getcom
 Calls: none

 ********************************************************************************)

var i,newsize,numrem:integer;
   begin
   newsize:=size(filelist);
   numrem:=oldsize-newsize;
   i:=0;
   while (i<=numrem) and (astart>1) do
      begin
      astart:=filelist[astart].back; 
      i:=i+1;
      end;
   llist:=astart;
   acombar:=mincombar;
   end;
  
procedure reprint;

(********************************************************************************

 Procedure reprint
 Purpose: This procedure re-prints the entire screen after returning from an 
          edit or view function.

 Parameters: dir (applicable to both lists) and index
 Called by: getcom
 Calls: clearscreen, gotoxy. inverseon, inverseoff, showlist

 ********************************************************************************)

var l:integer;
   begin
   clearscreen;
   gotoxy(1,1);
   inverseon;
   writeln(menubar);
   inverseoff;
   gotoxy(2,1);
   write(filehead);
   gotoxy(2,fortyone);
   write(filehead);
   showlist(dir[index],index,start[index],listgreathun);
   if (index=1) then l:=2
      else l:=1;
   showlist(dir[l],l,start[l],listgreathun);
   end; 

procedure getcom;

(*******************************************************************************

 Procedure: getcom
 Purpose: This procedure allows the user to traverse a directory, and enter into
          subdirectorys and higher directorys. Also, the user can enter command
          bar functions which allow him or her to perform normal unix system 
          commands on the directories dsplayed. The procedure checks for user
          input and reacts according to the specifications on the assignment
          sheet. A case statement is responsible for determining which procedure
          to call given user input. 

 Parameters: filelist, dir, index, llist, astart, acombar, listgreathun, apath
 Called by: main program and itself (recursive)
 Calls: samepath, filllist, addadjustllist, deladjustllist, clearhalfscreen,
        showlist, showbar, gotoxy, traverseup, traversedown, getnewpath, setup,
        printline, pagedown, pageup, tagfile, untagall, copy, move, deletefile,
        rename, makedir, remdir, edit, view, ls, listls & itself (recursive)

 *******************************************************************************)  
  
const
   enter=32;
   space=32;
   up='A';
   down='B';
   tab=9;
   upperD=100;
   lowerd=68;
   upperU=117;
   loweru=85;
   ordzero=48;
   ordone=49;
   ordtwo=50;
   ordthree=51;
   ordfour=52;
   ordfive=53;
   ordsix=54;
   ordseven=55;
   ordeight=56;
   ordnine=57;
   ordshiftnine=40;
    
var 
    ordch,           (* the ordinal of a character *)
    i,               (* loop control var *)
    l,               (* contains the index opposite the current directory *)
    cond             (* return value of system procedure *)
       :integer;
    cmd:string256;
    chrescape:char;  (* char variable which holds chr(escape) *)
    ch,              (* assigned to getchar for user input *)
    chr0,            (* chr function of zero *)
    dummychar        (* assigned to getchar- dummy *)
       :char;

   begin
   chrescape:=chr(escape);
   chr0:=chr(0);

   (* repeat loop for getting user input *)

   if (not(quit)) then

   repeat

      (* if an addition has been made to a directory and the directories are the 
         same, the opposite to the current directory must be re-printed *)

      if (adddupdir)
         then
         if (samepath(path[1],path[2]))
            then 
            begin
            if (index=1) then l:=2
               else l:=1;
            filllist(dir[l],lastlist[l],avail);
            addadjustllist(dir[l],lastlist[l],start[l],combar[l]); 
            clearhalfscreen(l);
            showlist(dir[l],l,start[l],listgreathun);
            end;

      (* similar to the above adddupdir condition but if one or more deletions
         have been made to the current directory *)

      if (deldupdir)
         then
         if (samepath(path[1],path[2]))
            then 
            begin
            if (index=1) then l:=2
               else l:=1;
            filllist(dir[l],lastlist[l],avail);
            deladjustllist(dir[l],lastlist[l],start[l],combar[l],oldsize);
            clearhalfscreen(l);
            showlist(dir[l],l,start[l],listgreathun);
            end;
      
 
      adddupdir:=FALSE;
      deldupdir:=FALSE;
      
      showbar(filelist,index,acombar,llist);
      gotoxy(26,1);
      ch:=getchar;
      write(chrescape,'[J');
      ordch:=ord(ch);

      (* the next if-then gets the extra ordinal values out of the way if a 
         char which returns multiple ordinal values is entered *)

      if ordch=27 then
         begin
         ch:=getchar;
         ch:=getchar;
         end;

      if ch='A'
         then 
         traverseup(filelist,index,acombar,astart,llist)
         else

      if ch='B'
         then
         traversedown(filelist,index,acombar,astart,llist)
         else

      (* case statement for the many possible user inputs *)
              
      case ordch of

      enter,space:           (* entering another directory *)
          begin
          if (filelist[llist].kind) then
             begin
             if (filelist[llist].name='.             ')
                then
                begin
                gotoxy(errorrow,1);
                writeln('Current directory');
                end

                else
                begin
                getnewpath(filelist,llist,apath);
                setup(filelist,index,acombar,llist,avail,astart,apath);
                end;
             end;
          end;

       tab:                   (* toggling *) 
           begin
           printline(filelist,index,llist,acombar);
           if (index=1) then index:=2
                    else index:=1;
           getcom(dir[index],dir,index,lastlist[index],start[index],
                 combar[index],listgreathun,path[index]);
           end;

       

       upperD,lowerd :        (* paging down *)  
          pagedown(filelist,index,llist,astart,acombar,apath);

       upperU,loweru :        (* paging up *)
          pageup  (filelist,index,llist,astart,acombar,apath);

       ordnine :              (* tagging file *) 
          tagfile(filelist,llist);

       ordshiftnine :         (* untagging all files *)
          untagall(filelist,llist,index,acombar,listgreathun);

       ordone :               (* copying a file to non-current directory *)
          begin
          if (index=1) then l:=2
             else l:=1;
          copy(filelist,llist,cond,path[index],path[l]);
          if (cond=0)
             then
             begin
             ls(path[l]);
             listls(lsfvar);
             filllist(dir[l],lastlist[l],avail);
             showlist(dir[l],l,start[l],listgreathun);
             addadjustllist(dir[l],lastlist[l],start[l],combar[l]);
             end;
          end;

       ordseven :             (* moving file to non-current directory *)
          begin
          l:=index;
          if (l=1) then l:=2
             else l:=1;
          move(filelist,llist,cond,path[index],path[l]);
          if (cond=0)
             then
             begin
             oldsize:=size(filelist);
             ls(path[l]);           (* destination list *)
             listls(lsfvar);
             filllist(dir[l],lastlist[l],avail);
             showlist(dir[l],l,start[l],listgreathun);
             addadjustllist(dir[l],lastlist[l],start[l],combar[l]);
          
             ls(path[index]);            (* current list *)
             listls(lsfvar);
             filllist(filelist,llist,avail);
             deladjustllist(filelist,llist,astart,acombar,oldsize);
             clearhalfscreen(index);
             showlist(filelist,index,astart,listgreathun);
             end;
          end;

       ordtwo :               (* deleting a file in current directory *) 
          begin
          deletefile(filelist,llist,cond,path[index]);
          if (cond=0)
             then
             begin
             oldsize:=size(filelist);
             ls(path[index]);            (* current list *)
             listls(lsfvar);
             filllist(filelist,llist,avail);
             deladjustllist(filelist,llist,astart,acombar,oldsize);
             clearhalfscreen(index);
             showlist(filelist,index,astart,listgreathun);
             deldupdir:=TRUE;
             end;
          end;

       ordeight :              (* renaming a file in current directory *)
          begin
          rename(filelist,llist,cond,apath);
          if (cond=0)
             then
             begin
             ls(apath);
             listls(lsfvar);
             filllist(filelist,llist,avail);
             showlist(filelist,index,astart,listgreathun);
             addadjustllist(filelist,llist,astart,acombar);
             adddupdir:=TRUE;
             end;
          end;

       ordfive :               (* making a new directory in current dir *) 
          begin
          makedir(filelist,cond,apath);
          if (cond=0)
             then
             begin
             ls(apath);
             listls(lsfvar);
             filllist(filelist,llist,avail);
             showlist(filelist,index,astart,listgreathun);
             addadjustllist(filelist,llist,astart,acombar);
             adddupdir:=TRUE;
             end;
          end;
                
       ordsix :                (* removing a dir in current dir *) 
          begin
          remdir(filelist,llist,cond,apath);
          if (cond=0)
             then
             begin
             oldsize:=size(filelist);
             ls(apath);
             listls(lsfvar);
             filllist(filelist,llist,avail);
             deladjustllist(filelist,llist,astart,acombar,oldsize);
             clearhalfscreen(index);
             showlist(filelist,index,astart,listgreathun);
             deldupdir:=TRUE;
             end;
          end;

       ordfour :               (* editing (vi) a file *)
          begin
          edit(filelist,llist,cond,apath);
          if (cond=0)
             then
             begin
             gotoxy(35,1);
             write('HIT A KEY TO RETURN TO MOS');
             dummychar:=getchar;
             reprint(dir,index);            
             end;
          end;
             
       ordthree :              (* viewing (more) a file *)
          begin
          view(filelist,llist,cond,apath);
          if (cond=0) 
             then
             begin
             gotoxy(35,1);
             write('HIT A KEY TO RETURN TO MOS');
             dummychar:=getchar;
             reprint(dir,index);
             end;
          end;

       ordzero :
          begin
          quit:=TRUE;
          cmd[1]:='r';
          cmd[2]:='e';
          cmd[3]:='s';
          cmd[4]:='e';
          cmd[5]:='t';
          i:=system(cmd);
          clearscreen;
          writeln('Exit MOS - Menu Operating System - Version 1.0');
          end;

         else
         begin
         gotoxy(errorrow,1);
         write('invalid key');
         end;

    end; (* case *)

    until (quit);

    end;  (* proc. getcom *)


begin
end.    (* unit browunit *)   
                     
     
