{$X+}
program mos;

(********************************************************************************
 *										*
 * Program: mos 								*
 * Programmer: Greg Fudala							*
 * Soc. sec #: xxx-xx-xxxx							*
 * Due date: April 24, 1989							*
 * System: Apple Mac II								*
 * Compiler: VP 1.05								*
 *										*
 *                                   Purpose        				*
 *										*
 * This program is MOS, the menu operating system. It allows the user to        *
 * view and manipulate directories under the UNIX operation system.             *
 *   										*
 * The screen consists of two directories. Upon execution, both directories     * 
 * are the current directory- (where the command to execute MOS was from)       *
 * The user is allowed to traverse the directory. This is done two ways. The    *
 * user can press the up & down arrow keys to move in the directory up and      *
 * down respectively, or skipping twenty files at a time, up or down, is        *
 * allowed. Also, the user may toggle between the two directories. Note:        * 
 * the program is limited to a maximum of one-hundred files and or directories  *
 * in a directory list.                                                         * 
 *										*
 * In addition, the user may enter other directories. In this way, it is        *
 * possible to display any two-directory combination at once in the directory   *
 * hierarchy. 									*
 *										*
 * The main feature of the program is the capability to perform UNIX operating  *
 * system commands between the two directories displayed. The commands cp,      *
 * rm, more, vi, mkdir, rmdir, & mv can be accessed. Also, several of these     *
 * commands can performed in multiples. In this way, the user can tag a group   *
 * of files and has the choice to perform a cp, rm, or mv routine. Another      *
 * feature enables the user to un-tag all files in a directory at once. The     *
 * pathname for the directory appears beneath each directory list.              *
 * When the user has completed his or her tasks, the exit command returns the   *
 * user to the directory from where he or she first executed MOS.               *  
 *										*
 * Input: Input is mainly directly from the user. However, the program does     *
 *        access the external devices by calling the system routine, another    *
 *        from of input. 							*
 *										*
 * Output: The only output is printed to the screen and written to external     *
 *         files /tmp/ls/out and /tmp/pwd.out. 					*
 *										*
 ********************************************************************************)

uses rawio,introunit,dirlsunit,listpackunit,menuunit,browunit;

var k:integer;

begin
direct_io;     (* turns off keyboard buffering *)

(* initial introduction *)

clearscreen;
startupscreen;
clearscreen;
helpscreen;
clearscreen;
callprint(path[1]);
callprint(path[2]);

(* fill the list and show it. Then, allow traversing and moving in the directory
   hierarchy *)

gotoxy(1,1);
inverseon;
writeln(menubar);
inverseoff;
gotoxy(2,1);
write(filehead);
gotoxy(2,41);
write(filehead);
k:=1;
setup(dir[1],k,combar[1],lastlist[1],avail,start[1],path[1]);
listls(lsfvar);
k:=2;
setup(dir[2],k,combar[2],lastlist[2],avail,start[2],path[2]);
k:=1;
getcom(dir[1],dir,k,lastlist[1],start[1],combar[1],listgreathun,path[1]);

end.   (* main- mos *)

