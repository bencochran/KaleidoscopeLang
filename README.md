# KaleidoscopeLang

An experimental partial implementation of a parser for the the language
described in the [LLVM Kaleidoscope tutorial][kaleidoscope]. It uses
[Madness][madness] for tokenizing and parsing.

## Caveats

* Um. Don’t use this for anything because that would be crazy.

* Currently treats all infix binary operators as right-associative with equal
  prescience. So math would be wrong.




[kaleidoscope]: http://llvm.org/docs/tutorial/LangImpl1.html
[madness]: https://github.com/robrix/Madness
