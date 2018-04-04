# What to Expect when You're InSpec'ing

The content within this directory is useful for setting up a few things to make getting started with the exercises a little easier.

This creates:

* A linux Essentials/Intermediate workstation
* A windows Essentials workstation
* A Docker workstation

Requires [terraform](https://www.terraform.io/)

```shell
$ terraform init
$ terraform apply
...
Apply complete! Resources: 10 added, 0 changed, 0 destroyed.

Outputs:

docker.target = 48b775925f0defa7797b33c8fa9cb45c98017805e8f3a12dc3c17ba93b7261ca
linux.target = 18.232.178.133
linux.target.Name = linux-target
linux.target.id = i-0e02fc942d2e9b6a2
windows.target = 35.173.1.170
windows.target.Name = windows-target
windows.target.id = i-0c3a896d68d86d312
```

When you're ready to tear it down.

$ terraform destroy
```
