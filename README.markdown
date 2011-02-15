
var a.
on b, invoke new.
set to a, new b.
set to a.
set to a, 5.
set to b, 10.
set to c, on c, invoke plub, takingb.
set to c, on a, invoke plus, taking b.
set to c, on c, invoke test, taking a, and blah, taking b.


set to a b cd e23, on b, invoke foo, taking c, and bar, taking 100, and blah, taking 200, and nice, taking (on x, invoke y, taking z), and finally, taking begin ... on p, invoke q. on r, invoke s. t. ...end

var a
set to a, 0

set to b, begin... on a, invoke lessThan, taking 10 ...end
on b, invoke ifTrue, taking begin...
    on a, invoke dump
    set to a, on a, invoke plus, taking 1
...end
    



on a, invoke gt, taking b.
set to t.

on t, invoke ifTrue, begin.
    on "lorem ipsum", invoke dump.
end.

invoke ifFalse, begin.
    on "ipsum", invoke dump.
end.

gt a b?
if true, do this.
    "lorem ipsum".
    invoke dump.
end.

if false, do.
end.
    
-- run the loop five times
on 5, invoke times, taking block.
    set to i
    "lorem ipsum"
    invoke appendString, taking i
    dump    
end.

begin
    gt a b
end
invoke while true, taking begin
    set to a, minus a 1
end

STRING
NUMBER
IDENTIFIER = string(\s+string)*

TERMINATION = \. | \n\n

identifier: identifer_base | identifier_base identifier

program: statements
statements : statement | statement statements
statement: 
    VAR IDENTIFIER TERMINATION |
    SET TO IDENTIFIER TERMINATION |
    expression TERMINATION

expression:
    STRING |
    NUMBER |
    block |
    ON IDENTIFIER, INVOKE method_invocation

block:
    BEGIN ... program ... END
    
    
method_invocation:
    IDENTIFIER optional_taking
    
optionl_taking:
    empty | taking more_invocation_call

taking:
    , TAKING expression 

more_invocation_call
    empty | , AND IDENTIFIER taking  more_invocation_call



autoboxed primitives
    integer
    bool
    rectangle
    point
    size

syntax-assisted objects
    string
    mutable array
    mutable dictionary

first-class blocks
    begin
    end

syntactic tasks
    define a class
    statements
        declaration (incl. blocks)
        return

        expression
            assignment
            message sending
            conditionals
            loops



x, init string with data x, encoding utf-8.




ObjScript

interface MyObject inherits Object
begin
    id i
    number j
    string k

    string method appendString a withString b, string a, string b begin
        string r
        let r be send string alloc, then send r initWithString a encoding b        
        return r
    end of method

    note a new method

    method hello i, i int
    begin
        let i be 0
        while i less than 5
            log "hello, world %d" i
            let i be i plus 1
        end
    end        
end of interface

canvas move center, pendown, forward 100, left 90, forward 100, left 90

repeat 4 begin
    canvas forward 100, left 90
end




