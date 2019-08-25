VPas Version 1.05 [30-Jan-89]


 0    1: {$X+}
 0    2: unit listpackunit;
 0    3: 
 0    4: (********************************************************************************
 0    5: 
 0    6:  unit listpackunit
 0    7:  Contents: this unit contains the linked list package, or all modules responsible
 0    8:            for manipulations on the linked list stored in an array of records.
 0    9:            
 0   10:  ********************************************************************************)
 0   11:            
 0   12: 
 0   13: interface
 0   14: 
 0   15: uses dirlsunit;
 0   16: 
 0   17: const namesize=14;      (* sizes of particular fields *)
 0   18:       datesize=6;
 0   19:       timesize=5;
 0   20:       llistsize=100;
 0   21:       rowsize=80;
 0   22:       dummyspace=31;    (* dummy space between d or - and size in ls.out *)
 0   23: 
 0   24: type
 0   25: 
 0   26: nametype=packed array[1..namesize] of char;
 0   27: 
 0   28: 
 0   29: (* type for a particular line in a directory *)
 0   30: 
 0   31:    linetype=record
 1   32:       name:nametype;
 1   33:       size:integer;
 1   34:       date:packed array[1..datesize] of char;
 1   35:       time:packed array[1..timesize] of char;
 1   36:       kind:boolean;
 1   37:       back,next:integer;
 1   38:       tag:boolean;
 1   39:    end;
 0   40: 
 0   41: filedir=array[1..llistsize] of linetype;       (* type for whole dir list *)
 0   42: filetype=array[1..2] of filedir;
 0   43: lastlisttype=array[1..2] of integer;
 0   44: 
 0   45: var
 0   46:    dir
 0   47:       :filetype;
