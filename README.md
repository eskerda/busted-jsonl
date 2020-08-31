# busted-jsonl

This is an alternative output handler for
[Busted](https://github.com/Olivine-Labs/busted), a unit testing framework for
Lua.

It is based on the `json` output handler that is bundled with Busted.

It prints a JSON element per test instead of per suite, aka
[JSON Lines](http://jsonlines.org/). Useful for:

* parsing busted output by stream
* running long suites on systems that timeout non verbose jobs after some
minutes, like Travis CI.
* analyzing busted output with any tool that supports JSON Lines (VisiData).

## Installing

```bash
luarocks install busted-jsonl
```

## Using

```bash
busted -o jsonl
```

or add a file `.busted` to your project root containing

```busted
return {
   default = {
      output = "jsonl"
   },
}
```

## Example

```
busted -o jsonl | jq
busted -o jsonl | vd -f jsonl
```

## License

This is based off the code of `json` from Busted, and like Busted, it is MIT-licensed.
