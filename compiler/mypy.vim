if exists("current_compiler")
  finish
endif
let current_compiler = "mypy"

CompilerSet makeprg=mypy\ --disallow-untyped-defs\ %:S

