name: example
on-fail: fail-job

steps:
  - main

jobs:
  main:
    uses: local
    directory: /tmp/ymp-build
    image: undefined
    environs:
      - prefix=/usr
    run:
      - echo hello world

  fail-job:
    uses: local
    image: undefined
    directory: /tmp/ymp-build
    run: |
      echo "Failed"
