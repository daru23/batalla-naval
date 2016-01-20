% Laboratorio de Lenguajes
% BATALLA NAVAL 
% Daniela Ruiz & Diego Millan
% 

:- dynamic (barco /7).
:- dynamic (municiones /1).
:- dynamic (cantidad_barco /1).

jugar:- crearTablero.

crearTablero:- 
					write('Num. de Filas: '),read(M), 
					write('Num. de Columnas: '),read(N),
					write('Cant. de Barcos: '),read(B),
					assert(cantidad_barco(B)),
					tableroInicial(M,N,L),
					crearBarcos(B,L,T),
					mostrarTablero(T),
					write('Cant. proyectiles disponibles: '), read(P),
					assert(municiones(P)),		
					ataque(T,Tf,M,N), 
%					revisar_todos(B,Tf,Tf1),
					mostrarTablero(Tf1).
%------------ Crea tablero inicial (todas las posiciones son agua) ------------%
tableroInicial(M,N,T):-crearT_aux(M,N,[],T), mostrarTablero(T).
crearT_aux(_,0,A,A).
crearT_aux(M,N,A,R):- N > 0,N1 is N-1,crearFila(M,L),crearT_aux(M,N1,[L|A],R).
% crear una lista con N elementos 'a'
crearFila(N,L):- crearF_aux(N,[],L).
crearF_aux(0,A,A).
crearF_aux(N,A,R):- N > 0, N1 is N-1, crearF_aux(N1,['a'|A],R).
%-------------------------- Muestra el tablero --------------------------------%
% imprime los elementos de una lista
mostrar_lista([]).
mostrar_lista([E|R]):- write(E), write(' '), mostrar_lista(R).
% imprime los elementos de una lista de listas (tablero)
mostrarTablero([]).
mostrarTablero([O|R]):- mostrar_lista(O), nl, mostrarTablero(R).
%-------------------------- Crear Barcos --------------------------------------%
%barco(Id,Tam,Dir,Fini,Cini,Status).
crearBarcos(0,T,T).
crearBarcos(N,L,T):- N1 is N-1,
							write('Informacion del Barco'),nl,
							write('Tamano: '),read(Tam),
							write('Direccion: '),read(Dir),
							write('Fila Inicial: '),read(Fini),
							write('Columna Inicial: '),read(Cini),
							assert(barco(N,Tam,Dir,Fini,Cini,0,'f')),						
							colocarB(Dir,Fini,Cini,Tam,N,L,A),
							crearBarcos(N1,A,T).	
%funcion auxiliar para modificar valores en el tablero
modificar_lista(0,S,[_|R],[S|R]).
modificar_lista(N,S,[E|R],[E|L]):- N1 is N-1, modificar_lista(N1,S,R,L).
%coloca los barcos ya sea horizontal o verticalmente 
colocarB('h',Fini,Cini,Tam,N,L,T):- colocarH(Fini,Cini,Tam,N,L,T).
colocarB('v',Fini,Cini,Tam,N,L,T):- colocarV(Fini,Cini,Tam,N,L,T).
%colocar barcos horizontales
colocarH_aux(_,0,_,T,T).	
colocarH_aux(C,Tam,S,E,L):-  	Tam>0,
										modificar_lista(C,S,E,L2),
										Tam1 is Tam-1, 
										C1 is C+1,
										colocarH_aux(C1,Tam1,S,L2,L).
colocarH(0,C,Tam,S,[E|R],[L|R]):- Tam>0, colocarH_aux(C,Tam,S,E,L).
colocarH(N,C,Tam,S,[E|R],[E|P]):- N1 is N-1, colocarH(N1,C,Tam,S,R,P).
%colocar barcos verticales
colocarV_aux(C,1,S,[E|R],[L|R]):- 		modificar_lista(C,S,E,L).
colocarV_aux(C,Tam,S,[E|R],[L|P]):- 	Tam>0, modificar_lista(C,S,E,L),
													N is Tam-1,
													colocarV_aux(C,N,S,R,P).
colocarV(0,C,Tam,S,[E|R],[L|P]):- colocarV_aux(C,Tam,S,[E|R],[L|P]).
colocarV(N,C,Tam,S,[E|R],[E|P]):- 	N1 is N-1, 
												colocarV(N1,C,Tam,S,R,P).
%--------------------------------- Atacar -------------------------------------% 
modificar_lista(0,['a'|R],['f'|R]):- !.
modificar_lista(0,['f'|R],['f'|R]):- !.
modificar_lista(0,['h'|R],['h'|R]):- !.
modificar_lista(0,['g'|R],['g'|R]):- !.
modificar_lista(0,[E|R],['g'|R]):- 	barco(E,T,D,F,C,G,S), T\==G, G1 is G+1, 
												write(G1), nl, 
												retract(barco(E,T,D,F,C,G,S)),
												assert(barco(E,T,D,F,C,G1,S)), !.
modificar_lista(0,[E|R],['h'|R]):- 	barco(E,G,D,F,C,G,S),  												
												retract(barco(E,G,D,F,C,G,S)),
												assert(barco(E,G,D,F,C,G,'h')), !.
modificar_lista(N,[E|R],[E|L]):- N1 is N-1, modificar_lista(N1,R,L). 

revisar_b(T0,T1):- cantidad_barco(B), revisar_todos(B,T0,T1).

revisar_todos(0,T,T).
revisar_todos(N,T0,T1):- N1 is N-1, revisar(N,T0,A),
								revisar_todos(N1,A,T1).

revisar(E,T0,T1):-	barco(E,T,D,F,C,G,S),T\=G, append(T0,[],T1), !.
revisar(E,T0,T1):- 	barco(E,T,D,F,C,G,S), T=G, 
							retract(barco(E,T,D,F,C,G,S)),
							assert(barco(E,T,D,F,C,G,'h')),
							colocarB(D,F,C,T,'h',T0,T1), !.


ataque(T0,T1,F,C):- municiones(N),  ataque_aux(0,0,F,C,T0,T1,N).
ataque_aux(_,_,F,C,T,T,0):-!.
ataque_aux(F,C1,F,C,T0,T1,N):-C1<C, C2 is C1+1,N \=0,
										ataque_aux(0,C2,F,C,T0,T1,N).
ataque_aux(F1,C1,F,C,T0,T1,N):-F1<F, C1<C,
										F2 is F1+1,N \=0,
										disparar(F1,C1,T0,A),
										N1 is N-1,
										mostrarTablero(A), nl,
										revisar_b(A,B),
										ataque_aux(F2,C1,F,C,B,T1,N1).

disparar(0,C2,[E|R],[F|R]):- modificar_lista(C2,E,F).
disparar(C1,C2,[E|R],[E|P]):- C is C1-1, disparar(C,C2,R,P).
%------------------------------------------------------------------------------%
estadoFinal(T):- final_aux(T).
final_aux([]).
final_aux([E|R]):- revisar_lista(E), final_aux(R).
revisar_lista([]).
revisar_lista(['a'|B]):- revisar_lista(B).
revisar_lista(['f'|B]):- revisar_lista(B).
revisar_lista(['h'|B]):- revisar_lista(B).
