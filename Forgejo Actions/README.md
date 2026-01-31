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

