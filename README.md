
# PiedPiper C++ Static Analysis Function
[![Build Status](https://travis-ci.com/AFCYBER-DREAM/piedpiper-cppcheck-faas.svg?branch=master)](https://travis-ci.com/AFCYBER-DREAM/piedpiper-cppcheck-faas)

PiedPiper C++ Static Analysis

### Table of Contents
* [Getting Started](#getting-started)
* [Prerequisites](#prerequisites)
* [Installing](#installing)
* [Inputs and Outputs](#inputs-and-outputs)
* [Running the Tests](#running-the-tests)
* [Contributing](#contributing)
* [Versioning](#versioning)
* [Authors](#authors)
* [License](#license)

## Getting Started

To deploy this function you must have OpenFaaS installed.  To create a
development environment see
(https://github.com/AFCYBER-DREAM/ansible-collection-pidev)

### Prerequisites

OpenFaaS

To install this function on OpenFaaS do the following after authentication:

```
git clone https://github.com/AFCYBER-DREAM/piedpiper-cppcheck-faas.git
cd piedpiper-cppcheck-faas
faas build
faas deploy
```

To validate that your function installed correctly you can run the following:

```
faas ls
```

## Inputs and Outputs

This function expects to receive its data via an HTTP POST request. The format
of the request should be as follows:

```yaml
ci:
  ci_provider: gitlab-ci
  ci_provider_config: {{ contents of .gitlab-ci.yml }}
file_config:
  - file: test.sh
    linter: noop
  - file: etc
pi_global_vars:
  ci_provider: gitlab-ci
  project_name: {{ project_name }}
  vars_dir: default_vars.d
  version: {{ version }}
pi_sast_pipe_vars:
  run_pipe: True
  url: http://172.17.0.1:8080/function
  version: latest
pi_sast:
  - name: "*.cc"
    sast: cppcheck
  - name: "*.c"
    sast: cppcheck
  - name: "*.cpp"
    sast: cppcheck
  - name: "*.h"
    sast: cppcheck
options: [{cppcheck}]

```

piedpiper-cppcheck-faas will look at the contents of options: to determine what
arguments are to be passed into the underlying cppcheck command in the function.
Cppcheck will accept both individual files for analysis, as well as a source
folder to scan. When passed a folder, Cppcheck will NOT analyze header (`.h` or
`.hpp`) files, only C/C++ source files (`.c`, `.cpp`, `.cc`). To analyze header
files, the header files must be specified as arguments to Cppcheck.

Typical arguments include:

```yaml

│  options: ['src/', '--verbose', '--force']
   options: ['{source or header file}']
   options: ['source1.c','source2.c', 'source2.h']

```

## Running the tests

piedpiper-cppcheck-faas can be run both as part of a Gitlab CI pipeline, or
with the piedpiper CLI tool. To use the analysis tool locally, navigate to the
source directory and use the command picli sast to begin static analysis.
PiCli will use the same run_vars as the PiedPiper CI pipeline.

## Contributing

Please read [CONTRIBUTING.md](https://github.com/AFCYBER-DREAM/piedpiper-picli)
for details on our code of conduct, and the process for submitting pull
requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available,
see the
[tags on this repository](https://github.com/piedpiper-validator-faas/tags).

## Authors

See also the list of
[contributors](https://github.com/AFCYBER-DREAM/piedpiper-validator-faas/contributors)
who participated in this project.

## License

MIT

## Acknowledgments

* Inspiration for the CLI framework came from the Ansible Molecule project
=======
# piedpiper-cppcheck-faas
>>>>>>> e7d26ad38458e9fbf26ca819e1cb87e77a4ba5c2
