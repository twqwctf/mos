# exec. image mos dependant on the following:

mos : introunit.o dirlsunit.o listpackunit.o menuunit.o browunit.o
	vp -x rawio.o introunit.o dirlsunit.o listpackunit.o menuunit.o browunit.o \
        mos.pas

# separate unit compilation statements

introunit.o : introunit.pas
	vp -c introunit.pas

dirlsunit.o : dirlsunit.pas
	vp -c dirlsunit.pas

listpackunit.o : listpackunit.pas
	vp -c listpackunit.pas

menuunit.o : menuunit.pas
	vp -c menuunit.pas

browunit.o : browunit.pas 
	vp -c browunit.pas


