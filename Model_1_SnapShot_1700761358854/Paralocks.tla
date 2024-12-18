----------------------------- MODULE Paralocks -----------------------------
(***************************************************************************)
(* Paralocks specification is an universal language for defining           *)
(* information flow security policy in applications.  Designed in Chalmers *)
(* University by N.  Broberg, D.  Sands.  This specification represents a  *)
(* subset of Paralocks limitted by sets of unparametrised and unary locks  *)
(* and can be used for information flow control in PL/SQL programs.        *)
(***************************************************************************)

EXTENDS Naturals, Sequences, FiniteSets, TLC, Apalache

CONSTANT U,      (**********************************************************)
                 (* the set of concrete actors (actor constants)           *)
                 (**********************************************************)
         UU,     (**********************************************************)
                 (* the set of quantified (bound) actor variables used in  *)
                 (* policy definitions                                     *)
                 (**********************************************************)
         NONE,   (**********************************************************)
                 (* in the absence of partially defined functions in TLA+  *)
                 (* this constant is used for representing empty locks in  *)
                 (* policy clauses                                         *)
                 (**********************************************************)
 \*        ALL,  (**********************************************************)
                 (* is used for representing open unparameterised locks    *)
                 (* in the current lockstate                               *)
                 (**********************************************************)
         E0,     (**********************************************************)
                 (* the set of unparametrised locks                        *)
                 (**********************************************************) 
         E1,     (**********************************************************)
                 (* the set of unary locks (with a single argument i.e.    *)
                 (* roles)                                                 *)
                 (**********************************************************) 
         Undef,  (**********************************************************)
                 (* used for specifying undefined values in program state  *)
                 (**********************************************************)        
         GPol    (**********************************************************)
                 (* global policies for transitivity                       *)
                 (**********************************************************)          
         
         \*E     cursors, exceptions....   
         
Data == 1..10000   (********************************************************)
                   (* the set of possible values for program variables     *)
                   (********************************************************) 
      


Range(s) == {s[i] : i \in DOMAIN s}

(***************************************************************************)
(* substMap1, substMap2, substMap3 - utility functions.  Rename bound      *)
(* variables of the first clause in accordance with the variables of the   *)
(* second clause.                                                          *)
(***************************************************************************)


f ## g == [x \in (DOMAIN f) \cup (DOMAIN g) |->
            CASE x \in DOMAIN f /\ x \in DOMAIN g -> 
                                IF f[x] \cap g[x] # {} THEN f[x] \cap g[x]
                                                       ELSE f[x]
            [] x \in DOMAIN f -> f[x]
            [] x \in DOMAIN g -> g[x]]


(***************************************************************************)
(* Renaming function under condition of clauses including no more than one *)
(* bound user variable                                                     *)
(***************************************************************************)


\* @type: (CLAUSE, CLAUSE) => Bool;
\*substMap3Equality(c1,c2) ==  c1[1] \in UU \/ c1[1] = c2[1]

\* integrity version
substMap3Equality(c1,c2) ==  c2[1] \in UU \/ c2[1] = c1[1]

\* @type: (CLAUSE, CLAUSE, E1) => Set(U);
(*matchLocks(c1, c2, e) ==
    LET 
        \* @type: Set(U);
        c == c1[2][2][e]
    IN 
        IF c \intersect UU /= {}
        THEN (c \ UU) \union {c2[1]}
        ELSE c 
*)
\* integrity version 
matchLocks(c1, c2, e) ==
    LET 
        \* @type: Set(U);
        c == c2[2][2][e]
    IN 
        IF c \intersect UU /= {}
        THEN (c \ UU) \union {c1[1]}
        ELSE c 
  
(***************************************************************************)
(* comparePol - is the policy comparison function.  Returns TRUE iff p1 is *)
(* less restrictive than p2.  See the full definition in [1].              *)
(***************************************************************************)   


(*compareClause(c1, c2) ==
    /\ substMap3Equality(c1,c2)
    /\ \A k \in E0 : \/ c1[2][1][k] = c2[2][1][k]
                     \/ c2[2][1][k] = {}
    /\ \A e \in E1 : \/ c1[2][2][e] = {NONE}
                     \/ matchLocks(c1, c2, e) \subseteq c2[2][2][e]
*)

