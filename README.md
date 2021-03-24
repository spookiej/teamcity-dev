# Teamcity Local Development
A project that enables local development and testing against teamcity, right on your workstation.

The docker-compose.yml config was adapted from here: https://ngeor.com/2017/12/26/my-local-teamcity-setup.html

# Start Teamcity
Run the following command `make up`. This will create all required directories and start the docker containers.

```
make up
Creating network "teamcity" with the default driver
Creating teamcity_server_1 ... done
Creating teamcity_agent_1  ... done
```

You can now visit `http://localhost:8111/` to setup an admin account.

Perform the following:<br>
1. Click Proceed
2. Select `Internal (HSQLDB)`
3. Accept License agreement and continue
4. Setup an admin account
5. update the .env file in the root of this project if required.
6. Authorize the agent http://localhost:8111/agents.html?tab=unauthorizedAgents
<br><br>

You're now ready to start configuring teamcity via terraform.

# Configuring Teamcity
## Install terraform and provider
This project is using asdf to manage the terraform version. This project assumes it is already installed.

To ensure the correct tf version is used run: `make install-tf`<br>

To install the terraform teamcity provider run the following command `make install-plugins`. The plugin will then be installed at `~/.terraform.d/plugins/<os_typ>_<os_arch>/`. eg `~/.terraform.d/plugins/darwin_amd64/` for mac.

## Run the terraform
1. source your teamcity username and password `source .env`
2. run the terraform
```
cd terraform
terraform apply

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # teamcity_build_config.build will be created
  + resource "teamcity_build_config" "build" {
      + description = "build 'mock project'"
      + id          = (known after apply)
      + name        = "run some stuff"
      + project_id  = (known after apply)
      + settings    = (known after apply)

      + step {
          + args    = "default_target --verbose"
          + code    = <<~EOT
                #!/bin/bash
                ls -la
                git status
            EOT
          + name    = "build_script"
          + step_id = (known after apply)
          + type    = "cmd_line"
        }

      + vcs_root {
          + checkout_rules = []
          + id             = (known after apply)
        }
    }

  # teamcity_project.root will be created
  + resource "teamcity_project" "root" {
      + description = "devlopment project for local testing"
      + id          = (known after apply)
      + name        = "dev"
    }

  # teamcity_project.test will be created
  + resource "teamcity_project" "test" {
      + id        = (known after apply)
      + name      = "test"
      + parent_id = (known after apply)
    }

  # teamcity_vcs_root_git.repo will be created
  + resource "teamcity_vcs_root_git" "repo" {
      + default_branch          = "refs/heads/master"
      + enable_branch_spec_tags = false
      + fetch_url               = "github.com:spookiej/teamcity-test.git"
      + id                      = (known after apply)
      + name                    = "teamcity-test"
      + project_id              = (known after apply)
      + push_url                = (known after apply)
      + submodule_checkout      = "CHECKOUT"
      + username_style          = "userid"

      + agent {
          + clean_files_policy = "untracked"
          + clean_policy       = "always"
          + use_mirrors        = true
        }

      + auth {
          + key_spec = "id_rsa"
          + password = (sensitive value)
          + ssh_type = "uploadedKey"
          + type     = "ssh"
          + username = "git"
        }
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

teamcity_project.root: Creating...
teamcity_project.root: Creation complete after 0s [id=Dev]
teamcity_project.test: Creating...
teamcity_vcs_root_git.repo: Creating...
teamcity_vcs_root_git.repo: Creation complete after 1s [id=Dev_TeamcityTest]
teamcity_project.test: Creation complete after 1s [id=Dev_Test]
teamcity_build_config.build: Creating...
teamcity_build_config.build: Creation complete after 1s [id=Dev_Test_RunSomeStuff]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```

6. Upload your private ssh key that is configured on github here: http://localhost:8111/admin/editProject.html?projectId=Dev&tab=ssh-manager the name you give the key needs to align with the terraform name which in the example is `id_rsa`.

# Stop Teamcity
Run the following command `make down`. This will stop all the docker containers.

```
make down
Stopping teamcity_agent_1  ... done
Stopping teamcity_server_1 ... done
Removing teamcity_agent_1  ... done
Removing teamcity_server_1 ... done
Removing network teamcity
```

**to cleanup the persistent data**: run `make clean`. this will delete all the data associated with the local instance of teamcity.
```
make clean
Are you sure? [y/N]: y
```
