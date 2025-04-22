:- consult('publicKB').
%:-consult('studentKB').
university_schedule(S):- 
	listofallstudents(S1),sort(S1,S2),permutation(S2,S3),list(S3,S).
listofallstudents(S1):- 
	findall(Student_id,studies(Student_id,_),S1).
list([],[]).
list([H|T],[sched(H,Slots)|T1]):-
	student_schedule(H,Slots),list(T,T1).


student_schedule(Student_id, Slots):-
	findall(Course_code,studies(Student_id,Course_code),AllCourses),permutation(AllCourses,All),getAllCourses(All,Slots).
getAllCourses([],[]).
getAllCourses([H|T],[slot(D,N,H)|T1]):-day_schedule(D,Schedule),find_slot(H,Schedule,N),N=\=0,getAllCourses(T,T1).

find_slot(Course_Code,Schedule,Slot_number):-
	find_slot_helper(Course_Code,Schedule,1,Slot_number).

find_slot_helper(C,[],_,0).
find_slot_helper(C,[H|T],Acc,Acc):- member(C,H).
find_slot_helper(C,[H|T],Acc,Number):-
	A is Acc+1,
	find_slot_helper(C,T,A,Number).

no_clashes([]).
no_clashes([H]).
no_clashes([slot(Day,Slot_number,_)|T]):-
	\+ member(slot(Day,Slot_number,_),T),
	no_clashes(T).

study_days(Slots, DayCount):-
	findall(Day, (member(S,Slots),S=slot(Day,_,_)),AllDays),
	remove_duplicates(AllDays,NoDuplicates),
	length0(NoDuplicates,NumofDays),
	NumofDays=<DayCount.

remove_duplicates([],[]).
remove_duplicates([H],[H]).
remove_duplicates([H|T], R) :-
    member(H,T),
	remove_duplicates(T,R).
remove_duplicates([H|T],[H|R]):-
	\+member(H,T),
	remove_duplicates(T,R).

length0([],0).
length0([_|T], Count):-
	length0(T,Count1),
	Count is Count1 + 1 .

assembly_hours(Schedules, AH):-
    findall(Schedule,
	(member(sched(_, Schedule),Schedules)),
	A),
	flatten(A,A1),
	% to get only the slots with days common to all students
	findall( Slot,
	(member(Slot,A1),member_In_All(Slot,A)),
	AH1),
	sort(AH1,A2),
	remove_course(A2,X),
	Days = [saturday,sunday,monday,tuesday,wednesday,thursday],
	Slots = [1,2,3,4,5],
	allSlots(Days,Slots,All),
	findall(slot(Day,Slot_number),(member(slot(Day,Slot_number),All),\+member(slot(Day,Slot_number),X),member(slot(Day,_),X)),AH3),
	sort(AH3,AH).

member_In_All(slot(Day,_,_),[H]):- member(slot(Day,_,_),H).
member_In_All(S,[H|T]):- S=slot(Day,_,_),member(slot(Day,_,_),H),member_In_All(S,T).


remove_course([],[]).
remove_course([slot(Day,Slot_number,_)|T],[slot(Day,Slot_number)|T1]):-remove_course(T,T1).

allSlots([],_,[]).
allSlots([H|T],Slots, All):-
	allTimes(H,Slots,A),
	allSlots(T,Slots,A2),
	append(A,A2,All).

allTimes(_,[],[]).
allTimes(Day,[H|T],[slot(Day,H)|T2]):-
	allTimes(Day,T,T2).