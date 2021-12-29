/*
 * Universidad de La Laguna
 * Inteligencia Artificial
 * @author Marco Antonio Cabrera Hernández - alu0101327372
 * @email alu0101327372@ull.edu.es
 */
use_module(library(persistency)).

%%%%% Rules for game control ----------------------------------------
start:-
  write('Welcome to Forgotten'), nl,
  write('You wake up in a strange forest, but you do not remember how you got here...'), nl,
  write('In fact you can not even remeber your name...'), nl,
  write('The one thing you remember is that you had a recorder, and it is very special to you...'), nl,
  write('It must be around here somewhere...'), nl,
  helpme,
  repeat,
  write('>> '),
  read(X),
  puzzle(X),
  do(X), nl,
  end_condition(X).

end_condition(end).
end_condition(_) :-
  have(recorder,true),
  write('Congratulations, you have completed the game!').

do(go(X)):-go(X),!.
do(go(X)):-go(X),!.
do(take(X)):-take(X),!.
do(helpme):-helpme,!.
%do(inventory):-inventory,!.
do(info):-info,!.
do(end):-
	halt(0).
do(_) :-
  write('Invalid command').


helpme:-
  write('Use Prolog commands to play the game.'),nl,
  write('The commands you can use are:'),nl,
  write('go([location]). (ex. go to the office)'),nl,
  write('info. (ex. look)'),nl,
  write('take([item]) (ex. take apple)'),nl,
  write('Hit enter to continue'),nl,
  get0(_),
  info.


%%%%% KB and basic rules --------------------------------------------
% Describe locations
location(road).
location(forest).
location('deep forest').
location(cave).
location('deep cave').
location(swamp).
location(stable).
location(castle).
location('castle hall').
location(staircase).
location(basement).
location('wine cellar').
location('second floor').
location(hallway).
location(library).
location('living room').

% Describe connections between locations
connection(road,forest).
connection(forest, 'deep forest').
connection('deep forest',swamp).
connection('deep forest',cave).
connection(cave, 'deep cave').
connection(swamp,stable).
connection('deep forest',castle).
connection(stable,castle).
connection(castle, 'castle hall').
connection('castle hall',staircase).
connection(staircase, basement).
connection(staircase,'second floor').
connection('second floor', hallway).
connection(basement,'wine cellar').
connection(hallway,library).
connection(hallway,'living room').

% Rules for making connection reciprocate
connect(X,Y):-
    connection(X,Y).
connect(X,Y):-
    connection(Y,X).




% Rules to get conections of location
list_connections(Location) :-
	connect(X, Location),
	write(X),
	nl,
    false.
list_connections(_).


% Describe items in each location
% We must declare the predicate as dynamic if the object is "takable"
% deep forest	
item(branch,'deep forest').
% stable
item('torch',stable).
% deep cave
item(bell,'deep cave').
% basement
item(key,basement).
% wine cellar
item(wine,'wine cellar').
% library
item(book,library).
% living room
item(recorder,'living room').


% initial location and state of items
:-dynamic (here/1,haveBranch/1,item/2,have/2).
here(forest).

have(recorder,false).
have(branch,false).
have(bell,false).
have(torch,false).
have(key,false).
have(wine,false).
have(book,false).



%% Rules to get items from location
list_items(Location) :-
	item(X, Location),
	write(X),
	nl,
    false.
list_items(_).

% Rule to get all information of current location
info :-
	here(Location),
	write('You are in the '), write(Location),write(.), nl,
	write('The available things are:'), nl,
	list_items(Location),
	write('You can move to:'), nl,
	list_connections(Location).

%%%%% Main rules

% Move from here(_) to new location
go(Location):-  
    puzzle(go(Location)),
	canGo(Location),
	move(Location),
	info.
% Verify there is a connection to new location
canGo(Location):- 
    here(X),                   
  	connect(X,Location),!.

% Retract dynamic predicate and assert it with new value
move(Location):-
    retract(here(_)),
    asserta(here(Location)).


% Take item into invertory
take(X):-  
	canTake(X),
	takeItem(X).
canTake(Item) :-
  	here(Location),
    (item(Item, Location) ->  
    write('Taken '), 
    write(Item),
  	write(' into inventory.'),nl;
    write('Can not find '), 
    write(Item),
  	write(' in here.'),
  	nl, fail
    ).

%%% review function
takeItem(X):-  
  	retract(item(X,_)),
    retract(have(X,_)),
  	asserta(have(X,true)).

%%%%% Rules for locked locations

% road -> must get the recorder before leaving
puzzle(go(road)):-
    have(recorder,true),
    !.
puzzle(go(road)):-
	write('I can not leave, I need my recorder...'),nl,
	!, fail.
  	
% deep cave -> must get the torch before entering
puzzle(go('deep cave')):-
    have(torch,true),
    write('You lit up the torch and walk into the deep cave...'),nl,
  	!.
puzzle(go('deep cave')):-
	write('I can not enter, its too dark...'),nl,
	!, fail.

% castle hall -> must get the bell before leaving
puzzle(go('castle hall')):-
    have(bell,true),
    write('You rang the bell and the castle door opened...'),nl,
  	!.
puzzle(go('castle hall')):-
	write('Seems like I need to ring to be let it...'),nl,
	!, fail.

% library -> must get the key to enter
puzzle(go(library)):-
    have(key,true),
    write('You unlocked the door and walked in...'),nl,
  	!.
puzzle(go(library)):-
	write('The door is locked...'),nl,
	!, fail.

% living room -> must get the recorder before leaving
puzzle(go('living room')):-
    have(book,true),
    have(wine,true),
    write('The old man took the wine jug and the book.'),nl,
    write('He dropped your recorder and you picked it up.'),nl,
  	!.
puzzle(go('living room')):-
	write('There is an old man in the room.'),nl,
	write('AHHHH do not disturb me!.'),nl,
	write('I need my wine and my book! - he yelled'),nl,
	!, fail.
puzzle(_).