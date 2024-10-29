--------------------------- MODULE ParametersFS------------------------------

EXTENDS Naturals, Sequences

CONSTANT  U,         (******************************************************)
                     (* described in Paralocks module                      *)
                     (******************************************************)
          UU,        (******************************************************)
                     (* described in Paralocks module                      *)
                     (******************************************************)
          NONE,      (******************************************************)
                     (* described in Paralocks module                      *)
                     (******************************************************)
          ALL,       (******************************************************)
                     (* described in Paralocks module                      *)
                     (******************************************************)
          E0,        (******************************************************)
                     (* described in Paralocks module                      *)
                     (******************************************************)
          E1,        (******************************************************)
                     (* described in Paralocks module                      *)
                     (******************************************************)
          Undef,     (******************************************************)
                     (* described in Paralocks module                      *)
                     (******************************************************)
          GPol,      (******************************************************)
                     (* described in Paralocks module                      *)
                     (******************************************************)
 Session_number      (******************************************************)
                     (* the number of user sessions                        *)
                     (******************************************************)

VARIABLES Sessions,  (******************************************************)
                     (* Sessions environment.  Maps user sessions to       *)
                     (* respective buffers.                                *)
                     (******************************************************)
          XLocks,    (******************************************************)
                     (* Represents exclusive locks for immitating the      *)
                     (* system where procedures can be executed one at a   *)
                     (* time                                               *)
                     (******************************************************)
          VPol,      (******************************************************)
                     (* Global variables security policies which due to    *)
                     (* flow sensitivity can be changed over program       *)
                     (* execution in contrast to inputs and outputs        *)
                     (******************************************************)
          Trace,     (******************************************************)
                     (* Represents a program trace                         *)
                     (******************************************************)
          SLocks,    (******************************************************)
                     (* Session locks is a convenient mechanism for        *)
                     (* representing short-time IF locks which must be     *)
                     (* closed immediately after we leave the session      *)
                     (******************************************************)
          Ignore,    (******************************************************)
                     (* The flag which is used to ignore an ifc policy     *)
                     (* violation warning (false alarm)                    *)
                     (******************************************************)
          StateE,    (******************************************************)
                     (* the set of open locks (for concrete actors)        *)
                     (******************************************************)
          New2Old    (******************************************************)
                     (* this is the tuple of the form <<old, new>>, where  *)
                     (* old - the policy of the changed variable, new -    *)
                     (* the policy of the expression assigned specified to *)
                     (* the current lock state                             *)
                     (******************************************************)

vars == <<Sessions, SLocks, StateE,
          New2Old, XLocks, VPol, Trace, Ignore>>

INSTANCE Paralocks WITH
         U <- U, UU <- UU, NONE <- NONE, E0 <- E0, E1 <- E1,
         Undef <- Undef, GPol <- GPol

(***************************************************************************)
(* The most liberal policy                                                 *)
(***************************************************************************)

\*integrity version
max == {<<CHOOSE x \in UU: TRUE,<<[e1 \in E0 |-> {NONE}],
                                  [e2 \in E1 |-> {NONE}]>> >>}

any_caller(x) == {<<x, <<[e1 \in E0 |-> {NONE}],
                                  [e2 \in E1 |-> {NONE}]>> >>}

(***************************************************************************)
(* The most restrictive policy                                             *)
(***************************************************************************)

\*integrity version
min == {}

u1 == CHOOSE i \in UU: TRUE
u2 == CHOOSE j \in UU: j#u1

Calls == {"p_allocate", "f_get_paper", "f_get_section_program", "f_is_accepted", "p_add_paper", "p_submit_paper", "p_change_status"}

(***************************************************************************)
(* Services markup                                                         *)
(***************************************************************************)

p_allocate_p_s_id(x) == [loc |-> "mem", offs |-> 0, policy |-> {<<u1,<<[t_expire |-> {NONE}], [guest |-> {NONE}, 
                                                                        reviewer |-> {NONE}, manager |-> {u1}, 
                                                                        organizer |-> {NONE}]>>>>}, name |-> "p_allocate_p_s_id"]
