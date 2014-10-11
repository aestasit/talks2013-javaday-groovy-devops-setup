# Groovy DevOps in the Cloud

This project provides an example setup that shows features of Sshoogr (<https://github.com/aestasit/sshoogr>), Gramazon (<https://github.com/aestasit/gramazon>) and PuppetUnit (<https://github.com/aestasit/puppet-unit>). 
Those tools were presented during "**Groovy DevOps in the Cloud**" talk at **Java Day Riga**, *2013*  by *Luciano Fiandesio* and *Andrey Adamovich*.

## Usage

This setup provides a **Gradle** script (`build.gradle`) that glues together all bits and pieces:

- `startInstance` task starts new machine in EC2 
- `uploadModules` task uploads Puppet modules to the newly created machine
- `test` task runs JUnit integration tests against the newly created machine
- `terminateInstance` task terminates the machine

Before you can take advantage of this setup, you will need to at least:

- Create **AWS** account
- Create **access and secret keys** to call EC2 API
- Set access and secret keys inside `gradle.properties`
- Create new key pair called `cloud-do` in `eu-west-1` region (or change the name of the key or the region in the `build.gradle` file to match any of the existing keys)
- Save newly generated private key in the root directory of the project as `cloud-do.pem` (or change `build.gradle` to match your file name or region)
- Create new security group `cloud-do` (or change the name of the security group in the `build.gradle` file to match any of the existing security groups)
- Allow inbound connecitons on port `22` for the configured security group
- Change the AMI identifier inside the `build.gradle` to match your OS image which has Puppet already installed

More details are also available in the presentation slides: <https://github.com/aestasit/talks2013-javaday-groovy-devops-slides>.




[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/aestasit/talks2013-javaday-groovy-devops-setup/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

