maintainer       "YOUR_COMPANY_NAME"
maintainer_email "YOUR_EMAIL"
license          "All rights reserved"
description      "Installs/Configures ostn"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

depends "build-essential"
depends "git"
depends "postgresql"
depends "nginx"
depends "rbenv"
depends "sudo"
