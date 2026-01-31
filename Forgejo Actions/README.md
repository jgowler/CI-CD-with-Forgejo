# CI/CD with Forgejo and Forgejo Runners

This is a project to set up Forgejo and Forgejo Runners to create a CI/CD pipeline using Docker.

---

## Part 6: Set up Forgejo Actions

Documentation used: https://forgejo.org/docs/next/user/actions/reference/

---

After installing Forgejo on a VM and the Runner on a seperate VM with Docker it is now time to start using Forgejo Actions.

Forgejo Actions can be described as "a built-in Continuous Integration and Continuous Delivery (CI/CD) system for the Forgejo software forges, designed to automate building, testing, linting, and deploying code directly within the repository."

To start using Forgejo Actions (FA from here on out) there needs to be a repo in which a workflow is present:

```
.forgejo/workflows/
```
In this folder will be  a YAML file used to specify the actions the Runner will perform when certain events occur in the repo, such as a `push` (the remote repo is updated with commits made locally).

The file "Test.yaml" will be put in the `workflows` folder above, which provides the instruction to the Runner on what to do.

The quickest and easiest example for a first run would be to have the Runner echo a message on push to the remote repo:

```
Test.yaml

on: [push]
	jobs:
	  test:
	    runs-on: docker
	    steps:
	      - run: echo All good!
```
line by line this translates to:
```
Test.yaml

When a commit is pushed to the repo
    Start the "Job", which is:
        The name of the job, "Test":
            run this on a Runner with the "docker" label
                Begin list of steps to be executed:
                    - A step, in this case "echo All good!"
```

To check if this is successful go to the repo and check the `Actions` tab. Here is where all the actions triggered by events on this repo are recorded. Information found here includes the YAML file, the branch, when it happened, and how long it took to complete amongst other information.

---

## Part 7: Testing pushed code

In this example a file will be created in `workflows` to test some sample Terraform code pushed to the repo. For the Runner to process this Terraform will need to be installed on the host VM:

1. Ensure that your system is up to date and that you have installed the gnupg and software-properties-common packages. You will use these packages to verify HashiCorp's GPG signature and install HashiCorp's Debian package repository.
```
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
```
Install HashiCorp's GPG key.
```
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
```
Verify the GPG key's fingerprint.
```
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
```
The gpg command reports the key fingerprint:
```
/usr/share/keyrings/hashicorp-archive-keyring.gpg
-------------------------------------------------
pub   rsa4096 XXXX-XX-XX [SC]
AAAA AAAA AAAA AAAA
uid         [ unknown] HashiCorp Security (HashiCorp Package Signing) <security+packaging@hashicorp.com>
sub   rsa4096 XXXX-XX-XX [E]
```
Add the official HashiCorp repository to your system.
```
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```
Update apt to download the package information from the HashiCorp repository.
```
sudo apt update
```
Install Terraform from the new repository.
```
sudo apt-get install terraform
```
Verify installation
```
terraform -help

Usage: terraform [global options] <subcommand> [args]

The available commands for execution are listed below.
The primary workflow commands are given first, followed by
less common or more advanced commands.

Main commands:
##...
```