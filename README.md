# CI/CD with Forgejo and Forgejo Runners

This is a project to set up Forgejo and Forgejo Runners to create a CI/CD pipeline using Docker.

---

## Part 1: Set up Forgejo

Documentation used: https://forgejo.org/docs/next/admin/installation/binary/

---

I created a new VM in Proxmox to host Forgejo, accessing it over SSH from VSCode to make things easier using the following commands:

```
ssh-keygen -t ed25519 -C "PC-to-Forgejo" -f PC-to-Forgejo
ssh-copy-id -i PC-to-Forgejo.pub <account>@<serverIP>
```

Once connected I installed Forgejo using the steps provided in the documentation.

---

## Part 2: Set up Runner VM
Documentation used:
https://docs.docker.com/engine/install/ubuntu/
https://forgejo.org/docs/next/admin/actions/runner-installation/#standard-registration

---

The Runner will be hosted on a seperate VM with access to Docker to create containers. Once the Docker engine was installed, daemon started and enabled, the binaries were downloaded and verified using the following:

```
export ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
export RUNNER_VERSION=$(curl -X 'GET' https://data.forgejo.org/api/v1/repos/forgejo/runner/releases/latest | jq .name -r | cut -c 2-)
export FORGEJO_URL="https://code.forgejo.org/forgejo/runner/releases/download/v${RUNNER_VERSION}/forgejo-runner-${RUNNER_VERSION}-linux-${ARCH}"
wget -O forgejo-runner ${FORGEJO_URL} || curl -o forgejo-runner ${FORGEJO_URL}
chmod +x forgejo-runner
wget -O forgejo-runner.asc ${FORGEJO_URL}.asc || curl -o forgejo-runner.asc ${FORGEJO_URL}.asc
gpg --keyserver hkps://keys.openpgp.org --recv EB114F5E6C0DC2BCDD183550A4B61A2DC5923710
gpg --verify forgejo-runner.asc forgejo-runner && echo "✓ Verified" || echo "✗ Failed"
```
Running the above should return the following:

```
Good signature from "Forgejo <contact@forgejo.org>"
		aka "Forgejo Releases <release@forgejo.org>"
✓ Verified
```
Then, copy the downloaded binary to `/usr/local/bin/forgejo-runner`:
```
cp forgejo-runner /usr/local/bin/forgejo-runner
```
Test Runner using `forgejo-runner -v`. If this returns the version then we are good to continue.

---

## Part 3: Set up Runner user

This part is very straight forward; create the `runner` user and add it to the `docker` group:

```
useradd --create-home runner
usermod -aG docker runner
```

This will allow the `runner` user to access Docker in the VM.

### Part 4: Register the runner

The runner needs to be registered to recieve tasks from Forgejo. This is done by entering the following on the Runner VM:

```
sudo su runner
whoami (should return 'runner')
cd ~ (move to home)
pwd (confirm home location - should return '/home/runner')
```
While logged in as runner we need to register it with Forgejo. Becuase I want the Runner to accept workflows from all repositories I accessed the register token from `Admin/Actions/Runners/Create new runner`:
```
forgejo-runner register
INFO Registering runner, arch=arm64, os=linux, version=v9.0.3.
WARN Runner in user-mode.
INFO Enter the Forgejo instance URL (for example, https://next.forgejo.org/):
http://<forgejo-vm-IP:3000>/ # not using https
INFO Enter the runner token:
<Token-from-Admin/Actions/Runners/Create new runner>
INFO Enter the runner name (if set empty, use hostname: runner-host):
<left blank / default>
INFO Enter the runner labels, leave blank to use the default labels (comma-separated, for example, ubuntu-20.<Left blank>
INFO Registering runner, name=docker, instance=http://forgejo-vm-IP/, labels=[docker].
DEBU Successfully pinged the Forgejo instance server
INFO Runner registered successfully.
```

### Part 5: Run as a systemd service:

---

Copy the following to `/etc/systemd/system/forgejo-runner.service`:

```
[Unit]
Description=Forgejo Runner
Documentation=https://forgejo.org/docs/latest/admin/actions/
After=docker.service

[Service]
ExecStart=/usr/local/bin/forgejo-runner daemon
ExecReload=/bin/kill -s HUP $MAINPID

# This user and working directory must already exist
User=runner 
WorkingDirectory=/home/runner
Restart=on-failure
TimeoutSec=0
RestartSec=10

[Install]
WantedBy=multi-user.target
```
Then run `systemctl daemon-reload` to reload the unit files. Make sure to start and enable the service:
```
systemctl start forgejo-runner.service
systemctl enable forgejo-runner.service
```
The runner in Forgejo will now show as `Idle` instead of `Offline`.

You can use the following to check the runner logs:
```
journalctl -u forgejo-runner.service
```

And that is it, Forgejo is set up and the Runner is ready to test.

---