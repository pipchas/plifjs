---- MODULE MC ----
EXTENDS Main, TLC

\* MV CONSTANT declarations@modelParameterConstants
CONSTANTS
x
----

\* MV CONSTANT declarations@modelParameterConstants
CONSTANTS
alex, bob, john
----

\* MV CONSTANT definitions UU
const_1700761333605130000 == 
{x}
----

\* MV CONSTANT definitions U
const_1700761333605131000 == 
{alex, bob, john}
----

\* CONSTANT definitions @modelParameterConstants:4GPol
const_1700761333605132000 == 
("organizer" :> {"manager",  "reviewer", "guest"}) @@
                 ("manager" :> {"guest"}) @@
                 ("reviewer" :> {"guest"}) @@
                 ("guest" :>  {"guest"})
----

\* CONSTANT definitions @modelParameterConstants:5E0
const_1700761333605133000 == 
{"t_expire"}
----

\* CONSTANT definitions @modelParameterConstants:6E1
const_1700761333605134000 == 
{"guest", "manager", "reviewer", "organizer"}
----

\* CONSTANT definitions @modelParameterConstants:8Session_number
const_1700761333605135000 == 
3
----

=============================================================================
\* Modification History
\* Created Thu Nov 23 20:42:13 MSK 2023 by user-sc