\* integrity version
compareClause(c1, c2) ==
    /\ substMap3Equality(c1,c2)
    /\ \A k \in E0 : \/ c1[2][1][k] = c2[2][1][k]
                     \/ c1[2][1][k] = {}
    /\ \A e \in E1 : \/ c2[2][2][e] = {NONE}
                     \/ matchLocks(c1, c2, e) \subseteq c1[2][2][e]
(*
\* @type: (POLICY, POLICY) => Bool;  
comparePol (p1, p2) ==
    \A c2 \in p2 : (\E c1 \in p1 : compareClause (c1, c2))
*)

\* integrity version
comparePol (p1, p2) ==
   \/ p2 /= {} /\ (\A c1 \in p1 : (\E c2 \in p2 : compareClause (c1, c2)) \/ p1 ={})
   \/ /\ p2 = {} 
      /\ p1 = {}


(***************************************************************************)
(* LUB - the join operator on policies.  Defined as specified in [] under  *)
(* assumption that we have unparametrised and unary locks only.            *)
(***************************************************************************)
\*GLB(p1, p2) == p1 \cup p2

\*integrity version
LUB(p1, p2) == p1 \cup p2  

\*integrity version
LUB4Seq (s) == FoldSeq(LAMBDA x, y: LUB(x,y), 
                                \* min policy 
                                {}, s)
                                       


(***************************************************************************)
(* GLB - the meet operation on policies.  It corresponds to conjunction of *)
(* (sets of) Horn clauses and can be represented as the union of all       *)
(* clauses of two policies.                                                *)
(***************************************************************************)

unionCl(c1,c2) == 
    LET capMap == [e0 \in E0 |-> c1[2][1][e0] \cap c2[2][1][e0]]
    IN
    IF substMap3Equality(c1,c2)
    THEN << c2[1], 
            <<  capMap, 
                [e1 \in E1 |-> 
                    IF NONE \in c1[2][2][e1] /\ NONE \in c2[2][2][e1] 
                    THEN {NONE} 
                    ELSE (matchLocks(c1, c2, e1) \cup c2[2][2][e1]) \ {NONE}]
            >>
         >>
    ELSE
        IF substMap3Equality(c2,c1)
        THEN << c1[1], 
                << capMap,
                    [e1 \in E1 |-> 
                     IF NONE \in c1[2][2][e1] /\ NONE \in c2[2][2][e1] 
                     THEN {NONE} 
                     ELSE (matchLocks(c2, c1, e1) \cup c1[2][2][e1]) \ {NONE}]
                >>
             >>
        ELSE <<>>
        
