# Iridium 

Iridium is a bare-bones functional programming language. Essentially, it is an interpreter 
for lambda calculus with a few tricks. It is meant to serve as the functional programming
equivalent of the Brainf*** language.

## Syntax

The syntax for this language is extremely simple, there are only two different types of expressions

### Lambda Expression

The syntax for a lambda expression is as follows:

```
λa.b
```

`a` and `b` are the names of parameters, and `λ` signifies the start of an anonymous function.
The `.` separates the parameter from the body of the function.
The above expression would read as: "a function that takes in a parameter `a` and returns a `b`.

An example of this would be the identity function (a function that simply returns its input), which looks like:

```
λx.x
```

### Function Application 

The syntax for function application is as follows:

```
(f)(x)
```

`f` is a function, and `x` is a valud that is being passed to that function. An example of this syntax might look like:

```
(λx.x)(y)
```

The above code represents applying the identity function (as defined earlier) to the value `y`. If you were to run this program, 
it would simply return `y`.

## Usage

### Hello World

Printing hello world in Iridium is a lot different than other programming languages. One problem that immediately rises is the 
fact that there's no such thing as strings, integers, booleans, etc. All we have to work with are functions. The way we work 
around this is by allowing the programmer to specify particular inputs to a function, which is what the `iridium` executable 
allows us to do.

Consider the following `hello.lam` file:

```
λx.x
```

Yes, this is the identity function from earlier. Let's try running it with the `iridium` executable:

```
$ iridium hello.lam
λx.x
```

Nothing happened; it just printed out the same thing. This is because we haven't given the function any arguments, so the 
interpreter is unable to reduce the expression any farther. Any additional arguments we pass to the executable will be passed
on to the functions. So we can run our program by doing:

```
$ iridium hello.lam "Hello, World!"
[Hello, World!]
```

And now we've printed hello world to the screen. This feels a bit like cheating, as we can just pass in any argument we want and 
get any input we want. This is true, but it's no different from a `print` function in any other language. The only difference 
in this scenario is that we've changed the position of the arguments to outside the program.

### Booleans

One of the most common datatypes used in programming is the boolean; a value that can be true or false.
But how can we do this in a language that only has functions? First, the program needs to know what true and false are.
We can do this by defining two functions which take in these inputs. And once we have that, we can simply return either 
to represent either true or false. For example, `true` might look like:

```
λt.λf.t
```

And `false` might look like:

```
λt.λf.f
```

Let's try running `λt.λf.t` and supplying only one argument, "TRUE":

```
$ iridium true.lam TRUE
λf.[TRUE]
```

What we have here is a partially evaluated expression. We can see the substitution of certain parameters, but it isn't enough to give a final result. If we specify the next argument, then we can see the expression fully reduces:

```
$ iridium true.lam TRUE FALSE 
[TRUE]
```

And if we replace `λt.λf.t`, with `λt.λf.f` we would get:

```
$ iridium false.lam TRUE FALSE 
[FALSE]
```

Iridium is actually aware of this representation of boolean, and automatically replaces `true` with `λt.λf.t`, and `false` with 
`λt.λf.f`. If we run our hello world program from earlier:

```
$ iridium hello.lam true
λt.λf.t

$ iridium hello.lam false 
λt.λf.f
```

This can be incredibly useful for passing in booleans directly into expressions.

Let's consider logical NOT: it takes a true value, and returns a false value, and vice versa. One way we could represent this 
with our new booleans is by simpliy flipping the parameters for true and false, like so:

```
λt.λf.λb.((b)(f))(t)
```

`t` and `f` represent the values `true` and `false`, and `b` represents the boolean given as input to the program. Here's what 
evaluation of the expression looks like:

```
$ iridium not.lam
λt.λf.λb.((b)(f))(t)

$ iridium not.lam TRUE
λf.λb.((b)(f))([TRUE])

$ iridium not.lam TRUE FALSE
λb.((b)([FALSE]))([TRUE])

$ iridium not.lam TRUE FALSE true
[FALSE]

$ iridium not.lam TRUE FALSE false
[TRUE]
```

### Numbers

Natural numbers are sometimes defined with a zero value, and a successor function. For example, 0 might be Z, and 2 might be S(S(Z)), and we can easily do this:

```
λs.λ0.(s)(0)
```

But now we run into the problem, what do we pass in for `s`? We could try just passing in any old symbol, but then we'll end up 
with something like:

```
([S])(0)
```

to solve this problem, Iridium provides a built in `S` function and a `Z` value, where `Z` represents 0 and `S` represents a 
function which adds one to a given number. As with the automatic boolean conversion, integer arguments are also automatically 
converted. For example, here is a program that adds one to a given input integer:

`increment.lam`:
```
λn.(S)(n)
```

From the command line:
```
$ iridium increment.lam
λn.(S)(n)

$ iridium increment.lam 5
#6
```
