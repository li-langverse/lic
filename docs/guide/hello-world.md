# Hello world

Li programs are made of **procedures** (`proc`). Each procedure states what it needs, what it guarantees, and how it stops.

## Minimal program

```nim
proc main() -> int
  requires true
  ensures result == 0
  decreases 0
=
  echo "Hello from Li"
  return 0
```

| Line | Meaning |
|------|---------|
| `proc main() -> int` | Entry procedure; returns an integer exit code |
| `requires true` | Precondition (here: always allowed to run) |
| `ensures result == 0` | Postcondition: return value is 0 |
| `decreases 0` | This procedure does not loop — trivially finishes |
| `=` | Start of the body (indentation continues the block) |

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
proc main() -> int
  requires true
  ensures result == 0
  decreases 0
=
  echo 42
  return 0
```

## Calling other procedures

```nim
proc greet() -> int
  requires true
  ensures result == 0
  decreases 0
=
  echo "Hi"
  return 0

proc main() -> int
  requires true
  ensures result == 0
  decreases 0
=
  greet()
  return 0
```

Next: [Examples gallery](examples-gallery.md) or the [Language handbook](../language/overview.md).