p_allocate_l_v_is_acc(x) == [loc |-> "mem", offs |-> 1, policy |-> min, name |-> "p_allocate_l_v_is_acc"]
p_allocate_l_v_p_id(x) == [loc |-> "mem", offs |-> 2, policy |-> min, name |-> "p_allocate_l_v_p_id"]
p_allocate_p_id(x) == [loc |-> "mem", offs |-> 3, policy |-> {<<u1,<<[t_expire |-> {NONE}], [guest |-> {NONE}, 
                                                                        reviewer |-> {NONE}, manager |-> {u1}, 
                                                                        organizer |-> {NONE}]>>>>}, name |-> "p_allocate_p_id"]
\*ParalocksInv fix 
p_allocate_p_sec_id(x) == [loc |-> "mem", offs |-> 4, policy |-> {<<u1,<<[t_expire |-> {NONE}], [guest |-> {NONE}, 
                                                                          reviewer |-> {NONE}, manager |-> {u1}, 
                                                                          organizer |-> {NONE}]>>>>}, name |-> "p_allocate_p_sec_id"]
\*ParalocksInv fix 
p_allocate_p_alloc_date(x) == [loc |-> "mem", offs |-> 5, policy |-> {<<u1,<<[t_expire |-> {NONE}], [guest |-> {NONE}, 
                                                                        reviewer |-> {NONE}, manager |-> {u1}, 
                                                                        organizer |-> {NONE}]>>>>}, name |-> "p_allocate_p_alloc_date"]
p_allocate_l_paper_not_accepted(x) == [loc |-> "mem", offs |-> 6, policy |-> min, name |-> "p_allocate_l_paper_not_accepted"]

f_get_paper_l_v_paper_paper_id(x) == [loc |-> "mem", offs |-> 0, policy |-> min, name |-> "f_get_paper_l_v_paper_paper_id"]
f_get_paper_l_v_paper_title(x) == [loc |-> "mem", offs |-> 1, policy |-> min, name |-> "f_get_paper_l_v_paper_title"]
f_get_paper_l_v_paper_abstract(x) == [loc |-> "mem", offs |-> 2, policy |-> min, name |-> "f_get_paper_l_v_paper_abstract"]
f_get_paper_l_v_paper_text(x) == [loc |-> "mem", offs |-> 3, policy |-> min, name |-> "f_get_paper_l_v_paper_text"]
f_get_paper_l_v_paper_authors(x) == [loc |-> "mem", offs |-> 4, policy |-> min, name |-> "f_get_paper_l_v_paper_authors"]
\*ParalocksInv fix
f_get_paper_p_p_id(x) == [loc |-> "mem", offs |-> 5, policy |-> max, name |-> "f_get_paper_p_p_id"]
\*ParalocksInv fix
f_get_paper_r_v_paper_paper_id(x) == [loc |-> "mem", offs |-> 6, policy |-> max, name |-> "f_get_paper_r_v_paper_paper_id"]
\*ParalocksInv fix
f_get_paper_r_v_paper_title(x) == [loc |-> "mem", offs |-> 7, policy |-> max, name |-> "f_get_paper_r_v_paper_title"]
\*ParalocksInv fix
f_get_paper_r_v_paper_abstract(x) == [loc |-> "mem", offs |-> 8, policy |-> max, name |-> "f_get_paper_r_v_paper_abstract"]
\*ParalocksInv fix
f_get_paper_r_v_paper_text(x) == [loc |-> "mem", offs |-> 9, policy |-> max, name |-> "f_get_paper_r_v_paper_text"]
\*ParalocksInv fix
f_get_paper_r_v_paper_authors(x) == [loc |-> "mem", offs |-> 10, policy |-> max, name |-> "f_get_paper_r_v_paper_authors"]