\*integrity version
GLB(p1, p2) == {x \in {unionCl(c1,c2): c1 \in p1, c2\in p2} : x # <<>>}   


(***************************************************************************)
(* ALSTP - the policy specialization operator.  It specializes an          *)
(* expression policy with the current lockstate at the point of            *)
(* assignment.  Logically the algorithm is based on the relational         *)
(* resolution reasoning method (with unification step).                    *)
(***************************************************************************)

\* @type: (Set(U), Set(U)) => Set(U -> U);
substMap4(uu, u) == 
    IF uu = {} 
    THEN {}
    ELSE {[u1 \in uu |-> u1]} \union { [u1 \in uu |-> y] : y \in u }                               

applySub(aset, sub) == 
    IF aset = {NONE} 
    THEN {NONE} 
    ELSE 
        {
            IF x \in DOMAIN sub 
            THEN sub[x]
            ELSE x
            : x \in aset
        }

\* @type: (CLAUSE, LOCKS, U -> U) => CLAUSE;
\* @type: (CLAUSE, LOCKS, U -> U) => CLAUSE;
specifyWithSub(c, locks, y) == 
    LET 
        f == c[2][1]
        g == c[2][2]
    IN LET
        S1 == 
        [ x \in DOMAIN f |-> 
            IF x \in E0 /\ locks[x] /= {}
            THEN {NONE}
            ELSE f[x]
        ]
    IN LET
        S2 == [ x \in DOMAIN g |->
            IF x \in E1
            THEN
                IF locks[x] = {}
                THEN applySub(g[x], y)
                ELSE 
                    IF applySub(g[x], y) \ locks[x] = {}
                    THEN {NONE}
                    ELSE applySub(g[x], y) \ locks[x]
            ELSE g[x]
        ]
    IN
    <<IF c[1] \in DOMAIN y 
         THEN y[c[1]]
         ELSE c[1], <<S1, S2>>
    >>

\* @type: (CLAUSE, LOCKS) => POLICY;                
contextClause(c, locks) ==
    LET
        contextClause_OP1 (x, y) ==
            LET sWS == specifyWithSub(c, locks, y)
            IN 
                IF \E i \in x: compareClause(i, sWS)
                THEN x
                ELSE (x \cup {sWS}) \ {i \in x: compareClause(sWS, i)}
    IN LET
        f == c[2][1]
    IN LET
        S1 == [ x \in DOMAIN f |->
            IF x \notin E0 \/ locks[x] = {}
            THEN f[x]
            ELSE {NONE}
        ]
    IN
        FoldSet (contextClause_OP1,
            {<< c[1], <<S1, c[2][2]>> >>},                    
            substMap4(
                IF c[1] \in UU 
                THEN {c[1]}
                ELSE {}, 
                UNION Range(locks) \cap U )
            ) 

\* @type: (POLICY, LOCKS) => POLICY;  
ALSTP(p, SE) ==
    LET
        ALSTP_OP(x, y) ==           
             LET specifiedClauses ==
             \* ~\E g \in x: P <=> \A g \in x: ~P
             {i \in contextClause(y, SE): 
                \A g \in x: ~compareClause(g, i)}
             IN
             (x \cup specifiedClauses) (*\ {i \in x: \E g 
                \in specifiedClauses: compareClause(g, i)}*)
    IN LET
        \* @type: CLAUSE => CLAUSE;
        ALSTP_OP1_direct(y) ==
            LET
                \* @type: E0 -> Set(U);
                f1 == y[2][1]
            IN LET
                f2 == y[2][2]
            IN LET
                \* @type: E0 -> Set(U);
                DirectUpdate1 == [ x \in DOMAIN f1 |->
                    IF x \in E0 /\ SE[x] /= {}
                    THEN {NONE}
                    ELSE f1[x]
                ]
            IN LET
                \* @type: E0 -> Set(U);
                DirectUpdate2 == [ x \in DOMAIN f2 |->
                    IF x \in E1 /\ SE[x] /= {}
                    THEN 
                         IF f2[x] \ SE[x] = {}
                            THEN {NONE}
                            ELSE f2[x] \ SE[x]
                    ELSE f2[x]
                ]    
            
            IN <<y[1], <<DirectUpdate1, DirectUpdate2>>>> 
    IN LET
        DirectSet == { ALSTP_OP1_direct(y): y \in p } 
    IN
    FoldSet(ALSTP_OP, DirectSet, p)

(***************************************************************************)
(* COpenLocks - adds a new set of open locks generated based on global     *)
(* policy rules (recursive locks) into the current lockstate SE            *)
(***************************************************************************)

COpenLocks(lock, GLOB) == 
    LET D  == CHOOSE i \in DOMAIN lock : TRUE
    IN 
        IF \E r \in DOMAIN GLOB : r = D
            THEN lock @@ [r \in GLOB[D] |-> lock[D]]
            ELSE lock
                  
(***************************************************************************)
(* Since TLA+ does not support partially defined function and types we use *)
(* the special value NONE for representing closed or not required locks    *)
(* here.                                                                   *)
(***************************************************************************)

=============================================================================
\* Modification History
\* Last modified Sun Nov 12 09:56:35 MSK 2023 by user-sc
\* Last modified Fri Oct 02 09:31:12 MSK 2020 by user-sc
\* Last modified Sat Aug 29 19:20:37 MSK 2020 by User
\* Created Mon May 25 11:46:28 MSK 2020 by User
