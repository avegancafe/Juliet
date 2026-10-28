# My Juliet extension

Personal layer on top of [Juliet](https://github.com/avegancafe/Juliet). Copy
this directory into its own repo, delete what you don't need, then point
Juliet at it in `~/.config/local/.env`:

```
JULIET_EXTENSION=https://github.com/you/juliet-you.git
```

and run `juliet-bootstrap`. To layer several (say a work extension and your
own), list them space-separated, in order: `JULIET_EXTENSION="<work> <yours>"`.
Every file here is optional; Juliet's `EXTENSIONS.md` describes each one.
`home/` and `config/` mirror `~/` and `~/.config/`: a file there replaces
Juliet's copy of the same file. `claude/settings.json` is merged into
`~/.claude/settings.json` instead of replacing it.

Full examples: [avegancafe/juliet-kyle](https://github.com/avegancafe/juliet-kyle)
(personal) and [avegancafe/juliet-j2](https://github.com/avegancafe/juliet-j2) (work).
