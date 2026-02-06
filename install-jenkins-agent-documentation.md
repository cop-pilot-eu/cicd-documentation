# COP-PILOT CI/CD – Partner Installation Jenkins Agent Guide

This guide explains how to connect your VM to the COP-PILOT CI/CD stack so Jenkins can execute pipelines on your machine over the SIF (OpenZiti) network.

⏱️Estimated completion time: ~15 minutes

---

## 1. 🆔 Create an Identity for Your VM in CloudZiti

1. Open the CloudZiti console:  
   **https://cop-pilot.cloudziti.io**

2. Go to **Identities → Create New Identity**.

3. Fill in:
   - **Name:** any meaningful name for your VM (e.g. `doc-vm`).
   - **Attributes:** add  
     ```text
     jenkins-cicd-user
     ```
4. Click **Save**.

<p align="center">
  <img src="./img/enable_jenkins_controller/identity_1.png" width="600" alt="Create a new identity"/>
</p>

After saving, the identity will have a **JWT enrollment token** available for download.

5. Back in the **Identities** list, click the three dots (…) for your new identity and download the **enrollment JWT**.

<p align="center">
  <img src="./img/enable_jenkins_controller/token_download.png" width="600" alt="Download the token"/>
</p>

You’ll use this file on your VM to enroll the identity.

---

## 2. 🧩 Install Ziti Edge Tunnel and Enroll the Identity on Your VM

###  2.1 📥 Copy the JWT to Your VM

On your local machine, copy the downloaded `.jwt` file to your VM (e.g. using `scp` or `sftp`), into the `~/ziti` directory:

```bash
mkdir -p ~/ziti
# example from your laptop:
# scp doc-vm.jwt user@your-vm:~/ziti/
```

We will assume the file is now:

```text
~/ziti/<identity-name>.jwt
```

For example:

```text
~/ziti/doc-vm.jwt
```

---

### 2.2 📦 Install prerequisites

On your VM:

```bash
sudo apt update
sudo apt install -y openjdk-21-jdk unzip
```

---

### 2.3 ⬇️ VM Identity Enrollment

[Ziti script](https://github.com/cop-pilot-eu/cicd-documentation/blob/main/ziti_install_enroll_and_tunnel.sh)
Make the script executable:

```bash
chmod +x ziti_install_enroll_and_tunnel.sh
```

Run the script, passing the JWT filename as input:

```bash
./ziti_install_enroll_and_tunnel.sh OpenSlice-central-domain.jwt --nohup
```



Finally, you can verify in the CloudZiti GUI that your identity is **Online** (green dot).

<p align="center">
  <img src="./img/enable_jenkins_controller/identity_online.png" width="600" alt="Identity online"/>
</p>

---

## 3. 🔧 Create an OpenZiti Service so Jenkins Can SSH into Your VM

Now that your VM identity is enrolled and online, the next step is to **expose SSH on your VM through OpenZiti**, so that the Jenkins controller can connect securely without any public IP or firewall changes.

### 3.1 Create the SSH service

In the CloudZiti console:

1. Go to **Services → Create New Service → Create Simple Service**.

2. Fill in the form as follows:

- **Service Name:**
  ```text
  doc-vm-login
  ```

- **Service Attributes:**
  ```text
  cicd-ssh
  ```

- **Accessing Configuration → What identities can access this service?**  
  Add:
  ```text
  jenkins-controller
  ```

- **How will the service be accessed?**
  - SDK only: **No**
  - Hostname:  
    ```text
    doc-vm-login.sif
    ```
  - Port:  
    ```text
    22
    ```

- **Hosting Configuration → What identities can host this service?**  
  Add:
  ```text
  doc-vm
  ```

- **Where should traffic be sent?**
  - Protocol: **TCP**
  - Hostname:  
    ```text
    127.0.0.1
    ```
  - Port:  
    ```text
    22
    ```

3. Click **Save**.

<p align="center">
  <img src="./img/enable_jenkins_controller/service_creation.png" width="600" alt="Service creation"/>
</p>

---

## 4. 👤 Create the Jenkins User and Configure SSH Access

### 4.1 Create the user

```bash
# Create the Jenkins user with a home directory and Bash shell
sudo useradd -m -s /bin/bash jenkins

# Grant passwordless sudo privileges
sudo visudo
# Add the following line under the root entry:
# jenkins ALL=(ALL) NOPASSWD:ALL
# Save and exit the editor
# Each cluster is granted access exclusively to run pipelines targeting its own infrastructure, with no privileges extended to other users or cluster.

# Add Jenkins to the docker group for Docker access without sudo
sudo usermod -aG docker jenkins

# Switch to the Jenkins user
sudo su - jenkins

# Create pipelines directory
mkdir -p ~/pipelines
```

### 4.2 Add the Jenkins controller public key

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
nano ~/.ssh/authorized_keys
```

Paste:

```text
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF572Y7VrEOoIisdwTwkJlQzTjM2Q4SXYxpB3oFaSRXR coppilot-admin@cop-pilot-cicd
```

Fix permissions:

```bash
chmod 600 ~/.ssh/authorized_keys
```

---

## 5. 🔗 Final Step – Register Your VM as a Jenkins Node

Once everything is set up, email:

**konstantinos.fragkos@netcompany.com**

Include:
- Your VM identity name (e.g. `doc-vm`)
- Your service name (e.g. `doc-vm-login`)

You will then be added as a Jenkins node and can run pipelines against your VM.

---