f_get_section_program_l_v_program_paper_id(x) == [loc |-> "mem", offs |-> 0, policy |-> min, name |-> "f_get_section_program_l_v_program_paper_id"]
f_get_section_program_l_v_program_title(x) == [loc |-> "mem", offs |-> 1, policy |-> min, name |-> "f_get_section_program_l_v_program_title"]
f_get_section_program_l_v_program_abstract(x) == [loc |-> "mem", offs |-> 2, policy |-> min, name |-> "f_get_section_program_l_v_program_abstract"]
f_get_section_program_l_v_program_text(x) == [loc |-> "mem", offs |-> 3, policy |-> min, name |-> "f_get_section_program_l_v_program_text"]
f_get_section_program_l_v_program_authors(x) == [loc |-> "mem", offs |-> 4, policy |-> min, name |-> "f_get_section_program_l_v_program_authors"]
\*ParalocksInv fix
f_get_section_program_p_s_id(x) == [loc |-> "mem", offs |-> 5, policy |-> max, name |-> "f_get_section_program_p_s_id"]
\*ParalocksInv fix
f_get_section_program_r_v_program_paper_id(x) == [loc |-> "mem", offs |-> 6, policy |-> max, name |-> "f_get_section_program_r_v_program_paper_id"]
\*ParalocksInv fix
f_get_section_program_r_v_program_title(x) == [loc |-> "mem", offs |-> 7, policy |-> max, name |-> "f_get_section_program_r_v_program_title"]
\*ParalocksInv fix
f_get_section_program_r_v_program_abstract(x) == [loc |-> "mem", offs |-> 8, policy |-> max, name |-> "f_get_section_program_r_v_program_abstract"]
\*ParalocksInv fix
f_get_section_program_r_v_program_text(x) == [loc |-> "mem", offs |-> 9, policy |-> max, name |-> "f_get_section_program_r_v_program_text"]
\*ParalocksInv fix
f_get_section_program_r_v_program_authors(x) == [loc |-> "mem", offs |-> 10, policy |-> max, name |-> "f_get_section_program_r_v_program_authors"]

f_is_accepted_l_v_status(x) == [loc |-> "mem", offs |-> 0, policy |-> min, name |-> "f_is_accepted_l_v_status"]
\*ParalocksInv fix
f_is_accepted_p_s_id(x) == [loc |-> "mem", offs |-> 1, policy |-> {<<u1,<<[t_expire |-> {NONE}], [guest |-> {NONE}, 
                                                                        reviewer |-> {NONE}, manager |-> {u1}, 
                                                                        organizer |-> {NONE}]>>>>}, name |-> "f_is_accepted_p_s_id"]
\*ParalocksInv fix
f_is_accepted_r_const(x) == [loc |-> "mem", offs |-> 2, policy |-> max, name |-> "f_is_accepted_r_const"]

\*ParalocksInv fix
p_add_paper_p_p_id(x) == [loc |-> "mem", offs |-> 0, policy |-> max, name |-> "p_add_paper_p_p_id"]
p_add_paper_p_tit(x) == [loc |-> "mem", offs |-> 1, policy |-> max, name |-> "p_add_paper_p_tit"]
p_add_paper_p_absr(x) == [loc |-> "mem", offs |-> 2, policy |-> max, name |-> "p_add_paper_p_absr"]
p_add_paper_p_t(x) == [loc |-> "mem", offs |-> 3, policy |-> max, name |-> "p_add_paper_p_t"]
p_add_paper_p_auth(x) == [loc |-> "mem", offs |-> 4, policy |-> max, name |-> "p_add_paper_p_auth"]

\*ParalocksInv fix
p_submit_paper_p_s_id(x) == [loc |-> "mem", offs |-> 0, policy |-> max, name |-> "p_submit_paper_p_s_id"]
p_submit_paper_p_p_id(x) == [loc |-> "mem", offs |-> 1, policy |-> max, name |-> "p_submit_paper_p_p_id"]
p_submit_paper_p_c_id(x) == [loc |-> "mem", offs |-> 2, policy |-> max, name |-> "p_submit_paper_p_c_id"]
p_submit_paper_p_sub_date(x) == [loc |-> "mem", offs |-> 3, policy |-> max, name |-> "p_submit_paper_p_sub_date"]
p_submit_paper_p_stat(x) == [loc |-> "mem", offs |-> 4, policy |-> max, name |-> "p_submit_paper_p_stat"]

p_change_status_p_stat(x) == [loc |-> "mem", offs |-> 0, policy |-> {<<u1,<<[t_expire |-> {NONE}], [guest |-> {NONE}, 
                                                                       reviewer |-> {u1}, manager |-> {NONE}, 
                                                                       organizer |-> {NONE}]>>>>}, name |-> "p_change_status_p_stat"]
p_change_status_p_s_id(x) == [loc |-> "mem", offs |-> 1, policy |-> {<<u1,<<[t_expire |-> {NONE}], [guest |-> {NONE}, 
                                                                       reviewer |-> {u1}, manager |-> {NONE}, 
                                                                       organizer |-> {NONE}]>>>>}, name |-> "p_change_status_p_s_id"]


(***************************************************************************)
(* The set of session users for specified session number                   *)
(***************************************************************************)

S ==  CHOOSE s \in SUBSET(U) : Cardinality(s) = Session_number

===========================================================================
