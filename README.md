# Authconfig

Formulas to set up authconfig and sssd on Linux systems.

**Note:**
See the full Salt Formulas installation and usage instructions
<http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>.

**Assumptions:**
`make` is on your system and available. If it is not or you are not sure what
`make` is, [this](https://www.gnu.org/software/make/) is a good place to start.

# Testing

Change to `state` file location in checked out repository.

- cd authconfig-formula/authconfig

This is where the ***Makefile*** is located.

- run: `bash make`
- test results will return to your screen.

# Available states

## `authconfig`
Install SSSD and its dependencies on both RHEL|CentOS and Ubuntu|Debian. The
default state will detect your OS based on default grains and run the
corresponding state file

## `authconfig.redhat`

Handles the installation of SSSD and its dependencies on a RHEL|CentOS system.

## `authconfig.ubuntu`

Handles the installation of SSSD and its dependencies on a Ubuntu|Debian system.

# Pillar customizations

Any of these values can be overwritten in a pillar file. If you do find yourself needing
more overrides follow the example below.


# Pillar customizations

[pillar.example](authconfig/tests/pillar/authconfig/init.sls)
