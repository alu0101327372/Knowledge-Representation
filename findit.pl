/*
 * Universidad de La Laguna
 * Inteligencia Artificial
 * @author Marco Antonio Cabrera Hernández - alu0101327372
 * @email alu0101327372@ull.edu.es
 */
use_module(biblioteca(persistency)).

%%%%% Reglas para el control del jueir ----------------------------------------
start:-
  write('Bienvenido a Find the llave'), nl,
  write('Te despiertas en una ciudad extraña, pero no recuerdas cómo llegaste allí...'), nl,
  write('De hecho ni siquiera puedes recordar tu nombre ...'), nl,
  write('Lo único que recuerdas es que tenías una llave y es muy especial para ti...'), nl,
  write('Debe estar por aquí en alguna parte...'), nl,
  helpme,
  repeat,
  write('>> '),
  read(X),
  puzzle(X),
  do(X), nl,
  end_condition(X).

end_condition(end).
end_condition(_) :-
  tener(amuleto,true),
  write('Felicidades, has completado el jueir!').

do(ir(X)):-ir(X),!.
do(ir(X)):-ir(X),!.
do(coger(X)):-coger(X),!.
do(helpme):-helpme,!.
do(info):-info,!.
do(end):-
	halt(0).
do(_) :-
  write('Invalid command').


helpme:-
  write('Usa los comandos de Prolog para jugar.'),nl,
  write('Los comandos que puede utilizar son:'),nl,
  write('ir([ubicación]). (ej. ir a la oficina)'),nl,
  write('info. (ex. mira)'),nl,
  write('tomar ([artículo]) (ej. tomar manzana)'),nl,
  write('Presiona enter para continuar'),nl,
  get0(_),
  info.


%%%%% KB y reglas básicas --------------------------------------------
% Ubicaciones
Ubicacion(camino).
Ubicacion(ciudad).
Ubicacion('ciudad').
Ubicacion(tunel).
Ubicacion('tunel').
Ubicacion(rio).
Ubicacion(establo).
Ubicacion(casa).
Ubicacion('pasillo de la casa').
Ubicacion(escalera).
Ubicacion(sotano).
Ubicacion('bodega').
Ubicacion('segunda planta').
Ubicacion(pasillo).
Ubicacion(biblioteca).
Ubicacion('sala').

% Conexiones entre ubicaciones
connection(camino,ciudad).
connection(ciudad, 'ciudad').
connection('ciudad',rio).
connection('ciudad',tunel).
connection(tunel, 'tunel').
connection(rio,establo).
connection('ciudad',casa).
connection(establo,casa).
connection(casa, 'pasillo de la casa').
connection('pasillo de la casa',escalera).
connection(escalera, sotano).
connection(escalera,'segunda planta').
connection('segunda planta', pasillo).
connection(sotano,'bodega').
connection(pasillo,biblioteca).
connection(pasillo,'sala').

% Reglas para hacer que la conexión sea recíproca
connect(X,Y):-
    connection(X,Y).
connect(X,Y):-
    connection(Y,X).


% Reglas para obtener conexiones de ubicación
list_connections(Ubicacion) :-
	connect(X, Ubicacion),
	write(X),
	nl,
    false.
list_connections(_).


% Elementos en cada ubicación
% Debemos declarar el predicado como dinámico si el objeto es "accesible"
% ciudad
item(calle,'ciudad').
% establo
item('linterna',establo).
% tunel
item(alarma,'tunel').
% sotano
item(llave,sotano).
% bodega
item(vino,'bodega').
% biblioteca
item(libro,biblioteca).


% de ubicación inicial y estado de los artículos
:-dynamic (aqui/1,tenercalle/1,item/2,tener/2).
aqui(ciudad).

tener(amuleto,false).
tener(calle,false).
tener(alarma,false).
tener(linterna,false).
tener(llave,false).
tener(vino,false).
tener(libro,false).


%% Reglas para obtener elementos de la ubicación
list_items(Ubicacion) :-
	item(X, Ubicacion),
	write(X),
	nl,
    false.
list_items(_).


% Reglas para obtener toda la información de la ubicación actual
info :-
	aqui(Ubicacion),
	write('Estás en '), write(Ubicacion),write(.), nl,
	write('Las cosas disponibles son:'), nl,
	list_items(Ubicacion),
	write('Puedes ir a:'), nl,
	list_connections(Ubicacion).


%%%%% Reglas principales
% mover de aquí (_) a una nueva ubicación
ir(Ubicacion):-  
    puzzle(ir(Ubicacion)),
	puedeIr(Ubicacion),
	mover(Ubicacion),
	info.

% Verifique que haya una conexión a la nueva Ubicacion
puedeIr(Ubicacion):- 
    aqui(X),                   
  	connect(X,Ubicacion),!.

% Retraer el predicado dinámico y afirmarlo con un nuevo valor
mover(Ubicacion):-
    retract(aqui(_)),
    asserta(aqui(Ubicacion)).


% Coger un articulo
coger(X):-  
	puedeCoger(X),
	cogerItem(X).
puedeCoger(Item) :-
  	aqui(Ubicacion),
    (item(Item, Ubicacion) ->  
    write('Cogido '), 
    write(Item),
  	write(' al inventario.'),nl;
    write('No se encuentra '), 
    write(Item),
  	write(' aqui'),
  	nl, fail
    ).

%%% review function
cogerItem(X):-  
  	retract(item(X,_)),
    retract(tener(X,_)),
  	asserta(tener(X,true)).

%%%%% Reglas para Ubicacions bloqueadas

% camino -> debes conseguir el amuleto antes de salir
puzzle(ir(camino)):-
    tener(amuleto,true),
    !.
puzzle(ir(camino)):-
	write('No puedo irme, necesito mi amuleto...'),nl,
	!, fail.
  	
% tunel -> debes conseguir la linterna antes de entrar
puzzle(ir('tunel')):-
    tener(linterna,true),
    write('Encendiste la linterna y entraste en el tunel ...'),nl,
  	!.
puzzle(ir('tunel')):-
	write('No puedo entrar, está demasiado oscuro ...'),nl,
	!, fail.

% pasillo de la casa -> debes obtener la alarma antes de salir
puzzle(ir('pasillo de la casa')):-
    tener(alarma,true),
    write('Tocaste la alarma y se abrió la puerta de la casa...'),nl,
  	!.
puzzle(ir('pasillo de la casa')):-
	write('Parece que necesito hacerla sonar para que me dejen...'),nl,
	!, fail.

% biblioteca -> debes conseguir la llave para entrar
puzzle(ir(biblioteca)):-
    tener(llave,true),
    write('Abriste la puerta y entraste...'),nl,
  	!.
puzzle(ir(biblioteca)):-
	write('La puerta está cerrada...'),nl,
	!, fail.

% sala -> debes obtener el amuleto antes de irse
puzzle(ir('sala')):-
    tener(libro,true),
    tener(vino,true),
    write('El anciano tomó la jarra de vino y el libro.'),nl,
    write('Dejó caer tu amuleto y tú lo recogiste.'),nl,
  	!.
puzzle(ir('sala')):-
	write('Augusto es un anciano en la habitación.'),nl,
	write('¡AHHHH no me molestes!.'),nl,
	write('¡Necesito mi vino y mi libro! - el gritó'),nl,
	!, fail.
puzzle(_).