# Hello world

Li programs are made of **procedures** (`def`). Each function states what it needs, what it guarantees, and how it stops.

## Minimal program

```nim
def main() -> int
  requires true
  ensures result == 0
  decreases 0
=
  echo "Hello from Li"
  return 0
```

| Line | Meaning |
|------|---------|
| `def main() -> int` | Entry function; returns an integer exit code |
| `requires true` | Precondition (here: always allowed to run) |
| `ensures result == 0` | Postcondition: return value is 0 |
| `decreases 0` | This procedure does not loop — trivially finishes |
| `=` | **Body delimiter** — starts the implementation (not an assignment to `decreases`) |

The line **`=`** after `decreases` confuses newcomers because it looks like “equals,” but it only marks **where the contract block ends and the body begins**. You are not assigning anything to `decreases 0`; you are telling the compiler “executable statements follow.” Same delimiter appears on **`while`** loops: `decreases …` then `=` then the loop body.

## Build

```bash
lic build hello.li -o hello
./hello
```

## What “requires / ensures / decreases” are for

Think of them as **promises**:

- **requires** — “I only run when this is true.”
- **ensures** — “When I finish, this will be true.”
- **decreases** — “Something counts down so I cannot loop forever.”

Li uses these promises during **`lic build`**. If Li cannot see that your promises are consistent with your code, the build fails. That is intentional: you learn about mistakes before you run anything.

## Printing text

`echo` works on integers and strings (when the runtime supports them):

```nim
def main() -> int
  requires true
  ensures result == 0
  decreases 0
=
  echo 42
  return 0
```

## Calling other procedures

```nim
def greet() -> int
  requires true
  ensures result == 0
  decreases 0
=
  echo "Hi"
  return 0

def main() -> int
  requires true
  ensures result == 0
  decreases 0
=
  greet()
  return 0
```

Next: [Examples gallery](examples-gallery.md) or the [Language handbook](../language/overview.md).
