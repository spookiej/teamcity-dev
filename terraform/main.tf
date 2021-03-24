resource "teamcity_project" "root" {
  name        = var.root_project_name
  description = var.root_project_description
}

resource "teamcity_vcs_root_git" "repo" {
  name           = var.root_repo_name
  project_id     = teamcity_project.root.id
  fetch_url      = var.root_repo_fetch_url
  default_branch = "refs/heads/master"

  enable_branch_spec_tags = false
  username_style          = "userid"
  submodule_checkout      = "checkout"

  # Auth block configures the authentication to Git VCS
  auth {
    type     = "ssh"
    ssh_type = "uploadedKey"
    key_spec = var.root_repo_key_spec
    username = var.root_repo_username
  }

  # Configure agent settings
  agent {
    clean_policy       = "always"
    clean_files_policy = "untracked"
    use_mirrors        = true
  }
}

resource teamcity_project "test" {
  name      = "test"
  parent_id = teamcity_project.root.id
}

resource "teamcity_build_config" "build" {
  name        = "run some stuff"
  description = "build 'mock project'"
  project_id  = teamcity_project.test.id

  vcs_root {
    id        = teamcity_vcs_root_git.repo.id
  }

  step {
    type = "cmd_line"
    name = "build_script"
    code = file("./files/build.sh")
    args = "default_target --verbose"
  }
}