VPas Version 1.05 [30-Jan-89]


 0   48: 
 0   49:    avail:integer;                 (* the next avail node *)
 0   50:    lastlist               (* the index for the current end of the list *)
 0   51:       :lastlisttype;
 0   52: 
 0   53:    listgreathun
 0   54:       :boolean;           (* TRUE if the current dir is more than 100 elem *)
 0   55: 
 0   56: 
 0   57: function size(filelist:filedir):integer;
 0   58: procedure getnode(var anylist:filedir;llist:integer;var avail:integer);
 0   59: procedure initlist(var anylist:filedir);
 0   60: procedure filllist(var filelist:filedir;var llist,avail:integer);
 0   61: 
 0   62: implementation
 0   63: 
 0   64: function size;
 0   65: 
 0   66: (****************************************************************************
 0   67: 
 0   68:  Function size
 0   69:  Purpose: This function determines the size of a directory
 0   70: 
 0   71:  Parameters: filelist
 0   72:  Called by: deladjustllist, getcom
 0   73:  Calls: none
 0   74: 
 0   75:  ****************************************************************************)
 0   76:  
 0   77: var endlist,count:integer;
 0   78:    begin
 1   79:    endlist:=1;
 1   80:    count:=1;
 1   81:    while (filelist[endlist].next<>0) do
 1   82:       begin
 2   83:       count:=count+1;
 2   84:       endlist:=filelist[endlist].next;
 2   85:       end;
 1   86:    size:=count;
 1   87:    end;
 0   88: 
 0   89: 
 0   90: procedure getnode;
 0   91: 
 0   92: (*****************************************************************************
 0   93: 
 0   94:  Procedure: getnode
VPas Version 1.05 [30-Jan-89]


 0   95:  Purpose: returns the index for the next available node 
 0   96: 
 0   97:  Parameters: anylist,lastlist,avail
 0   98:  Called by: filllist
 0   99:  Calls: none
 0  100: 
 0  101:  *****************************************************************************)
 0  102: 
 0  103:    begin
 1  104:       if (anylist[avail].next<>0) and (llist<>0) 
 1  105:          then
 1  106:          avail:=anylist[avail].next; 
 1  107:    end;
 0  108: 
 0  109: procedure initlist;
 0  110: 
 0  111: (*****************************************************************************
 0  112: 
 0  113:  Procedure: initlist
 0  114:  Purpose: fills the back and next indexes of the linked list in a linked
 0  115:           manner so that the back and next fields are linked together. If a
 0  116:           node were to be deleted, the back and next fields would have to be
 0  117:           altered accordingly to maintain the linked list.
 0  118: 
 0  119:  Parameters:  anylist
 0  120:  Called by: filllist
 0  121:  Calls: none
 0  122: 
 0  123:  *****************************************************************************)
 0  124:  
 0  125:    var i:integer;
 0  126:    begin
 1  127:    for i:=1 to llistsize do
 1  128:       begin
 2  129:       anylist[i].next:=i+1;
 2  130:       anylist[i].back:=i-1;
 2  131:       end;
 1  132:    anylist[llistsize].next:=0;
 1  133:   end;
 0  134: 
 0  135: 
 0  136: procedure filllist;
 0  137: 
 0  138: (*****************************************************************************
 0  139:  
 0  140:  Procedure filllist
 0  141:  Purpose: This procedure reads the current dir from ls.out and fills the linked
VPas Version 1.05 [30-Jan-89]


 0  142:           lists' nodes with the appropriate fields. Then, in either case of the 
 0  143:           dir being less than, equal to, or greater than 50 elements, the end
 0  144:           of the list is denoted by a zero in the next field following the
 0  145:           last full node.
 0  146: 
 0  147:  Parameters: anylist,lastlist,avail
 0  148:  Called by: setup, getcom 
 0  149:  Calls: getnode,initlist
 0  150: 
 0  151:  *********************************************************************************)
 0  152: 
 0  153: var t                (* counter *)
 0  154:        :integer;
 0  155:     dumchar,         (* dummy char *)
 0  156:     chr              (* chr which determines dir or not *)
 0  157:        :char;
 0  158: 
 0  159:    begin
 1  160:    listgreathun:=FALSE;
 1  161:    initlist(filelist);
 1  162:    reset(lsfvar,'/tmp/ls.out');
 1  163:    avail:=1;
 1  164:    llist:=0;
 1  165: 
 1  166:    (* fills list until eof or fills 50 nodes *)
 1  167: 
 1  168:    while ((filelist[avail].next)<>0) and (not (eof(lsfvar))) do
 1  169:       begin
 2  170:       
 2  171:       getnode(filelist,llist,avail);
 2  172:       if (llist=0)
 2  173:          then
 2  174:          begin
 3  175:          readln(lsfvar);
 3  176:          llist:=1;
 3  177:          end;
 2  178:       read(lsfvar,chr);   
 2  179:       if (chr='d')  
 2  180:          then
 2  181:          filelist[avail].kind:=TRUE
 2  182:          else
 2  183:          filelist[avail].kind:=FALSE;
 2  184:       filelist[avail].tag:=FALSE;
 2  185:       for t:=1 to dummyspace do
 2  186:          read(lsfvar,dumchar);
 2  187:       read(lsfvar,filelist[avail].size);
 2  188:       read(lsfvar,dumchar);
VPas Version 1.05 [30-Jan-89]


 2  189:       read(lsfvar,filelist[avail].date);
 2  190:       read(lsfvar,dumchar);
 2  191:       read(lsfvar,filelist[avail].time);
 2  192:       read(lsfvar,dumchar);
 2  193:       readln(lsfvar,filelist[avail].name);
 2  194: 
 2  195:       if (filelist[avail].next<>0) 
 2  196:          then
 2  197:          llist:=filelist[avail].next;
 2  198: 
 2  199:       end;
 1  200: 
 1  201:    if (not(eof(lsfvar))) 
 1  202:       then
 1  203:       listgreathun:=TRUE
 1  204: 
 1  205:       else
 1  206: 
 1  207:       (* sets zero in next field if dir is less than 100 elem *)
 1  208: 
 1  209:       if (filelist[avail].next<>0) then
 1  210:          filelist[filelist[llist].back].next:=0;
 1  211:      
 1  212:    end;
 0  213: 
 0  214: 
 0  215: begin
 1  216: end.   (* unit listpackunit *)
 0  217:    
 0  218: 
 0  219: 
 0  220: 
VPas Version 1.05 [30-Jan-89]


Procedures and functions

     FILLLIST (procedure) 60, 159
     GETNODE (procedure) 58, 103
     INITLIST (procedure) 59, 126
     SIZE (function) 57, 78
