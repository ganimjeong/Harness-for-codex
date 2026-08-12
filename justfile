bootstrap:
    scripts/bootstrap

check:
    scripts/check

test:
    scripts/test

eval:
    scripts/eval

doctor:
    scripts/doctor

hooks:
    scripts/hooks

surface *ARGS:
    scripts/surface {{ARGS}}

selftest:
    scripts/selftest

agent-eval *ARGS:
    scripts/agent-eval {{ARGS}}
