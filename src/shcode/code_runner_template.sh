name: example
on-fail: fail-job

steps:
  - main

jobs:
  main:
    uses: local
    image: undefined
    environs:
      - prefix=/usr
    run:
      - echo hello world

  fail-job:
    uses: local
    image: undefined
    run: |
      echo "Failed"
